import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/themes/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late SharedPreferences prefs;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.accent),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Save logged-in state in SharedPreferences
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userEmail', email);

      if (!mounted) return;
      _showSnackBar("Login Successful");
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong. Please try again.";

      if (e.code == 'user-not-found') {
        message = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format.";
      }

      _showSnackBar(message);
    } catch (e) {
      _showSnackBar("An error occurred. Try again.");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,

        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          ),
          child: Text(
            'Login',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Colors.white,
            ),
          ),

        ),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Welcome header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.login,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Welcome Back!",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Sign in to continue your health journey",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Login form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: _obscurePassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            setState(() => isLoading = true);

                            if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                              _showSnackBar("Please fill all fields");
                              setState(() => isLoading = false);
                              return;
                            }

                            try {
                              final res = await ApiService.login(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );

                              if (!mounted) return;

                              if (res['success'] == true) {
                                _showSnackBar("Login Successful");
                                Navigator.pushReplacementNamed(context, '/home');
                              } else {
                                _showSnackBar(res['message'] ?? "Invalid email or password!");
                              }
                            } catch (e) {
                              String errorMsg = "Something went wrong. Please try again.";
                              if (e.toString().contains("SocketException")) {
                                errorMsg = "No Internet connection. Please check your network.";
                              } else if (e.toString().contains("Timeout")) {
                                errorMsg = "Server is taking too long. Try again later.";
                              }
                              _showSnackBar(errorMsg);
                            }

                            setState(() => isLoading = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Login',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],

                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      child: Text(
                        'Register',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

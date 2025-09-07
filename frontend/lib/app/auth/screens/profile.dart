import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../common/themes/colors.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  final TextEditingController _nameController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? "";
  }

  Future<void> _updateDisplayName() async {
    if (_nameController.text.trim().isEmpty) return;
    try {
      await user!.updateDisplayName(_nameController.text.trim());
      await user!.reload();
      user = FirebaseAuth.instance.currentUser;
      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Username updated!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating username: $e")));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Profile header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "User Profile",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Manage your account settings",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Profile options
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildProfileOption(
                        context,
                        icon: Icons.edit,
                        title: "Edit Profile",
                        subtitle: "Update your personal information",
                        onTap: () {},
                      ),
                      const Divider(height: 32),
                      _buildProfileOption(
                        context,
                        icon: Icons.notifications,
                        title: "Notifications",
                        subtitle: "Manage your notification preferences",
                        onTap: () {},
                      ),
                      const Divider(height: 32),
                      _buildProfileOption(
                        context,
                        icon: Icons.security,
                        title: "Privacy & Security",
                        subtitle: "Control your privacy settings",
                        onTap: () {},
                      ),
                      const Divider(height: 32),
                      _buildProfileOption(
                        context,
                        icon: Icons.help,
                        title: "Help & Support",
                        subtitle: "Get help and contact support",
                        onTap: () {},
                      ),
                      const Divider(height: 32),
                      _buildProfileOption(
                        context,
                        icon: Icons.logout,
                        title: "Logout",
                        subtitle: "Sign out of your account",
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // App info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "SwasthAI",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Version 1.0.0",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your AI-powered health assistant",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDestructive 
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isDestructive ? AppColors.error : AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textLight,
              size: 16,

            ),
          ],
        ),
      ),
    );
  }
}

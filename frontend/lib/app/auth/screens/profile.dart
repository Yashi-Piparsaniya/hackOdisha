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
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: user == null
          ? const Center(child: Text("No user logged in"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.accent,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (user!.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null) as ImageProvider<Object>?,
                  child: _image == null && user!.photoURL == null
                      ? Text(
                    user!.displayName != null &&
                        user!.displayName!.isNotEmpty
                        ? user!.displayName![0].toUpperCase()
                        : "U",
                    style: const TextStyle(
                        fontSize: 40, color: Colors.white),
                  )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _updateDisplayName,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: Text(user!.email ?? "Not set"),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15)),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

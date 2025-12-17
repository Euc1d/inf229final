import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart' as auth;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _showPasswordFields = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<auth.AuthProvider>(context, listen: false);
    _nameController.text = authProvider.user?.name ?? '';
    _emailController.text = authProvider.user?.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo selected!'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.orange),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.orange),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadAvatar(String userId) async {
    if (_selectedImage == null) return null;

    try {
      final ref = FirebaseStorage.instance.ref().child('avatars').child('$userId.jpg');
      await ref.putFile(File(_selectedImage!.path));
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<auth.AuthProvider>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) throw Exception('No user logged in');

      String? avatarUrl;
      if (_selectedImage != null) {
        avatarUrl = await _uploadAvatar(user.uid);
      }

      Map<String, dynamic> updates = {'name': _nameController.text.trim()};
      if (avatarUrl != null) {
        updates['avatarUrl'] = avatarUrl;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updates);

      if (_emailController.text.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(_emailController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification email sent. Check your inbox.'), duration: Duration(seconds: 3)),
          );
        }
      }

      if (_showPasswordFields && _newPasswordController.text.isNotEmpty) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated!')));
        }
      }

      await authProvider.refreshUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildAvatar(auth.AuthProvider authProvider) {
    final user = authProvider.user;

    if (_selectedImage != null) {
      return ClipOval(
        child: Image.file(
          File(_selectedImage!.path),
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    }

    if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          user.avatarUrl!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const CircleAvatar(
              radius: 60,
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(user),
        ),
      );
    }

    return _buildDefaultAvatar(user);
  }

  Widget _buildDefaultAvatar(user) {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.orange,
      child: Text(
        user?.name.isNotEmpty == true ? user.name[0].toUpperCase() : 'U',
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<auth.AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Stack(
                  children: [
                    _buildAvatar(authProvider),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text('Tap to change avatar', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter your email';
                  if (!value.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Change Password'),
                value: _showPasswordFields,
                onChanged: (value) => setState(() => _showPasswordFields = value ?? false),
                activeColor: Colors.orange,
              ),
              if (_showPasswordFields) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => _showPasswordFields && (value == null || value.isEmpty) ? 'Enter current password' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (_showPasswordFields && (value == null || value.isEmpty)) return 'Enter new password';
                    if (_showPasswordFields && value!.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => _showPasswordFields && value != _newPasswordController.text ? 'Passwords do not match' : null,
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _updateProfile,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Save Changes', style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart'; // Import the permission_handler package

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bioController;
  late TextEditingController _experiencesController;
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _experiencesController = TextEditingController();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _experiencesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Request permission to access the gallery
    final permissionStatus = await Permission.photos.request();

    if (permissionStatus.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission Denied')));
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? imageUrl;

        if (_profileImage != null) {
          final storageRef = FirebaseStorage.instance.ref().child('profile_pics/${DateTime.now().millisecondsSinceEpoch}.jpg');
          final uploadTask = storageRef.putFile(_profileImage!);
          await uploadTask.whenComplete(() {});

          imageUrl = await storageRef.getDownloadURL();
        }
        final user = FirebaseAuth.instance.currentUser;
        final uid = user?.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'bio': _bioController.text,
          'experiences': _experiencesController.text,
          'photoUrl': imageUrl ?? '',
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          _bioController.text = userDoc['bio'] ?? '';
          _experiencesController.text = userDoc['experiences'] ?? '';
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : Icon(Icons.camera_alt, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a bio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _experiencesController,
                  decoration: const InputDecoration(
                    labelText: 'Experiences',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your experiences';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

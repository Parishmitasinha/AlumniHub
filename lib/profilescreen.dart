import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "Sinha";
  String email = "sinha11@gmail.com";
  String bio = "  ";
  File? imagePath;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = name;
    _emailController.text = email;
    _bioController.text = bio;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Firebase.initializeApp();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final userProfileData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'bio': _bioController.text,
      'profileImage': imagePath != null ? imagePath!.path : '',
    };

    try {
      await FirebaseFirestore.instance.collection('Profile').doc('user-id').set(userProfileData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _toggleEditing,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: imagePath != null
                  ? FileImage(imagePath!) // Correctly display the image after selecting
                  : NetworkImage("https://www.example.com/profile-image.jpg") as ImageProvider,
              child: Icon(Icons.camera_alt, size: 30, color: Colors.white),
            ),
          ),
          SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Name"),
            enabled: _isEditing,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: "Email"),
            enabled: _isEditing,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: InputDecoration(labelText: "Bio"),
            enabled: _isEditing,
          ),
          SizedBox(height: 16),
          if (_isEditing)
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text("Save Profile"),
            ),
        ],
      ),
    );
  }
}

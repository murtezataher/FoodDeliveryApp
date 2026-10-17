import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';  // Import permission_handler

class EditChefProfileScreen extends StatefulWidget {
  const EditChefProfileScreen({Key? key}) : super(key: key);

  @override
  _EditChefProfileScreenState createState() => _EditChefProfileScreenState();
}

class _EditChefProfileScreenState extends State<EditChefProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final restaurantNameController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String? _existingImageUrl;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChefData();
    _requestPermissions();  // Request permissions on screen initialization
  }

  // Request storage permissions
  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      print('Storage permission granted');
    } else {
      print('Storage permission denied');
    }
  }

  Future<void> _loadChefData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      final userId = user.uid;

      final chefDoc = await FirebaseFirestore.instance.collection('chefs').doc(userId).get();

      if (chefDoc.exists) {
        final data = chefDoc.data()!;
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['address'] ?? '';
        restaurantNameController.text = data['restaurant_name'] ?? '';
        _existingImageUrl = data['image_url'];  // Using 'image_url' from Firestore
      } else {
        throw Exception('No chef data found for the logged-in user.');
      }
    } catch (e) {
      print('Error loading chef data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    String? imageUrl = _existingImageUrl;

    if (_selectedImage != null) {
      imageUrl = await _uploadImage(_selectedImage!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('chefs').doc(user.uid).set({
        'name': nameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'restaurant_name': restaurantNameController.text,
        'image_url': imageUrl,  // Save the image URL
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);  // Go back to the previous screen
    } catch (e) {
      print('Error saving changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Profile Picture',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(_selectedImage!),
              )
                  : CircleAvatar(
                radius: 50,
                backgroundImage: _existingImageUrl != null
                    ? NetworkImage(_existingImageUrl!) as ImageProvider
                    : null,
                child: _existingImageUrl == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: restaurantNameController,
              decoration: const InputDecoration(labelText: 'Restaurant Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

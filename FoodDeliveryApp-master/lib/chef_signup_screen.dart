import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:foodapp/signin.dart';
import 'package:foodapp/signin_chef_screen.dart';
import 'package:foodapp/widgets.dart';

class ChefSignUpScreen extends StatefulWidget {
  const ChefSignUpScreen({super.key});

  @override
  State<ChefSignUpScreen> createState() => _ChefSignUpScreenState();
}

class _ChefSignUpScreenState extends State<ChefSignUpScreen> {
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _restaurantNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  File? _image; // To store the selected image
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(String userId) async {
    if (_image == null) {
      // Use the default image URL if no image is selected
      return 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png';
    }

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chef_images/$userId/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = await storageRef.putFile(_image!);
      return await uploadTask.ref.getDownloadURL(); // Return the download URL
    } catch (e) {
      print("Image upload failed: $e");
      // Use the default image URL if the upload fails
      return 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: const Color(0xFF1E293B),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Chef Sign Up",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                reuseableTextField("Enter Name", false, _nameTextController),
                const SizedBox(height: 15),
                reuseableTextField("Restaurant Name", false, _restaurantNameController),
                const SizedBox(height: 15),
                reuseableTextField("Address", false, _addressController),
                const SizedBox(height: 15),
                reuseableTextField("Phone Number", false, _phoneController),
                const SizedBox(height: 15),
                reuseableTextField("Enter Email", false, _emailTextController),
                const SizedBox(height: 15),
                reuseableTextField("Enter Password", true, _passwordTextController),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _image == null
                        ? const Center(
                      child: Text(
                        "Tap to upload image",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                        : Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SignINSignUPButtons(context, "Sign Up", () async {
                  try {
                    // Create User in Firebase Authentication
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: _emailTextController.text.trim(),
                      password: _passwordTextController.text.trim(),
                    );

                    // Save Chef's Information to Firestore
                    User? user = userCredential.user;
                    if (user != null) {
                      String imageUrl = await _uploadImage(user.uid);

                      await FirebaseFirestore.instance.collection('chefs').doc(user.uid).set({
                        'uid': user.uid,
                        'name': _nameTextController.text.trim(),
                        'restaurant_name': _restaurantNameController.text.trim(),
                        'address': _addressController.text.trim(),
                        'phone': _phoneController.text.trim(),
                        'email': _emailTextController.text.trim(),
                        'rating': 0.0, // Default rating
                        'image_url': imageUrl, // Store image URL
                        'time_stamp': Timestamp.now(),
                        'delivery_fee': 0,
                        'delivery_time': 'Unavailable',
                        'revenue': 0,
                        'income': 0
                      });

                      print("Chef profile saved successfully!");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInChefScreen()),
                      );
                    }
                  } catch (error) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: Text(error.toString()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

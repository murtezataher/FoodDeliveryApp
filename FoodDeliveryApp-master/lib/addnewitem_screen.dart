import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class AddNewItemScreen extends StatefulWidget {
  const AddNewItemScreen({Key? key}) : super(key: key);

  @override
  State<AddNewItemScreen> createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends State<AddNewItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); // New description controller

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isAvailable = true; // Default availability status is 'available'

  // List of predefined categories
  final List<String> _categories = ['Pizza', 'Burger', 'Sandwich', 'coffee', 'drinks'];
  String? _selectedCategory; // Store the selected category

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });
    }
  }

  // Function to upload the image to Firebase Storage
  Future<String?> _uploadImage(File imageFile) async {
    try {
      // Generate a unique file name
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Define the storage reference
      Reference storageRef = FirebaseStorage.instance.ref().child('food_images/$fileName');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL of the uploaded image
      String imageUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {      print('Error uploading image: $e');
    return null; // Return null if the upload fails
    }
  }

  // Function to save the new item to Firestore
  Future<void> _saveNewItem() async {
    if (_nameController.text.trim().isEmpty || _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Name and price are required.')));
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please select a category.')));
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Description is required.')));
      return;
    }

    // Check if an image is selected; use default image URL if not
    String imageUrl = 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png';
    if (_pickedImage != null) {
      File imageFile = File(_pickedImage!.path);
      String? uploadedImageUrl = await _uploadImage(imageFile);

      if (uploadedImageUrl == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to upload image.')));
        return;
      }
      imageUrl = uploadedImageUrl; // Update imageUrl with the uploaded one
    }

    // Get the current user's ID
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No user logged in.')));
      return;
    }

    // Reference to the chef's document
    final chefDocRef = FirebaseFirestore.instance.collection('chefs').doc(currentUser.uid);

    // Reference to the chef's food items subcollection
    final chefFoodItemsRef = chefDocRef.collection('chef_food_items');

    // Add the new food item to Firestore
    await chefFoodItemsRef.add({
      'name': _nameController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
      'availability': _isAvailable,
      'category': _selectedCategory, // Save the selected category
      'description': _descriptionController.text.trim(), // Save the description
      'image_url': imageUrl, // Use either the uploaded URL or the default URL
      'time_stamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Item added successfully!')));
    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _nameController),
            const SizedBox(height: 16),
            const Text('Upload Photo', style: TextStyle(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 100,
                width: 100,
                color: Colors.grey[300], // Placeholder for upload
                child: _pickedImage != null
                    ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
                    : const Icon(Icons.upload, size: 40),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Price', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _priceController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),

            const Text('Availability', style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: Text(_isAvailable ? 'Available' : 'Not Available'),
              value: _isAvailable,
              onChanged: (bool value) {
                setState(() {
                  _isAvailable = value;
                });
              },
            ),

            const SizedBox(height: 16),
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text('Select a category'),
              isExpanded: true,
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),

            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)), // New Description Field
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter a description for the item',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _saveNewItem,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


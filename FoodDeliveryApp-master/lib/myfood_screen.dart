import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyFoodScreen extends StatelessWidget {
  const MyFoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (currentUser == null) {
      return const Center(child: Text('User is not logged in.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Food List')),
      body: StreamBuilder<QuerySnapshot>(
        // Fetch food items for the current chef
        stream: FirebaseFirestore.instance
            .collection('chefs')
            .doc(currentUser.uid) // Query by current chef's UID
            .collection('chef_food_items') // Access the chef's food items sub-collection
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No food items available.'));
          }

          final foodItems = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              var foodItem = foodItems[index];
              String availability = foodItem['availability'] == true
                  ? 'Available'
                  : 'Unavailable'; // Convert bool to string

              return _buildFoodItem(
                foodItem.id,
                foodItem['name'],
                foodItem['price'].toString(),
                availability,
                foodItem['image_url'],
                context,
              );
            },
          );
        },
      ),
    );
  }

  // Widget to display each food item
  Widget _buildFoodItem(
      String itemId,
      String title,
      String price,
      String status,
      String imageUrl,
      BuildContext context,
      ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: imageUrl.isNotEmpty
            ? Image.network(imageUrl, height: 50, width: 50, fit: BoxFit.cover)
            : Container(
          height: 50,
          width: 50,
          color: Colors.grey[300], // Placeholder for food image
          child: const Icon(Icons.food_bank, size: 30),
        ),
        title: Text(title),
        subtitle: Text('\PKR $price'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status,
              style: TextStyle(
                color: status == 'Available' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.orangeAccent),
              onPressed: () => _deleteItem(context, itemId),
            ),
          ],
        ),
      ),
    );
  }

  // Function to delete an item
  Future<void> _deleteItem(BuildContext context, String itemId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('chefs')
          .doc(currentUser.uid) // Locate the chef's document
          .collection('chef_food_items') // Access their food items sub-collection
          .doc(itemId) // Locate the specific item by its document ID
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $e')),
      );
    }
  }
}

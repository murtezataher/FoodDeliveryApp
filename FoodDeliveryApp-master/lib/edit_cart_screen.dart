import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'cart_provider.dart';

class EditCartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A), // App bar background
        elevation: 1,
        title: const Text(
          "Edit Cart",
          style: TextStyle(color: Colors.white), // App bar text color
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Return to MyCartScreen
            },
            child: const Text(
              "DONE",
              style: TextStyle(color: Colors.orange), // Orange for "DONE" button
            ),
          ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
        child: Text(
          "Your cart is empty.",
          style: TextStyle(color: Colors.grey[700], fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200], // Light grey container
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Rounded corners for the image
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                  item.imageUrl!, // Fetch the image URL
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image_not_supported,
                        color: Colors.grey, size: 50);
                  },
                )
                    : Icon(Icons.fastfood, color: Colors.grey, size: 50), // Default icon if no image
              ),
              title: Text(
                item.name,
                style: const TextStyle(color: Colors.black), // Black text for item name
              ),
              subtitle: Text(
                "PKR ${item.price.toStringAsFixed(2)} x ${item.quantity}",
                style: TextStyle(color: Colors.grey[700]), // Dark grey subtitle
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.black),
                    onPressed: () {
                      if (item.quantity > 1) {
                        // Decrease quantity
                        cart.updateItemQuantity(item.name, item.size, item.quantity - 1);
                      } else {
                        // Remove item if quantity is 1
                        cart.removeItem(item.name, item.size);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${item.name} removed from cart."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  Text(
                    "${item.quantity}",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.black),
                    onPressed: () {
                      // Increase quantity
                      cart.updateItemQuantity(item.name, item.size, item.quantity + 1);
                    },
                  ),
                ],
              ),
              onLongPress: () {
                // Remove item from the cart with a long press
                cart.removeItem(item.name, item.size);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${item.name} removed from cart."),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

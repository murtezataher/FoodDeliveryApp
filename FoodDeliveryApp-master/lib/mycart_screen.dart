import 'package:foodapp/edit_cart_screen.dart';
import 'package:foodapp/payment_method_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'cart_provider.dart';

class MyCartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 1, // Slight shadow
        title: const Text(
          "My Cart",
          style: TextStyle(color: Colors.white), // White text for visibility
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditCartScreen()),
              );
            },
            child: const Text(
              "EDIT ITEMS",
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Light grey for item container
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
                          return Icon(Icons.image_not_supported, color: Colors.grey, size: 50);
                        },
                      )
                          : Icon(Icons.fastfood, color: Colors.grey, size: 50), // Default icon if no image
                    ),

                    title: Text(
                      item.name,
                      style: const TextStyle(color: Colors.black), // Black for title
                    ),
                    subtitle: Text(
                      "Size: ${item.size} - PKR ${item.price} x ${item.quantity}",
                      style: TextStyle(color: Colors.grey[700]), // Slightly dark grey
                    ),
                    trailing: Text(
                      "PKR ${(item.price * item.quantity).toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey, // Slight shadow for separation
                  blurRadius: 5,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TOTAL: PKR ${cart.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Payment Method Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PaymentMethodScreen(totalAmount: cart.totalPrice),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "PLACE ORDER",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

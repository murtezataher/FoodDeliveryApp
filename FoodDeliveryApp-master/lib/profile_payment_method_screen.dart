import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/addcard_screen.dart';
import 'package:foodapp/payment_success_screen.dart';
import 'cart_provider.dart';
import 'card_model.dart';

class ProfilePaymentMethodScreen extends StatefulWidget {


  const ProfilePaymentMethodScreen({Key? key})
      : super(key: key);

  @override
  _ProfilePaymentMethodScreenState createState() => _ProfilePaymentMethodScreenState();
}

class _ProfilePaymentMethodScreenState extends State<ProfilePaymentMethodScreen> {
  String selectedPaymentMethod = "Cash";
  final List<CardDetails> savedCards = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _fetchCustomerId() async {
    try {
      // Get the current user
      final user = _auth.currentUser;
      if (user == null) return null;

      // Check if the customer exists in Firestore
      final customerSnapshot = await _firestore
          .collection('customers')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (customerSnapshot.docs.isNotEmpty) {
        return customerSnapshot.docs.first.id; // Return the document ID
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching customer ID: $e")),
      );
    }
    return null;
  }

  Future<void> _saveOrderToFirestore(BuildContext context) async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    // Ensure a restaurant ID is available
    final String? restaurantId = cart.currentRestaurantId;
    if (restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No restaurant associated with the cart.")),
      );
      return;
    }

    // Fetch the customer ID
    final String? customerId = await _fetchCustomerId();
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch customer information.")),
      );
      return;
    }

    // Fetch the customer's name from Firestore
    String customerName = "";
    try {
      final customerDoc =
      await _firestore.collection('customers').doc(customerId).get();
      if (customerDoc.exists) {
        customerName = customerDoc.data()?['name'] ?? "Unknown Customer";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching customer name: $e")),
      );
    }

    // Fetch the restaurant name from Firestore
    String restaurantName = "";
    try {
      final chefDoc = await _firestore.collection('chefs').doc(restaurantId).get();
      if (chefDoc.exists) {
        restaurantName = chefDoc.data()?['restaurant_name'] ?? "Unknown Restaurant";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching restaurant name: $e")),
      );
    }

    // Prepare order data
    final orderData = {
      "items": cart.items.map((item) {
        return {
          "name": item.name,
          "size": item.size,
          "price": item.price,
          "quantity": item.quantity,
          "total": item.price * item.quantity,
          "imageUrl": item.imageUrl,
        };
      }).toList(),
      "paymentMethod": selectedPaymentMethod,
      "timestamp": FieldValue.serverTimestamp(),
      "customerId": customerId,
    };

    try {
      // Save order to Firestore under customer's orders
      final customerOrderRef = _firestore
          .collection('customers')
          .doc(customerId)
          .collection('orders');
      final newOrder = await customerOrderRef.add(orderData);

      // Add notification to customer
      final notificationDataToCustomer = {
        "customerName": customerName,
        "restaurantName": restaurantName,
        "timestamp": FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('customers')
          .doc(customerId)
          .collection('notifications')
          .add(notificationDataToCustomer);

      // Save order to Firestore under chef's orders
      final chefOrderRef = _firestore
          .collection('chefs')
          .doc(restaurantId)
          .collection('orders');
      await chefOrderRef.doc(newOrder.id).set(orderData);

      // Add notification to chef
      final chefNotificationData = {
        "customerName": customerName,
        "timestamp": FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('chefs')
          .doc(restaurantId)
          .collection('notifications')
          .add(chefNotificationData);

      // Update income for the associated chef

      // Clear cart after successful order
      cart.clearCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to process order: $e")),
      );
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Payment",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPaymentOption("Visa", Icons.credit_card),
                    _buildPaymentOption("Mastercard", Icons.payment),
                  ],
                ),
                const SizedBox(height: 24),
                if (selectedPaymentMethod == "Visa" ||
                    selectedPaymentMethod == "Mastercard") ...[
                  ...savedCards.map(
                        (card) => ListTile(
                      title: Text(card.holderName),
                      subtitle: Text(
                          "**** **** **** ${card.cardNumber.substring(12)}"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCardScreen(
                            onCardAdded: (newCard) {
                              setState(() {
                                savedCards.add(newCard);
                                selectedPaymentMethod = "Visa"; // Auto-select
                              });
                            },
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, color: Colors.orange),
                        SizedBox(width: 8),
                        Text("Add New",
                            style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                  ),
                ],

              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: selectedPaymentMethod == method
                ? Colors.orange
                : Colors.grey[300],
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            method,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/addcard_screen.dart';
import 'package:foodapp/payment_success_screen.dart';
import 'cart_provider.dart';
import 'card_model.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentMethodScreen({Key? key, required this.totalAmount})
      : super(key: key);

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selectedPaymentMethod = "Cash";
  final List<CardDetails> savedCards = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String restaurantName = ""; // Variable to store the restaurant name

  Future<String?> _fetchCustomerId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final customerSnapshot = await _firestore
          .collection('customers')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (customerSnapshot.docs.isNotEmpty) {
        return customerSnapshot.docs.first.id;
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

    final String? restaurantId = cart.currentRestaurantId;
    if (restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No restaurant associated with the cart.")),
      );
      return;
    }

    final String? customerId = await _fetchCustomerId();
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch customer information.")),
      );
      return;
    }

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
      "totalAmount": widget.totalAmount,
      "paymentMethod": selectedPaymentMethod,
      "timestamp": FieldValue.serverTimestamp(),
      "customerId": customerId,
    };

    try {
      final customerOrderRef = _firestore
          .collection('customers')
          .doc(customerId)
          .collection('orders');
      final newOrder = await customerOrderRef.add(orderData);

      final notificationDataToCustomer = {
        "customerName": customerName,
        "restaurantName": restaurantName,
        "totalPrice": widget.totalAmount,
        "timestamp": FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('customers')
          .doc(customerId)
          .collection('notifications')
          .add(notificationDataToCustomer);

      final chefOrderRef = _firestore
          .collection('chefs')
          .doc(restaurantId)
          .collection('orders');
      await chefOrderRef.doc(newOrder.id).set(orderData);

      final chefNotificationData = {
        "customerName": customerName,
        "totalPrice": widget.totalAmount,
        "timestamp": FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('chefs')
          .doc(restaurantId)
          .collection('notifications')
          .add(chefNotificationData);

      final chefRef = _firestore.collection('chefs').doc(restaurantId);
      await _firestore.runTransaction((transaction) async {
        final chefSnapshot = await transaction.get(chefRef);
        if (chefSnapshot.exists) {
          final currentIncome = chefSnapshot.data()?['income'] ?? 0.0;
          final currentRevenue = chefSnapshot.data()?['revenue'] ?? 0.0;
          transaction.update(chefRef, {
            "income": currentIncome + widget.totalAmount,
            "revenue": currentRevenue + widget.totalAmount,
          });
        } else {
          transaction.set(chefRef, {
            "income": widget.totalAmount,
            "revenue": widget.totalAmount,
          });
        }
      });

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
                    _buildPaymentOption("Cash", Icons.money),
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
                                selectedPaymentMethod = "Visa";
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOTAL:",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "\PKR ${widget.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await _saveOrderToFirestore(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentSuccessScreen(
                      restaurantName: restaurantName,
                      orderTime: DateTime.now(),
                    ),
                  ),
                );
              },
              child: const Text(
                "PAY & CONFIRM",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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

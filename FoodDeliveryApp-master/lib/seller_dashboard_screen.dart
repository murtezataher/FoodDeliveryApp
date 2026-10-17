import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/running_orders_screen.dart';
import 'review_screen.dart'; // Import your ReviewScreen

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  Future<Map<String, dynamic>> _getChefData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot chefData =
      await FirebaseFirestore.instance.collection('chefs').doc(user.uid).get();
      return chefData.data() as Map<String, dynamic>;
    } else {
      throw Exception("User not authenticated");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getChefData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final chefData = snapshot.data!;
          final revenue = (chefData['revenue'] ?? 0).toDouble();
          final rating = (chefData['rating'] ?? 0.0).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard('20', 'Running Orders', context),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRevenueSection(revenue),
                const SizedBox(height: 16),
                _buildReviewSection(context, rating),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String value, String title, BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (title == 'Running Orders') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RunningOrdersScreen()),
            );
          }
        },
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueSection(double revenue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Revenue: \PKR ${revenue.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildGraphPlaceholder(),
      ],
    );
  }

  Widget _buildGraphPlaceholder() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: NetworkImage(
            'https://th.bing.com/th/id/R.1b7c4111819c151d66ec3f999330b465?rik=H2MbR2twcKdHVg&pid=ImgRaw&r=0',
          ),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context, double rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 30),
            const SizedBox(width: 8),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReviewScreen()),
              );
            },
            child: const Text(
              'See All Reviews',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }
}

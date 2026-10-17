import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerNotificationScreen extends StatelessWidget {
  const CustomerNotificationScreen({Key? key}) : super(key: key);

  // Function to format Firestore Timestamp
  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final hours = date.hour > 12 ? date.hour - 12 : date.hour;
    final minutes = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    return "$day/$month/$year $hours:$minutes $ampm";
  }

  @override
  Widget build(BuildContext context) {
    // Get the current customer's UID
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Notifications',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('You are not logged in. Please log in to see notifications.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(currentUserId)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, notificationSnapshot) {
          if (!notificationSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications available.'));
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: notificationSnapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final totalPrice = data['totalPrice'] ?? 0;
              final timeStamp = data['timestamp'] as Timestamp;
              final restaurantName = data['restaurantName'] ?? 'Unknown Restaurant';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: const Icon(Icons.notifications, color: Colors.orange),
                ),
                title: Text(
                  'Order placed for PKR ${totalPrice.toString()} from $restaurantName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  formatTimestamp(timeStamp),
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

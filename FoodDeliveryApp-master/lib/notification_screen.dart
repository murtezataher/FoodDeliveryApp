import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  // Helper method to format timestamp
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chefs').snapshots(),
        builder: (context, chefSnapshot) {
          if (!chefSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Widget> notificationWidgets = [];

          for (var chefDoc in chefSnapshot.data!.docs) {
            final chefId = chefDoc.id;

            notificationWidgets.add(
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chefs')
                    .doc(chefId)
                    .collection('notifications')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, notificationSnapshot) {
                  if (!notificationSnapshot.hasData ||
                      notificationSnapshot.data!.docs.isEmpty) {
                    return Container(); // No notifications
                  }

                  return Column(
                    children: notificationSnapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final customerName = data['customerName'] ?? 'Unknown';
                      final totalPrice = data['totalPrice'] ?? 0;
                      final timestamp = data['timestamp'] as Timestamp;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(Icons.notifications, color: Colors.orangeAccent),
                        ),
                        title: Text(
                          'Order placed by $customerName for PKR $totalPrice',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          formatTimestamp(timestamp),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Container(
                          height: 20,
                          width: 20,
                          color: Colors.grey.shade300,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: notificationWidgets,
          );
        },
      ),
    );
  }
}

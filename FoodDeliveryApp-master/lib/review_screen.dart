import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String chefUid = FirebaseAuth.instance.currentUser!.uid; // Get the current chef's UID

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Reviews", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('chefs')
            .doc(chefUid)
            .collection('reviews')
            .orderBy('timestamp', descending: true) // Order by timestamp
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading reviews'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reviews yet.'));
          }

          // Extract reviews from Firestore
          var reviews = snapshot.data!.docs.map((doc) {
            return {
              "customerId": doc['customerId'],
              "rating": doc['rating'].toString(),
              "review": doc['review'],
            };
          }).toList();

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.person, color: Colors.grey),
                ),
                title: Text(
                  "Rating: ${reviews[index]['rating']}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(reviews[index]['review']!),
                trailing: Text(
                  'By: ${reviews[index]["customerId"]}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

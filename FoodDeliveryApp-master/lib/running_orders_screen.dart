import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RunningOrdersScreen extends StatelessWidget {
  const RunningOrdersScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    String chefUid = FirebaseAuth.instance.currentUser!.uid;

    // Fetch orders from Firestore
    QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
        .collection('chefs')
        .doc(chefUid)
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .get();

    // Parse the orders into a list of maps
    return ordersSnapshot.docs.map((doc) {
      return {
        'items': doc['items'], // List of items in the order
        'timestamp': doc['timestamp'],
        'paymentMethod': doc['paymentMethod'],
        'totalAmount': doc['totalAmount'],
        'orderId': doc.id,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running Orders'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching orders.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No running orders available.'));
          }

          List<Map<String, dynamic>> orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final items = List<Map<String, dynamic>>.from(order['items']);
              final timestamp = order['timestamp'];
              final paymentMethod = order['paymentMethod'];
              final totalAmount = order['totalAmount'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ExpansionTile(
                  title: Text(
                    'Order #${order['orderId']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Method: $paymentMethod'),
                      Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}'),
                      Text('Time: ${timestamp.toDate()}'),
                    ],
                  ),
                  children: items.map((item) {
                    return ListTile(
                      leading: Image.network(
                        item['imageUrl'],
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey),
                      ),
                      title: Text(item['name']),
                      subtitle: Text(
                          'Quantity: ${item['quantity']}\nPrice: \$${item['price']}'),
                    );
                  }).toList(),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await removeOrder(order['orderId']);
                          // Refresh the UI
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const RunningOrdersScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Done'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          await removeOrder(order['orderId']);
                          // Refresh the UI
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const RunningOrdersScreen()),
                          );
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> removeOrder(String orderId) async {
    String chefUid = FirebaseAuth.instance.currentUser!.uid;

    // Remove order from Firestore
    await FirebaseFirestore.instance
        .collection('chefs')
        .doc(chefUid)
        .collection('orders')
        .doc(orderId)
        .delete();
  }
}

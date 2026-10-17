import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/deliveryman_call_screen.dart';
import 'package:foodapp/deliveryman_message_screen.dart';
import 'package:foodapp/homescreen.dart';

class TrackingOrderScreen extends StatelessWidget {
  final String restaurantName;
  final DateTime orderTime;

  TrackingOrderScreen({
    required this.restaurantName,
    required this.orderTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Track Order'),
        backgroundColor: Colors.grey[200],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[300], // Background color in case the image fails to load
              child: Image.network(
                'https://th.bing.com/th/id/R.5e5df70005a7c14372b13fe7151b1412?rik=il%2f%2bimcK%2b5IwLg&pid=ImgRaw&r=0',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      'Image could not load.',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurantName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Slightly larger text
                ),
                Text('Order at ${formatDateTime(orderTime)}'),
                SizedBox(height: 10),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('orderPlacement').limit(1).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading texts.'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No text found.'));
                    }

                    // Fetch the first document from the collection
                    var data = snapshot.data!.docs[0].data() as Map<String, dynamic>;
                    String text1 = data['text1'] ?? 'Order has been received';
                    String text2 = data['text2'] ?? 'Preparing your food';
                    String text3 = data['text3'] ?? 'Picked up for delivery';

                    return Row(
                      children: [
                        Expanded(child: _buildOrderStatus(text1, text2, text3)),
                        _buildActionButton(
                          color: Colors.orange,
                          icon: Icons.call,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeliveryManCallScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 10),
                        _buildActionButton(
                          color: Colors.blue,
                          icon: Icons.message,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeliveryManMessageScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            color: Colors.white,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                        (route) => false,
                  );
                },
                child: Text(
                  'Continue Ordering',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus(String text1, String text2, String text3) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('20 min', style: TextStyle(fontSize: 28, color: Colors.orange)), // Larger font size
        Text('Estimated Delivery Time', style: TextStyle(fontSize: 18)),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: Colors.orange),
            SizedBox(width: 8),
            Text(text1, style: TextStyle(fontSize: 18)), // Slightly larger text
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: Colors.orange),
            SizedBox(width: 8),
            Text(text2, style: TextStyle(fontSize: 18)), // Slightly larger text
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.circle, size: 8, color: Colors.orange),
            SizedBox(width: 8),
            Text(text3, style: TextStyle(fontSize: 18)), // Slightly larger text
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}

import 'package:flutter/material.dart';
import 'package:foodapp/tracking_order_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String restaurantName; // Restaurant name to be passed
  final DateTime orderTime; // Order time to be passed

  PaymentSuccessScreen({
    required this.restaurantName,
    required this.orderTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://th.bing.com/th/id/R.85c14dfeb8edd88f62b5bbfe671f0108?rik=T38yCB6ZWsrEdA&riu=http%3a%2f%2fclipart-library.com%2fimages_k%2fgreen-checkmark-transparent%2fgreen-checkmark-transparent-17.png&ehk=XzHgRYQ3s7cSIB3YzfqPKv4s787lzN9vDBRhCfmVfH0%3d&risl=&pid=ImgRaw&r=0',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Congratulations!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'You successfully made a payment, enjoy our service!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrackingOrderScreen(
                      restaurantName: restaurantName,
                      orderTime: orderTime,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Track Order',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

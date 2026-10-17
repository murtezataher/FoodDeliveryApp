import 'package:flutter/material.dart';

class ChefFoodDetailsScreen extends StatelessWidget {
  final Map<String, String> foodItem;

  const ChefFoodDetailsScreen({Key? key, required this.foodItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${foodItem['title']}'),
            const SizedBox(height: 10),
            Text('Price: ${foodItem['price']}'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Edit logic
              },
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}

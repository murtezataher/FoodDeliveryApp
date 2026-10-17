import 'package:flutter/material.dart';

class DeliveryManCallScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300], // Placeholder for the image
          ),
          SizedBox(height: 20),
          Text(
            'Robert Fox',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Connecting...',
            style: TextStyle(color: Colors.grey),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {Navigator.pop(context);},
                icon: Icon(Icons.call_end),
                color: Colors.red,
                iconSize: 50,
              ),
              SizedBox(width: 30),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.mic_off),
                color: Colors.grey,
                iconSize: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

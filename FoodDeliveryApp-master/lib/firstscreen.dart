import 'package:flutter/material.dart';
import 'package:foodapp/homescreen.dart';

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF0F172A),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/food.jpg',
                  width: 350,
                  height: 300,
                ),
                SizedBox(height: 24),
                Text(
                  'All your favorites',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Get all your loved foods in one once place, you just place the order we do the rest',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),

                SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  ),
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage() ));},
                  child: Text('NEXT',style: TextStyle(color: Colors.white),),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

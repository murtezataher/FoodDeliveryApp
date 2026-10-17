import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:foodapp/homescreen.dart';
import 'package:foodapp/signin.dart';
import 'package:foodapp/widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _addressTextController = TextEditingController();
  final TextEditingController _phoneTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: const Color(0xFF1E293B),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Customer Sign Up",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                reuseableTextField("Enter Name", false, _nameTextController),
                const SizedBox(height: 20),
                reuseableTextField("Enter Address", false, _addressTextController),
                const SizedBox(height: 20),
                reuseableTextField("Enter Phone Number", false, _phoneTextController),
                const SizedBox(height: 20),
                reuseableTextField("Enter Email", false, _emailTextController),
                const SizedBox(height: 20),
                reuseableTextField("Enter Password", true, _passwordTextController),
                const SizedBox(height: 20),
                SignINSignUPButtons(context, "Sign up", () async {
                  try {
                    // Create Firebase User
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                      email: _emailTextController.text.trim(),
                      password: _passwordTextController.text.trim(),
                    );

                    User? user = userCredential.user;

                    // Add data to Firestore
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('customers')
                          .doc(user.uid)
                          .set({
                        'name': _nameTextController.text.trim(),
                        'phone_number': _phoneTextController.text.trim(),
                        'address': _addressTextController.text.trim(),
                        'email': _emailTextController.text.trim(),
                        'uid': user.uid,
                      });

                      print("Account has been created!");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                      );
                    }
                  } catch (error) {
                    print("Error: ${error.toString()}");
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/homescreen.dart';
import 'package:foodapp/widgets.dart';

class resetpasswordscreen extends StatefulWidget {
  const resetpasswordscreen({super.key});

  @override
  State<resetpasswordscreen> createState() => _resetpasswordscreenState();
}

class _resetpasswordscreenState extends State<resetpasswordscreen> {
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFF1E293B),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 30),
                reuseableTextField("Enter Email", false, _emailTextController),
                const SizedBox(height: 20,),
                SignINSignUPButtons(context, "Reset Password", () {
                  FirebaseAuth.instance.sendPasswordResetEmail(email: _emailTextController.text).then((value) => Navigator.of(context).pop());

                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}

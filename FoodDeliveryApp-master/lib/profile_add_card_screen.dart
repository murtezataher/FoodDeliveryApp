import 'package:flutter/material.dart';
import 'card_model.dart';

class ProfileAddCardScreen extends StatefulWidget {
  final Function(CardDetails) onCardAdded; // Callback to send card data back

  const ProfileAddCardScreen({Key? key, required this.onCardAdded}) : super(key: key);

  @override
  _ProfileAddCardScreenState createState() => _ProfileAddCardScreenState();
}

class _ProfileAddCardScreenState extends State<ProfileAddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  String holderName = "";
  String cardNumber = "";
  String expiryDate = "";
  String cvc = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Add Card",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Card Holder Name"),
                onSaved: (value) => holderName = value ?? "",
                validator: (value) =>
                value == null || value.isEmpty ? "Enter holder name" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "Card Number"),
                keyboardType: TextInputType.number,
                onSaved: (value) => cardNumber = value ?? "",
                validator: (value) =>
                value == null || value.length != 16 ? "Enter valid card number" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "Expiry Date (MM/YY)"),
                onSaved: (value) => expiryDate = value ?? "",
                validator: (value) =>
                value == null || !RegExp(r"^\d{2}/\d{2}$").hasMatch(value)
                    ? "Enter valid expiry date"
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: "CVC"),
                keyboardType: TextInputType.number,
                onSaved: (value) => cvc = value ?? "",
                validator: (value) =>
                value == null || value.length != 3 ? "Enter valid CVC" : null,
              ),
              SizedBox(height: 24),

            ],
          ),
        ),
      ),
    );
  }
}

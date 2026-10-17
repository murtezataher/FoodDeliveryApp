import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<Map<String, dynamic>> faqCategories = [
    {
      "title": "Ordering",
      "faqs": [
        {"question": "How do I place an order?", "answer": "Select items, add to cart, and checkout."},
        {"question": "Can I schedule an order?", "answer": "Yes, you can schedule orders for later delivery."},
      ],
    },
    {
      "title": "Payment",
      "faqs": [
        {"question": "What payment methods are accepted?", "answer": "We accept cash, credit/debit cards, and online wallets."},
        {"question": "Is my payment information secure?", "answer": "Yes, all payments are encrypted and secure."},
      ],
    },
    {
      "title": "Delivery",
      "faqs": [
        {"question": "How do I track my order?", "answer": "Use the tracking link provided in your order details."},
        {"question": "What if my order is late?", "answer": "Contact support via the app for assistance."},
      ],
    },
    {
      "title": "Account",
      "faqs": [
        {"question": "How do I reset my password?", "answer": "Go to login, tap 'Forgot Password,' and follow the instructions."},
        {"question": "Can I update my address?", "answer": "Yes, you can update your address in the account settings."},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: faqCategories.length,
        itemBuilder: (context, index) {
          return FAQBox(
            title: faqCategories[index]['title'],
            faqs: faqCategories[index]['faqs'],
          );
        },
      ),
    );
  }
}

class FAQBox extends StatefulWidget {
  final String title;
  final List<Map<String, String>> faqs;

  const FAQBox({Key? key, required this.title, required this.faqs}) : super(key: key);

  @override
  _FAQBoxState createState() => _FAQBoxState();
}

class _FAQBoxState extends State<FAQBox> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
        onExpansionChanged: (expanded) {
          setState(() {
            isExpanded = expanded;
          });
        },
        children: widget.faqs.map((faq) {
          return ListTile(
            title: Text(
              faq['question']!,
              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.orangeAccent),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(faq['answer']!),
            ),
          );
        }).toList(),
      ),
    );
  }
}

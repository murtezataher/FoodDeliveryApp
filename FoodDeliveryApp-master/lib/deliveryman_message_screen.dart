import 'package:flutter/material.dart';

class DeliveryManMessageScreen extends StatefulWidget {
  @override
  _DeliveryManMessageScreenState createState() =>
      _DeliveryManMessageScreenState();
}

class _DeliveryManMessageScreenState extends State<DeliveryManMessageScreen> {
  final TextEditingController _controller = TextEditingController();

  // List to store messages dynamically
  List<Map<String, dynamic>> _messages = [

    {'text': 'Hey, congratulations on the order!', 'isSender': false},
  ];

  void _sendMessage() {
    String message = _controller.text.trim();

    if (message.isNotEmpty) {
      setState(() {
        _messages.add({'text': message, 'isSender': true});
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Robert Fox'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(
                  _messages[index]['text'],
                  _messages[index]['isSender'],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Write something...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send, color: Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isSender) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSender ? Colors.orange : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isSender ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

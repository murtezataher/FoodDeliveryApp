import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class PersonalInfoScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const PersonalInfoScreen({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Personal Info',
          style: TextStyle(
            color: Color(0xFFB6B6B6),
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
            child: const Text(
              'EDIT',
              style: TextStyle(
                color: Color(0xFFFF7643),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFFFE0E0),
            ),
            const SizedBox(height: 16),
            Text(
              userData?['name'] ?? 'N/A',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userData?['bio'] ?? 'I love fast food',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB6B6B6),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    iconColor: Colors.deepOrange,
                    label: 'FULL NAME',
                    value: userData?['name'] ?? 'N/A',
                  ),
                  const Divider(height: 32, color: Color(0xFFE0E0E0)),
                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    iconColor: Colors.deepPurple,
                    label: 'EMAIL',
                    value: userData?['email'] ?? 'N/A',
                  ),
                  const Divider(height: 32, color: Color(0xFFE0E0E0)),
                  _buildInfoRow(
                    icon: Icons.phone_outlined,
                    iconColor: Colors.blue,
                    label: 'PHONE NUMBER',
                    value: userData?['phone_number'] ?? 'N/A',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value,Color iconColor = Colors.black}) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFB6B6B6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

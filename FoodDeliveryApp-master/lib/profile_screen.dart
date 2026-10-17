import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodapp/customer_notification_screen.dart';
import 'package:foodapp/customer_reviews_screen.dart';
import 'package:foodapp/faq_screen.dart';
import 'package:foodapp/favorites_screen.dart';
import 'package:foodapp/mycart_screen.dart';
import 'package:foodapp/profile_payment_method_screen.dart';
import 'myorders_screen.dart';
import 'signin.dart';
import 'personal_info_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('customers').doc(uid).get();
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error during logout. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.orangeAccent,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            userData?['name'] ?? 'User Name',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),
          _buildSection(
            title: 'Profile Options',
            options: [
              _buildOption(
                context,
                title: 'Personal Info',
                icon: Icons.person,
                iconColor: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PersonalInfoScreen(userData: userData)),
                ),
              ),
              _buildOption(
                context,
                title: 'My Orders',
                icon: Icons.shopping_cart,
                iconColor: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  MyOrdersScreen()),
                ),

              ),

            ],
          ),
      _buildSection(
        title: 'new',
        options: [
         SizedBox(height: 20),
          _buildSection(
            title: 'More Options',
            options: [
              _buildOption(
                context,
                title: 'Cart',
                icon: Icons.shopping_bag,
                iconColor: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyCartScreen()),
                  );
                },
              ),
              _buildOption(
                context,
                title: 'Favourite',
                icon: Icons.favorite,
                iconColor: Colors.red,
                onTap: () { Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesScreen()),
                );},
              ),
              _buildOption(
                context,
                title: 'Notifications',
                icon: Icons.notifications,
                iconColor: Colors.purple,
                onTap: () { Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerNotificationScreen()),
                );},
              ),
              _buildOption(
                context,
                title: 'Payment Method',
                icon: Icons.payment,
                iconColor: Colors.teal,
                onTap: () {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePaymentMethodScreen()),
                );},
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Settings',
            options: [
              _buildOption(
                context,
                title: 'FAQs',
                icon: Icons.help,
                iconColor: Colors.cyan,
                onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => FAQScreen()));},
              ),
              _buildOption(
                context,
                title: 'User Reviews',
                icon: Icons.star,
                iconColor: Colors.amber,
                onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerReviewsScreen(customerId: uid)));},
              ),

            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Log Out'),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () => _logout(context),
          ),
        ],
      ),
    ],));
  }

  Widget _buildSection({required String title, required List<Widget> options}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: options,
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
        Color iconColor = Colors.black,
      }) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon, color: iconColor),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }
}

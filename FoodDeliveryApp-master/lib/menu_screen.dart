import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/chefprofile_screen.dart';
import 'package:foodapp/review_screen.dart';
import 'package:foodapp/signin_chef_screen.dart';
import 'package:foodapp/withdraw_successful_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileBalance(context),
          const Divider(),
          _buildMenuOption(Icons.person, 'Personal Info', Colors.deepPurple,() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChefProfileScreen()),
            );
          }),
          _buildMenuOption(Icons.star, 'User Reviews',Colors.orangeAccent, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReviewScreen()),
            );
          }),
          _buildMenuOption(Icons.delivery_dining, 'Delivery Fee',Colors.green, () {
            _showDeliveryFeeBottomSheet(context);
          }),
          _buildMenuOption(Icons.access_time, 'Delivery Time',Colors.blue, () {
            _showDeliveryTimeBottomSheet(context);
          }),
          _buildMenuOption(Icons.category, 'Restaurant Categories',Colors.red, () {
            _showRestaurantCategoriesBottomSheet(context);
          }),
          _buildMenuOption(Icons.description, 'Add Description',Colors.deepOrange, () {
            _showDescriptionBottomSheet(context);
          }),
          _buildMenuOption(Icons.logout, 'Log Out',Colors.red, () {
            _logOut(context);
          }),
        ],
      ),
    );
  }

  Future<void> _logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInChefScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  void _showDeliveryFeeBottomSheet(BuildContext context) {
    final TextEditingController _feeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter Delivery Fee',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Fee',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    String fee = _feeController.text.trim();
                    if (fee.isNotEmpty) {
                      try {
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        await FirebaseFirestore.instance
                            .collection('chefs')
                            .doc(uid)
                            .update({'delivery_fee': double.parse(fee)});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Delivery fee updated successfully')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating fee: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid amount')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeliveryTimeBottomSheet(BuildContext context) {
    final TextEditingController _timeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter Delivery Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Time (e.g., 30-45 mins)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    String time = _timeController.text.trim();
                    if (time.isNotEmpty) {
                      try {
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        await FirebaseFirestore.instance
                            .collection('chefs')
                            .doc(uid)
                            .update({'delivery_time': time});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Delivery time updated successfully')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating time: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid time')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRestaurantCategoriesBottomSheet(BuildContext context) {
    final TextEditingController _category1Controller = TextEditingController();
    final TextEditingController _category2Controller = TextEditingController();
    final TextEditingController _category3Controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter Restaurant Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _category1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Category 1',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _category2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Category 2',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _category3Controller,
                  decoration: const InputDecoration(
                    labelText: 'Category 3',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    String category1 = _category1Controller.text.trim();
                    String category2 = _category2Controller.text.trim();
                    String category3 = _category3Controller.text.trim();

                    if (category1.isNotEmpty ||
                        category2.isNotEmpty ||
                        category3.isNotEmpty) {
                      try {
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        await FirebaseFirestore.instance
                            .collection('chefs')
                            .doc(uid)
                            .update({
                          'categories': [
                            category1,
                            category2,
                            category3
                          ].where((category) => category.isNotEmpty).toList(),
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Categories updated successfully')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating categories: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter at least one category')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDescriptionBottomSheet(BuildContext context) {
    final TextEditingController _descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter a description for your restaurant...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    String description = _descriptionController.text.trim();
                    if (description.isNotEmpty) {
                      try {
                        String uid = FirebaseAuth.instance.currentUser!.uid;
                        await FirebaseFirestore.instance
                            .collection('chefs')
                            .doc(uid)
                            .update({'description': description});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Description updated successfully')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating description: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a valid description')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileBalance(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('chefs')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching data'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No data found'));
        }

        var chefData = snapshot.data!;
        double balance = chefData['income'] ?? 0.0;

        return Card(
          color: Colors.orange,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Available Balance', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  '\PKR ${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _withdrawBalance(context, balance);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text('Withdraw', style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _withdrawBalance(BuildContext context, double balance) async {
    if (balance > 0) {
      try {
        String uid = FirebaseAuth.instance.currentUser!.uid;

        // Perform withdrawal and reset balance to 0
        await FirebaseFirestore.instance
            .collection('chefs')
            .doc(uid)
            .update({'income': 0.0});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal successful')),
        );

        // After withdrawal, navigate to WithdrawSuccessfulScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WithdrawSuccessfulScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing withdrawal: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No balance to withdraw')),
      );
    }
  }



  Widget _buildMenuOption(IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }}

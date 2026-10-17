import 'package:flutter/material.dart';
import 'package:foodapp/notification_screen.dart';
import 'seller_dashboard_screen.dart';
import 'running_orders_screen.dart';
import 'myfood_screen.dart';
import 'addnewitem_screen.dart';
import 'menu_screen.dart';
class BottomNavBarScreen extends StatefulWidget {
  const BottomNavBarScreen({super.key});

  @override
  State<BottomNavBarScreen> createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SellerDashboardScreen(),
     NotificationScreen(),
    const MyFoodScreen(),
    const AddNewItemScreen(),
    const MenuScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _screens[_selectedIndex], // Display screen based on the selected index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard,color: Colors.orangeAccent,),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications,color: Colors.orangeAccent,),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank,color: Colors.orangeAccent,),
            label: 'My Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add,color: Colors.orangeAccent,),
            label: 'Add Item',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu,color: Colors.orangeAccent,),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_screen.dart';
import 'mycart_screen.dart';
import 'profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _restaurants = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = true;
  String _userAddress = 'Fetching address...';

  @override
  void initState() {
    super.initState();
    _fetchRestaurantsFromFirestore();
    _fetchUserAddress();
  }

  Future<void> _fetchRestaurantsFromFirestore() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('chefs').get();
      final List<Map<String, dynamic>> loadedRestaurants = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'restaurant_name': data['restaurant_name'] ?? 'Unknown Restaurant',
          'categories': List<String>.from(data['categories'] ?? []),
          'rating': data['rating'] ?? 0.0,
          'deliveryFee': data['delivery_fee'] ?? 'Unavailable',
          'time': data['delivery_time'] ?? 'Unavailable',
          'image_url': data['image_url'] ?? 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
        };
      }).toList();

      setState(() {
        _restaurants.addAll(loadedRestaurants);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching restaurants: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserAddress() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('customers').doc(user.uid).get();
        setState(() {
          _userAddress = doc.data()?['address'] ?? 'Address not available';
        });
      }
    } catch (e) {
      print('Error fetching user address: $e');
      setState(() {
        _userAddress = 'Error fetching address';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredRestaurants = _restaurants.where((restaurant) {
      final matchesCategory = _selectedCategory == 'all' || restaurant['categories'].any((category) => category.toLowerCase() == _selectedCategory);
      final matchesSearch = restaurant['restaurant_name'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.black),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                  },
                ),
                Spacer(),
                Text(
                  'Deliver to:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.orangeAccent),
                ),
                const SizedBox(height: 4),
                Text(
                  _userAddress,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Spacer(),
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.black),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyCartScreen()));
                  },
                ),
              ],
            ),


            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search restaurants',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Categories:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryChip(
                    label: 'All',
                    isSelected: _selectedCategory == 'all',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'all';
                      });
                    },
                  ),
                  CategoryChip(
                    label: 'Karahi',
                    isSelected: _selectedCategory == 'karahi',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'karahi';
                      });
                    },
                  ),
                  CategoryChip(
                    label: 'Burger',
                    isSelected: _selectedCategory == 'burger',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'burger';
                      });
                    },
                  ),
                  CategoryChip(
                    label: 'Ice Cream',
                    isSelected: _selectedCategory == 'ice cream',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'ice cream';
                      });
                    },
                  ),
                  CategoryChip(
                    label: 'Pizza',
                    isSelected: _selectedCategory == 'pizza',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'pizza';
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = filteredRestaurants[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantScreen(restaurantId: restaurant['uid']),
                        ),
                      );
                    },
                    child: RestaurantCard(restaurant: restaurant),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Chip(
          label: Text(label),
          backgroundColor: isSelected ? Colors.orangeAccent : Colors.grey.shade200,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          restaurant['image_url'] != null && restaurant['image_url'].isNotEmpty
              ? Image.network(
            restaurant['image_url'],
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          )
              : Image.network(
            'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant['restaurant_name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant['categories'] != null && restaurant['categories'].isNotEmpty
                      ? restaurant['categories'].join(', ')
                      : 'No categories available',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    SizedBox(width: 4),
                    Text(
                      '${restaurant['rating']}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.delivery_dining, size: 20,color:  Colors.orangeAccent,),
                    SizedBox(width: 4),
                    Text(
                      '${restaurant['deliveryFee']}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.timelapse_outlined, size: 20,color: Colors.orangeAccent,),
                    SizedBox(width: 4),
                    Text(
                      restaurant['time'] != 'Unavailable'
                          ? '${restaurant['time']} mins'
                          : '${restaurant['time']}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DefaultScreen extends StatelessWidget {
  final String restaurantName;

  const DefaultScreen(this.restaurantName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(restaurantName)),
      body: Center(child: Text('Screen for $restaurantName is not implemented yet.')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restaurant_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteRestaurants();
  }

  Future<void> _fetchFavoriteRestaurants() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Fetch favorites from the user's favorites subcollection
      final favoritesSnapshot = await _firestore
          .collection('customers')
          .doc(user.uid)
          .collection('favorites')
          .get();

      final List<String> restaurantIds = favoritesSnapshot.docs
          .map((doc) => doc['restaurantId'] as String)
          .toList();

      if (restaurantIds.isEmpty) {
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch restaurant details from the chefs collection
      final querySnapshot = await _firestore
          .collection('chefs')
          .where(FieldPath.documentId, whereIn: restaurantIds)
          .get();

      final List<Map<String, dynamic>> loadedFavorites = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'restaurant_name': data['restaurant_name'] ?? 'Unknown Restaurant',
          'categories': List<String>.from(data['categories'] ?? []),
          'rating': data['rating'] ?? 0.0,
          'deliveryFee': data['delivery_fee'] ?? 'Unavailable',
          'time': data['delivery_time'] ?? 'Unavailable',
          'image_url': data['image_url'] ??
              'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
        };
      }).toList();

      setState(() {
        _favorites = loadedFavorites;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching favorites: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFromFavorites(String restaurantId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Remove the favorite restaurant from Firestore
      final favoritesRef = _firestore
          .collection('customers')
          .doc(user.uid)
          .collection('favorites');

      final querySnapshot = await favoritesRef
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      for (var doc in querySnapshot.docs) {
        await favoritesRef.doc(doc.id).delete();
      }

      setState(() {
        _favorites.removeWhere((restaurant) => restaurant['uid'] == restaurantId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from favorites')),
      );
    } catch (e) {
      print('Error removing favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove favorite')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? const Center(child: Text('No favorites added yet.'))
          : ListView.builder(
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final restaurant = _favorites[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RestaurantScreen(restaurantId: restaurant['uid']),
                ),
              );
            },
            child: RestaurantCard(
              restaurant: restaurant,
              onRemoveFavorite: () => _removeFromFavorites(restaurant['uid']),
            ),
          );
        },
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onRemoveFavorite;

  const RestaurantCard({
    required this.restaurant,
    required this.onRemoveFavorite,
  });

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        restaurant['restaurant_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.orangeAccent),
                      onPressed: onRemoveFavorite,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant['categories'] != null && restaurant['categories'].isNotEmpty
                      ? restaurant['categories'].join(', ')
                      : 'No categories available',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orangeAccent, size: 20),
                    const SizedBox(width: 4),
                    Text('${restaurant['rating']}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 16),
                    const Icon(Icons.delivery_dining, size: 20, color: Colors.orangeAccent),
                    const SizedBox(width: 4),
                    Text('${restaurant['deliveryFee']}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 16),
                    const Icon(Icons.timelapse_outlined, size: 20, color: Colors.orangeAccent),
                    const SizedBox(width: 4),
                    Text(
                      restaurant['time'] != 'Unavailable'
                          ? '${restaurant['time']} mins'
                          : '${restaurant['time']}',
                      style: const TextStyle(fontSize: 14),
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

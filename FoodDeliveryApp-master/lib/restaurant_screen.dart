import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_provider.dart';
import 'package:provider/provider.dart';

class RestaurantScreen extends StatefulWidget {
  final String restaurantId;

  RestaurantScreen({required this.restaurantId});

  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  String selectedCategory = 'All'; // Default category to "All"
  bool isFavorite = false;
  bool showRatingBox = false; // Controls visibility of the rating box
  int selectedRating = 0; // Keeps track of selected stars
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    String customerId = FirebaseAuth.instance.currentUser!.uid;
    final favoriteDoc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .collection('favorites')
        .doc(widget.restaurantId)
        .get();

    setState(() {
      isFavorite = favoriteDoc.exists;
    });
  }

  Future<void> _toggleFavorite() async {
    String customerId = FirebaseAuth.instance.currentUser!.uid;
    final favoriteCollection = FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .collection('favorites');

    if (isFavorite) {
      await favoriteCollection.doc(widget.restaurantId).delete();
    } else {
      await favoriteCollection.doc(widget.restaurantId).set({
        'restaurantId': widget.restaurantId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> _submitRatingAndReview() async {
    if (selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a rating.')),
      );
      return;
    }

    String customerId = FirebaseAuth.instance.currentUser!.uid;
    String review = _reviewController.text.trim();

    // Add rating to chef's subcollection
    final chefRatingsCollection = FirebaseFirestore.instance
        .collection('chefs')
        .doc(widget.restaurantId)
        .collection('ratings');

    await chefRatingsCollection.add({
      'rating': selectedRating,
      'customerId': customerId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update overall rating in chef's document
    final chefDoc = FirebaseFirestore.instance.collection('chefs').doc(widget.restaurantId);
    final ratingsSnapshot = await chefRatingsCollection.get();
    int totalRatings = 0;
    int numberOfRatings = ratingsSnapshot.docs.length;

    for (var doc in ratingsSnapshot.docs) {
      totalRatings += (doc['rating'] as num).toInt();

    }

    double newRating = totalRatings / numberOfRatings;

    await chefDoc.update({
      'rating': newRating,
    });

    // Add review to customer's subcollection
    final customerReviewsCollection = FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .collection('reviews');

    await customerReviewsCollection.add({
      'restaurantId': widget.restaurantId,
      'review': review,
      'rating': selectedRating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Add review to restaurant's subcollection
    final restaurantReviewsCollection = FirebaseFirestore.instance
        .collection('chefs')
        .doc(widget.restaurantId)
        .collection('reviews');

    await restaurantReviewsCollection.add({
      'customerId': customerId,
      'review': review,
      'rating': selectedRating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      showRatingBox = false;
      selectedRating = 0;
      _reviewController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thank you for your feedback!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('chefs').doc(widget.restaurantId).get(),
      builder: (context, chefSnapshot) {
        if (chefSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Loading...')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!chefSnapshot.hasData || !chefSnapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: Text('Restaurant Not Found')),
            body: Center(child: Text('This restaurant does not exist.')),
          );
        }

        final chefData = chefSnapshot.data!;
        final restaurantName = chefData['restaurant_name'] ?? 'Unknown Restaurant';
        final restaurantImage = chefData['image_url'] ?? 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png';
        final rating = chefData['rating'] ?? 0.0;
        final deliveryFee = chefData['delivery_fee'] ?? 0;
        final deliveryTime = chefData['delivery_time'] ?? 'N/A';
        final description = chefData['description'] ?? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.grey),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Restaurant View',
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.orangeAccent,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Restaurant Header Section
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            restaurantImage,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          restaurantName,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.orange, size: 18),
                                SizedBox(width: 4),
                                Text('$rating'.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(width: 40),
                                Icon(Icons.delivery_dining_rounded, color: Colors.orangeAccent),
                                SizedBox(width: 4),
                                Text(deliveryFee.toString(), style: TextStyle(color: Colors.grey)),
                                SizedBox(width: 40),
                                Icon(Icons.timelapse_outlined, color: Colors.orangeAccent),
                                SizedBox(width: 4),
                                Text(deliveryTime.toString(), style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            /*Row(
                              children: [
                                Icon(Icons.delivery_dining_rounded, color: Colors.orangeAccent),
                                Text(deliveryFee.toString(), style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.timelapse_outlined, color: Colors.orangeAccent),
                                Text(deliveryTime.toString(), style: TextStyle(color: Colors.grey)),
                              ],
                            ),*/
                          ],
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showRatingBox = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text('Rate and Review',style: TextStyle(fontSize: 18,color: Colors.white),),
                        ),
                      ],
                    ),
                  ),

                  // Rating Box
                  if (showRatingBox)
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rate this Restaurant',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    showRatingBox = false;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  Icons.star,
                                  color: selectedRating > index ? Colors.orange : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    selectedRating = index + 1;
                                  });
                                },
                              );
                            }),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _reviewController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Write your review...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _submitRatingAndReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text('Submit',style: TextStyle(fontSize: 18,color: Colors.white),),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 16),

                  // Categories Section (unchanged)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('All'),
                        _buildCategoryChip('Burger'),
                        _buildCategoryChip('Sandwich'),
                        _buildCategoryChip('Pizza'),
                        _buildCategoryChip('Drinks'),
                        _buildCategoryChip('Ice cream'),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Food Items Section (unchanged)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chefs')
                        .doc(widget.restaurantId)
                        .collection('chef_food_items')
                        .snapshots(),
                    builder: (context, foodSnapshot) {
                      if (foodSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!foodSnapshot.hasData || foodSnapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No food items available.'));
                      }

                      final foodItems = foodSnapshot.data!.docs.where((doc) {
                        if (selectedCategory == 'All') return true;
                        return doc['category'].toString().toLowerCase() == selectedCategory.toLowerCase();
                      }).map((doc) {
                        return {
                          'id': doc.id,
                          'name': doc['name'] ?? 'Unknown Dish',
                          'price': doc['price'] ?? 0,
                          'image_url': doc['image_url'] ??
                              'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
                          'availability': doc['availability'] ?? true,
                        };
                      }).toList();

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: foodItems.length,
                        itemBuilder: (context, index) {
                          return BurgerCard(
                            id: foodItems[index]['id'],
                            name: foodItems[index]['name'],
                            price: foodItems[index]['price'],
                            imageUrl: foodItems[index]['image_url'],
                            restaurantId: widget.restaurantId,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = selectedCategory == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Chip(
          label: Text(label),
          backgroundColor: isSelected ? Colors.orange : Colors.grey[200],
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class BurgerCard extends StatelessWidget {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String restaurantId;

  BurgerCard({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, height: 100, width: double.infinity, fit: BoxFit.cover),
            ),
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\PKR ${price.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailsScreen(
                            id: id,
                            name: name,
                            price: price,
                            imageUrl: imageUrl,
                            restaurantId: restaurantId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class FoodDetailsScreen extends StatefulWidget {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String restaurantId;

  FoodDetailsScreen({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.restaurantId,
  });

  @override
  _FoodDetailsScreenState createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  String _selectedSize = 'Regular'; // Default size
  String _description = 'Loading...'; // Placeholder for description

  @override
  void initState() {
    super.initState();
    _fetchFoodDetails();
  }

  Future<void> _fetchFoodDetails() async {
    try {
      // Access the chef's subcollection `chef_food_items` using the `restaurantId` and `id`.
      DocumentSnapshot foodDoc = await FirebaseFirestore.instance
          .collection('chefs') // Collection for chefs
          .doc(widget.restaurantId) // Chef's unique ID
          .collection('chef_food_items') // Subcollection for chef's food items
          .doc(widget.id) // Specific food item ID
          .get();

      if (foodDoc.exists) {
        setState(() {
          _description = foodDoc.get('description') ?? 'No description available';
        });
      } else {
        setState(() {
          _description = 'Food details not found.';
        });
      }
    } catch (e) {
      setState(() {
        _description = 'Failed to load description.';
      });
      print('Error fetching food details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),


            SizedBox(height: 16),
            Text(
              _description,
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                _buildSizeChip(context, '10"'),
                SizedBox(width: 8),
                _buildSizeChip(context, '14"'),
                SizedBox(width: 8),
                _buildSizeChip(context, '16"'),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\PKR ${widget.price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        int currentQuantity = cart.getItemQuantity(widget.name, _selectedSize);
                        if (currentQuantity > 0) {
                          cart.updateItemQuantity(widget.name, _selectedSize, currentQuantity - 1);
                        }
                      },
                    ),
                    Text(
                      cart.getItemQuantity(widget.name, _selectedSize).toString(),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () {
                        cart.addItem(
                          name: widget.name,
                          price: widget.price,
                          size: _selectedSize,
                          restaurantId: widget.restaurantId,
                          imageUrl: widget.imageUrl,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                cart.addItem(
                  name: widget.name,
                  price: widget.price,
                  size: _selectedSize,
                  restaurantId: widget.restaurantId,
                  imageUrl: widget.imageUrl,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${widget.name} added to the cart")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'ADD TO CART',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeChip(BuildContext context, String size) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSize = size; // Update the selected size
        });
      },
      child: Chip(
        label: Text(size),
        backgroundColor: _selectedSize == size ? Colors.orange : Colors.grey[200],
        labelStyle: TextStyle(
          color: _selectedSize == size ? Colors.white : Colors.black,
        ),
      ),
    );
  }
  }
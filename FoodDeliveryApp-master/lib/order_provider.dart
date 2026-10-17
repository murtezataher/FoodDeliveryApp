import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  String _restaurantName = '';
  String _estimatedTime = '';

  String get restaurantName => _restaurantName;
  String get estimatedTime => _estimatedTime;

  void setRestaurantName(String name) {
    _restaurantName = name;
    notifyListeners(); // Notify UI updates
  }

  void setEstimatedTime(String time) {
    _estimatedTime = time;
    notifyListeners(); // Notify UI updates
  }
}

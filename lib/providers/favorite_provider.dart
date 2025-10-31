import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class FavoriteProvider with ChangeNotifier {
  List<String> _favorites = [];

  List<String> get favorites => _favorites;

  Future<void> fetchFavorites() async {
    _favorites = await FirebaseService.getFavorites();
    notifyListeners();
  }

  bool isFavorite(String cakeId) => _favorites.contains(cakeId);

  Future<void> toggleFavorite(String cakeId) async {
    await FirebaseService.toggleFavorite(cakeId);
    await fetchFavorites();
  }
}

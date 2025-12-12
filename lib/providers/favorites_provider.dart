import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  List<String> favoriteSongs = [];

  bool isFavorite(String path) {
    return favoriteSongs.contains(path);
  }

  void toggleFavorite(String path) {
    if (isFavorite(path)) {
      favoriteSongs.remove(path);
    } else {
      favoriteSongs.add(path);
    }
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class Cake {
  final String id;
  final String name;
  final String description;
  final String image;
  final Color color;
  final int price;
  final String category;
  final bool isAvailable;

  Cake({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.color,
    required this.price,
    required this.category,
    required this.isAvailable,
  });

  factory Cake.fromJson(Map<String, dynamic> json) {
    return Cake(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      color: _parseColor(json['color']),
      price: json['price'],
      category: json['category'],
      isAvailable: json['is_available'] ?? true,
    );
  }

  static Color _parseColor(String color) {
    String hex = color.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse('0x$hex'));
  }
}

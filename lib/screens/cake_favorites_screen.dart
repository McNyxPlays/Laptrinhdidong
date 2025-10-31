import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cake.dart';
import '../services/firebase_service.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FavoriteProvider>(context);
    final cp = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Yêu thích')),
      body: FutureBuilder<List<Cake>>(
        future: _getFavoriteCakes(fp.favorites),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          final cakes = snapshot.data ?? [];
          if (cakes.isEmpty)
            return Center(child: Text('Chưa có bánh yêu thích'));
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
            ),
            itemCount: cakes.length,
            itemBuilder: (context, index) {
              final cake = cakes[index];
              final isFavorite = true;
              return GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/details',
                  arguments: cake.id,
                ),
                child: Card(
                  color: cake.color,
                  child: Column(
                    children: [
                      Image.network(cake.image, height: 120, fit: BoxFit.cover),
                      Text(cake.name),
                      Text('${cake.price} VNĐ'),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.add_shopping_cart),
                            onPressed: () async =>
                                await cp.addToCart(cake.id, 'Nhỏ', 1),
                          ),
                          IconButton(
                            icon: Icon(Icons.favorite, color: Colors.red),
                            onPressed: () async =>
                                await fp.toggleFavorite(cake.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Cake>> _getFavoriteCakes(List<String> ids) async {
    List<Cake> cakes = [];
    for (var id in ids) {
      cakes.add(await FirebaseService.getCakeById(id));
    }
    return cakes;
  }
}

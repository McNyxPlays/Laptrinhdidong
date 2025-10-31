import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cake.dart';
import '../services/firebase_service.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class CakeDetailsScreen extends StatefulWidget {
  @override
  _CakeDetailsScreenState createState() => _CakeDetailsScreenState();
}

class _CakeDetailsScreenState extends State<CakeDetailsScreen> {
  String _selectedSize = 'Nhỏ';
  final Map<String, double> _sizeMultipliers = {
    'Nhỏ': 1.0,
    'Trung bình': 1.5,
    'Lớn': 2.0,
  };
  final Map<String, String> _sizeDescriptions = {
    'Nhỏ': '15cm',
    'Trung bình': '20cm',
    'Lớn': '25cm',
  };

  @override
  Widget build(BuildContext context) {
    final cakeId = ModalRoute.of(context)!.settings.arguments as String;
    final fp = Provider.of<FavoriteProvider>(context);
    final cp = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: FutureBuilder<Cake>(
        future: FirebaseService.getCakeById(cakeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          final cake = snapshot.data!;
          final adjustedPrice = (cake.price * _sizeMultipliers[_selectedSize]!)
              .toInt();
          final isFavorite = fp.isFavorite(cake.id);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(cake.name),
                  background: Hero(
                    tag: 'cake-${cake.id}',
                    child: CachedNetworkImage(
                      imageUrl: cake.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cake.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (auth.user != null)
                            IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : null,
                              ),
                              onPressed: () async =>
                                  await fp.toggleFavorite(cake.id),
                            ),
                        ],
                      ),
                      Text('Danh mục: ${cake.category}'),
                      Text(
                        'Trạng thái: ${cake.isAvailable ? 'Có sẵn' : 'Hết hàng'}',
                        style: TextStyle(
                          color: cake.isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Mô tả: ${cake.description}'),
                      SizedBox(height: 16),
                      Text('Kích thước:'),
                      DropdownButton<String>(
                        value: _selectedSize,
                        items: _sizeMultipliers.keys
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text('$s (${_sizeDescriptions[s]})'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedSize = v!),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '$adjustedPrice VNĐ',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 24),
                      if (cake.isAvailable)
                        ElevatedButton.icon(
                          icon: Icon(Icons.add_shopping_cart),
                          label: Text('Thêm vào giỏ hàng'),
                          onPressed: () async {
                            await cp.addToCart(cake.id, _selectedSize, 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã thêm ${cake.name} ($_selectedSize)',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

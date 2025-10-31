import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cake.dart';
import '../services/firebase_service.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class CakeListScreen extends StatefulWidget {
  @override
  _CakeListScreenState createState() => _CakeListScreenState();
}

class _CakeListScreenState extends State<CakeListScreen> {
  late Future<List<Cake>> _cakesFuture;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _sortPriceAsc = true;

  @override
  void initState() {
    super.initState();
    _cakesFuture = FirebaseService.getCakes();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
      Provider.of<CartProvider>(context, listen: false).fetchCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cửa Hàng Bánh Kem'),
        backgroundColor: Colors.pink,
      ),
      drawer: _buildDrawer(context, authProvider),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFC0CB), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bánh...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip('All'),
                          _buildCategoryChip('Socola'),
                          _buildCategoryChip('Dâu'),
                          _buildCategoryChip('Vani'),
                          _buildCategoryChip('Matcha'),
                          _buildCategoryChip('Tiramisu'),
                          _buildCategoryChip('Chanh Leo'),
                          _buildCategoryChip('Red Velvet'),
                          _buildCategoryChip('Caramen'),
                          _buildCategoryChip('Trái Cây'),
                          _buildCategoryChip('Bắp'),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _sortPriceAsc ? Icons.trending_up : Icons.trending_down,
                    ),
                    onPressed: () =>
                        setState(() => _sortPriceAsc = !_sortPriceAsc),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Cake>>(
                future: _cakesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  List<Cake> cakes = snapshot.data ?? [];
                  if (_selectedCategory != 'All')
                    cakes = cakes
                        .where((c) => c.category == _selectedCategory)
                        .toList();
                  if (_searchQuery.isNotEmpty)
                    cakes = cakes
                        .where(
                          (c) => c.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                        )
                        .toList();
                  cakes.sort(
                    (a, b) => _sortPriceAsc
                        ? a.price.compareTo(b.price)
                        : b.price.compareTo(a.price),
                  );
                  if (cakes.isEmpty)
                    return Center(child: Text('Không tìm thấy bánh nào'));
                  return GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: cakes.length,
                    itemBuilder: (context, index) {
                      final cake = cakes[index];
                      return _buildCakeCard(context, cake);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    bool selected = _selectedCategory == category;
    return Padding(
      padding: EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(category),
        selected: selected,
        onSelected: (_) => setState(() => _selectedCategory = category),
      ),
    );
  }

  Widget _buildCakeCard(BuildContext context, Cake cake) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/details', arguments: cake.id),
      child: Card(
        color: cake.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'cake-${cake.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: cake.image,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.cake, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Text(cake.name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${cake.price} VNĐ'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider auth) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.pink),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Trang chủ'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Yêu thích'),
            onTap: () {
              if (auth.user == null)
                Navigator.pushNamed(context, '/login');
              else
                Navigator.pushNamed(context, '/favorites');
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Giỏ hàng'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/cart');
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text(auth.user == null ? 'Đăng nhập' : 'Hồ sơ'),
            onTap: () => Navigator.pushNamed(
              context,
              auth.user == null ? '/login' : '/profile',
            ),
          ),
          if (auth.user != null)
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Lịch sử đơn hàng'),
              onTap: () => Navigator.pushNamed(context, '/orders'),
            ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text('Kiểm tra đơn hàng'),
            onTap: () => Navigator.pushNamed(context, '/order_status'),
          ),
        ],
      ),
    );
  }
}

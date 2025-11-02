// lib/screens/cake_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/cake.dart';
import '../services/firebase_service.dart';
import '../providers/favorite_provider.dart';
import '../providers/auth_provider.dart';
import 'admin_cake_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_order_management_screen.dart';

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
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
            // Tìm kiếm
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

            // Bộ lọc + sắp xếp
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: _buildCategoryChips()),
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

            // Danh sách bánh
            Expanded(
              child: FutureBuilder<List<Cake>>(
                future: _cakesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }

                  var cakes = snapshot.data ?? [];
                  if (_searchQuery.isNotEmpty) {
                    cakes = cakes
                        .where(
                          (c) => c.name.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          ),
                        )
                        .toList();
                  }
                  if (_selectedCategory != 'All') {
                    cakes = cakes
                        .where((c) => c.category == _selectedCategory)
                        .toList();
                  }
                  cakes.sort(
                    (a, b) => _sortPriceAsc
                        ? a.price.compareTo(b.price)
                        : b.price.compareTo(a.price),
                  );

                  if (cakes.isEmpty) {
                    return Center(child: Text('Không tìm thấy bánh'));
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: cakes.length,
                    itemBuilder: (context, index) {
                      final cake = cakes[index];
                      final isFavorite = favoriteProvider.isFavorite(cake.id);

                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/details',
                          arguments: cake.id,
                        ),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // Hình ảnh + tên
                              Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: cake.image,
                                      height: 130,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) =>
                                          Container(color: Colors.grey[200]),
                                      errorWidget: (_, __, ___) => Icon(
                                        Icons.cake,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      cake.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),

                              // Nút yêu thích (chỉ hiện khi đăng nhập)
                              if (authProvider.user != null)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.grey,
                                        size: 20,
                                      ),
                                      onPressed: () => favoriteProvider
                                          .toggleFavorite(cake.id),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
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

  // Danh sách chip loại bánh
  List<Widget> _buildCategoryChips() {
    final categories = [
      'All',
      'Socola',
      'Dâu',
      'Vani',
      'Matcha',
      'Tiramisu',
      'Chanh Leo',
      'Red Velvet',
      'Caramen',
      'Trái Cây',
      'Bắp',
    ];
    return categories
        .map(
          (cat) => Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat, style: TextStyle(fontSize: 13)),
              selected: _selectedCategory == cat,
              selectedColor: Colors.pink.shade100,
              checkmarkColor: Colors.pink,
              onSelected: (_) => setState(() => _selectedCategory = cat),
            ),
          ),
        )
        .toList();
  }

  // Drawer menu
  Widget _buildDrawer(BuildContext context, AuthProvider auth) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.pink),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          _drawerTile(Icons.home, 'Trang chủ', () => Navigator.pop(context)),
          _drawerTile(Icons.favorite, 'Yêu thích', () {
            if (auth.user == null)
              Navigator.pushNamed(context, '/login');
            else
              Navigator.pushNamed(context, '/favorites');
          }),
          _drawerTile(
            Icons.shopping_cart,
            'Giỏ hàng',
            () => Navigator.pushNamed(context, '/cart'),
          ),
          _drawerTile(
            Icons.account_circle,
            auth.user == null ? 'Đăng nhập' : 'Hồ sơ',
            () {
              Navigator.pushNamed(
                context,
                auth.user == null ? '/login' : '/profile',
              );
            },
          ),
          if (auth.user != null)
            _drawerTile(
              Icons.history,
              'Lịch sử đơn hàng',
              () => Navigator.pushNamed(context, '/orders'),
            ),
          _drawerTile(
            Icons.search,
            'Kiểm tra đơn hàng',
            () => Navigator.pushNamed(context, '/order_status'),
          ),
          if (auth.isAdmin) Divider(),
          if (auth.isAdmin) ...[
            _drawerTile(
              Icons.add,
              'Thêm sản phẩm',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminCakeScreen()),
              ),
            ),
            _drawerTile(
              Icons.bar_chart,
              'Biểu đồ doanh thu',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminDashboardScreen()),
              ),
            ),
            _drawerTile(
              Icons.list,
              'Quản lý đơn hàng',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminOrderManagementScreen()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}

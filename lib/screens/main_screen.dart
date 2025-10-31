// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'cake_list_screen.dart';
import 'cake_favorites_screen.dart';
import 'cake_cart_screen.dart';
import 'order_history_screen.dart';
import 'user_profile_screen.dart';
import 'admin_cake_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CakeListScreen(),
      FavoritesScreen(),
      CartScreen(),
      OrderHistoryScreen(),
      UserProfileScreen(),
    ];
  }

  void _onItemTapped(int index) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    if (user == null && index != 0) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    if (index == 4) {
      final profile = await auth.getUserRole();
      if (profile['role'] == 'admin') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminCakeScreen()),
        );
        return;
      }
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Đơn hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}

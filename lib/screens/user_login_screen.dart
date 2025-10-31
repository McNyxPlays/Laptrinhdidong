import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  void _login() async {
    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).login(_emailCtrl.text, _passwordCtrl.text);
      Provider.of<FavoriteProvider>(context, listen: false).fetchFavorites();
      Provider.of<CartProvider>(context, listen: false).fetchCart();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
            ),
            ElevatedButton(onPressed: _login, child: Text('Đăng nhập')),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('Đăng ký'),
            ),
          ],
        ),
      ),
    );
  }
}

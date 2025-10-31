import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../providers/auth_provider.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await FirebaseService.getProfile();
    _nameCtrl.text = data['name'] ?? '';
    _phoneCtrl.text = data['phone'] ?? '';
    _addressCtrl.text = data['address'] ?? '';
  }

  void _update() async {
    await FirebaseService.updateProfile({
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'address': _addressCtrl.text,
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Cập nhật thành công')));
  }

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hồ sơ')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: 'Họ tên'),
            ),
            TextField(
              controller: _phoneCtrl,
              decoration: InputDecoration(labelText: 'SĐT'),
            ),
            TextField(
              controller: _addressCtrl,
              decoration: InputDecoration(labelText: 'Địa chỉ'),
            ),
            ElevatedButton(onPressed: _update, child: Text('Cập nhật')),
            ElevatedButton(
              onPressed: _logout,
              child: Text('Đăng xuất'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

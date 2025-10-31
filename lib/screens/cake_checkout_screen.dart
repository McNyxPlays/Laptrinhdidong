// lib/screens/cake_checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // DÙNG ĐỂ COPY
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _payment = 'Tiền mặt';
  bool _done = false;
  String _orderId = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cp = Provider.of<CartProvider>(context);
    final isLoggedIn = auth.user != null;

    if (_done) {
      return Scaffold(
        appBar: AppBar(title: Text('Thanh toán')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon thành công
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, size: 60, color: Colors.white),
                ),
                SizedBox(height: 24),

                // Tiêu đề
                Text(
                  'Thành công!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Mã đơn hàng
                SelectableText(
                  'Mã đơn: $_orderId',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // NÚT SAO CHÉP MÃ
                ElevatedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _orderId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã sao chép mã đơn: $_orderId'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(Icons.copy, size: 20),
                  label: Text('Sao chép mã'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // NÚT VỀ TRANG CHỦ
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  icon: Icon(Icons.home, size: 20),
                  label: Text('Về trang chủ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán'), backgroundColor: Colors.pink),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isLoggedIn)
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Họ tên',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
                  ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _addressCtrl,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú (không bắt buộc)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _payment,
                  decoration: InputDecoration(
                    labelText: 'Phương thức thanh toán',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Tiền mặt',
                      child: Text('Thanh toán tiền mặt'),
                    ),
                    DropdownMenuItem(
                      value: 'Chuyển khoản',
                      child: Text('Chuyển khoản'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _payment = v!),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final name = isLoggedIn ? null : _nameCtrl.text;
                      _orderId = await FirebaseService.createOrder(
                        items: cp.items,
                        total: cp.total,
                        name: name,
                        address: _addressCtrl.text,
                        note: _noteCtrl.text,
                        paymentMethod: _payment,
                      );
                      cp.clear();
                      setState(() => _done = true);
                    }
                  },
                  child: Text('Hoàn tất đơn hàng'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: EdgeInsets.all(16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

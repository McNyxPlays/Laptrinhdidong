import 'package:flutter/material.dart';
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 100, color: Colors.green),
              Text('Thành công! Mã đơn: $_orderId'),
              ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!isLoggedIn)
                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(labelText: 'Họ tên'),
                  validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
                ),
              TextFormField(
                controller: _addressCtrl,
                decoration: InputDecoration(labelText: 'Địa chỉ'),
                validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
              ),
              TextFormField(
                controller: _noteCtrl,
                decoration: InputDecoration(labelText: 'Ghi chú'),
              ),
              DropdownButtonFormField<String>(
                value: _payment,
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
                child: Text('Hoàn tất'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

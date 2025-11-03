// lib/screens/cake_checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _phoneCtrl = TextEditingController(); // THÊM SĐT
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _payment = 'Tiền mặt';
  bool _done = false;
  String _orderId = '';
  bool _showTransferInfo = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // TỰ ĐỘNG ĐIỀN KHI MỞ
  }

  Future<void> _loadUserInfo() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      final profile = await FirebaseService.getProfile();
      _nameCtrl.text = profile['name'] ?? '';
      _phoneCtrl.text = profile['phone'] ?? ''; // LẤY SĐT
      _addressCtrl.text = profile['address'] ?? '';
    }
  }

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
                Text(
                  'Thành công!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                SelectableText(
                  'Mã đơn: $_orderId',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _orderId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã sao chép: $_orderId'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: Icon(Icons.copy),
                  label: Text('Sao chép mã'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  icon: Icon(Icons.home),
                  label: Text('Về trang chủ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
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
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
                  ),
                if (!isLoggedIn) SizedBox(height: 12),

                // SĐT - BẮT BUỘC DÙ ĐÃ LOGIN
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'SĐT phải có đúng 10 chữ số';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),

                // Địa chỉ
                TextFormField(
                  controller: _addressCtrl,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ giao hàng',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
                ),
                SizedBox(height: 12),

                TextFormField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú (không bắt buộc)',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _payment,
                  decoration: InputDecoration(
                    labelText: 'Phương thức thanh toán',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Tiền mặt',
                      child: Text('Thanh toán tiền mặt'),
                    ),
                    DropdownMenuItem(
                      value: 'Chuyển khoản',
                      child: Text('Chuyển khoản ngân hàng'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _payment = v!;
                      _showTransferInfo = v == 'Chuyển khoản';
                    });
                  },
                ),

                if (_showTransferInfo)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hướng dẫn chuyển khoản:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('• Ngân hàng: Vietcombank'),
                            Text('• Số TK: 1234567890'),
                            Text('• Tên TK: Cửa Hàng Bánh Kem'),
                            Text('• Nội dung: $_orderId (sau khi tạo đơn)'),
                            SizedBox(height: 8),
                            Text(
                              'Sau khi chuyển, quay lại app để hoàn tất.',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                        phone: _phoneCtrl.text,
                        note: _noteCtrl.text,
                        paymentMethod: _payment,
                      );
                      cp.clear();
                      setState(() => _done = true);
                    }
                  },
                  child: Text(
                    'Hoàn tất đơn hàng',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

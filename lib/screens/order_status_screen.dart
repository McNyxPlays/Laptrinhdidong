import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class OrderStatusScreen extends StatefulWidget {
  @override
  _OrderStatusScreenState createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  final _orderIdCtrl = TextEditingController();
  Map<String, dynamic>? _order;

  void _check() async {
    final data = await FirebaseService.getOrderById(_orderIdCtrl.text);
    setState(() => _order = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kiểm tra đơn hàng')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _orderIdCtrl,
              decoration: InputDecoration(labelText: 'Mã đơn hàng'),
            ),
            ElevatedButton(onPressed: _check, child: Text('Kiểm tra')),
            if (_order != null)
              Column(
                children: [
                  Text('Trạng thái: ${_order!['status']}'),
                  Text('Tổng: ${_order!['total']} VNĐ'),
                  // Add more details if needed
                ],
              ),
          ],
        ),
      ),
    );
  }
}

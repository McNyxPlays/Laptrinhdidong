import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class OrderHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lịch sử đơn hàng')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FirebaseService.getOrderHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) return Center(child: Text('Chưa có đơn hàng'));
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Mã đơn: ${order['orderId']}'),
                subtitle: Text(
                  'Tổng: ${order['total']} VNĐ - Trạng thái: ${order['status']}',
                ),
              );
            },
          );
        },
      ),
    );
  }
}

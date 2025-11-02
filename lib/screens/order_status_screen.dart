// lib/screens/order_status_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});
  @override
  _OrderStatusScreenState createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  final _orderIdCtrl = TextEditingController();
  Map<String, dynamic>? _order;
  bool _loading = false;

  void _check() async {
    final orderId = _orderIdCtrl.text.trim();
    if (orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã đơn hàng')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final data = await FirebaseService.getOrderById(orderId);
      if (data == null) throw Exception('Không tìm thấy đơn hàng');
      setState(() => _order = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tìm thấy đơn hàng: $orderId')),
      );
      setState(() => _order = null);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra đơn hàng'),
        backgroundColor: Colors.pink.shade50,
        foregroundColor: Colors.pink.shade900,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: false, // Ngăn resize khi keyboard lên
      body: SafeArea(
        child: SingleChildScrollView(
          // Cuộn để tránh bottom overflow
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Input
              TextField(
                controller: _orderIdCtrl,
                decoration: InputDecoration(
                  labelText: 'Mã đơn hàng',
                  hintText: 'Nhập mã đơn (ví dụ: abc123xyz)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.receipt, color: Colors.pink),
                  filled: true,
                  fillColor: Colors.pink.shade50,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _check(),
              ),
              const SizedBox(height: 16),

              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _check,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.search),
                  label: Text(
                    _loading ? 'Đang tìm kiếm...' : 'Kiểm tra đơn hàng',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Result
              if (_order != null)
                _buildOrderCard()
              else if (_orderIdCtrl.text.isNotEmpty && !_loading)
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Không tìm thấy đơn hàng',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mã đơn + Trạng thái (Sửa right overflow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Mã đơn: ${_order!['orderId']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Chip(
                  label: Text(
                    _order!['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _getStatusColor(_order!['status']),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),

            // Thông tin khách hàng
            _buildInfoRow(Icons.person, 'Khách hàng', _order!['name']),
            _buildInfoRow(
              Icons.location_on,
              'Địa chỉ giao',
              _order!['address'],
            ),
            if (_order!['note']?.toString().isNotEmpty == true)
              _buildInfoRow(Icons.note, 'Ghi chú', _order!['note']),
            _buildInfoRow(
              Icons.payment,
              'Thanh toán',
              _order!['paymentMethod'],
            ),
            _buildInfoRow(
              Icons.access_time,
              'Thời gian đặt',
              _formatTimestamp(_order!['timestamp']),
            ),

            SizedBox(height: 16),
            Text(
              'Chi tiết sản phẩm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Danh sách bánh
            ...(_order!['items'] as List)
                .map((item) => _buildCakeItem(item))
                .toList(),

            Divider(height: 24, thickness: 1),

            // Tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_order!['total']} VNĐ',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.pink),
          SizedBox(width: 10),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildCakeItem(Map<String, dynamic> item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: item['image'] ?? '',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[200]),
              errorWidget: (_, __, ___) =>
                  Icon(Icons.broken_image, color: Colors.red),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Bánh không tên',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  '${item['size']} • Số lượng: ${item['quantity']} • ${item['price']} VNĐ',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Text(
            '${item['subtotal']} VNĐ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Chưa xác định';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return 'Không xác định';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Confirmed':
        return Colors.blue;
      case 'Delivering':
        return Colors.purple;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

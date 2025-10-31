import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<CartProvider>(context, listen: false).fetchCart();
  }

  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<CartProvider>(context);
    final items = cp.items;
    final total = cp.total;

    if (items.isEmpty)
      return Scaffold(
        appBar: AppBar(title: Text('Giỏ hàng')),
        body: Center(child: Text('Giỏ hàng trống')),
      );

    return Scaffold(
      appBar: AppBar(title: Text('Giỏ hàng')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Image.network(
                    item['image'],
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text('${item['name']} (${item['size']})'),
                  subtitle: Text(
                    '${item['price']} VNĐ x ${item['quantity']} = ${item['subtotal']} VNĐ',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => cp.updateItem(
                          item['cakeId'],
                          item['size'],
                          item['quantity'] - 1,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => cp.updateItem(
                          item['cakeId'],
                          item['size'],
                          item['quantity'] + 1,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            cp.removeItem(item['cakeId'], item['size']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Tổng cộng: $total VNĐ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/checkout'),
                  child: Text('Thanh toán'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

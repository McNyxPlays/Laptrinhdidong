// lib/screens/admin_cake_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AdminCakeScreen extends StatefulWidget {
  @override
  _AdminCakeScreenState createState() => _AdminCakeScreenState();
}

class _AdminCakeScreenState extends State<AdminCakeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _category = 'Socola';
  bool _isAvailable = true;
  Color _color = Colors.pink[100]!;

  final List<String> _categories = [
    'Socola',
    'Dâu',
    'Vani',
    'Matcha',
    'Tiramisu',
    'Chanh Leo',
    'Red Velvet',
    'Caramen',
    'Trái Cây',
    'Bắp',
  ];

  Future<void> _addCake() async {
    if (!_formKey.currentState!.validate()) return;

    final id = Uuid().v4();
    final hexColor =
        '#${_color.value.toRadixString(16).substring(2).toUpperCase()}';

    await FirebaseFirestore.instance.collection('cakes').doc(id).set({
      'id': id,
      'name': _nameCtrl.text,
      'description': _descCtrl.text,
      'image': _imageCtrl.text,
      'color': hexColor,
      'price': int.parse(_priceCtrl.text),
      'category': _category,
      'is_available': _isAvailable,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thêm bánh thành công!'),
        duration: Duration(seconds: 2),
      ),
    );
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý bánh'), backgroundColor: Colors.pink),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Tên bánh *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: 'Mô tả *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _imageCtrl,
                decoration: InputDecoration(
                  labelText: 'URL ảnh *',
                  border: OutlineInputBorder(),
                  hintText: 'https://images.unsplash.com/...',
                ),
                validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: InputDecoration(
                  labelText: 'Giá (VNĐ) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Bắt buộc' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('Có sẵn: '),
                  Switch(
                    value: _isAvailable,
                    onChanged: (v) => setState(() => _isAvailable = v),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text('Màu nền:'),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    [
                      Colors.pink[100]!,
                      Colors.red[100]!,
                      Colors.orange[100]!,
                      Colors.yellow[100]!,
                      Colors.green[100]!,
                      Colors.blue[100]!,
                      Colors.purple[100]!,
                      Colors.brown[100]!,
                    ].map((c) {
                      return GestureDetector(
                        onTap: () => setState(() => _color = c),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _color == c
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addCake,
                child: Text('Thêm bánh mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

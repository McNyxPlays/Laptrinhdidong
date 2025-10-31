// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import '../models/cake.dart';

class FirebaseService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  // === AUTH ===
  static Future<User?> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'favorites': [],
        'role': email == 'admin@example.com' ? 'admin' : 'user',
      });
      return cred.user;
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      throw 'Đăng nhập thất bại: ${e.toString()}';
    }
  }

  static Future<void> logout() async => await _auth.signOut();
  static User? get currentUser => _auth.currentUser;

  static Future<Map<String, dynamic>> getProfile() async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    return doc.data() ?? {};
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(currentUser!.uid).update(data);
  }

  // === CAKES ===
  static Future<List<Cake>> getCakes() async {
    final snapshot = await _firestore.collection('cakes').get();
    return snapshot.docs.map((doc) => Cake.fromJson(doc.data())).toList();
  }

  static Future<Cake> getCakeById(String id) async {
    final doc = await _firestore.collection('cakes').doc(id).get();
    if (!doc.exists) {
      throw 'Cake not found';
    }
    return Cake.fromJson(doc.data()!);
  }

  // === FAVORITES ===
  static Future<List<String>> getFavorites() async {
    if (currentUser == null) return [];
    final doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    return List<String>.from(doc.data()!['favorites'] ?? []);
  }

  static Future<void> toggleFavorite(String cakeId) async {
    if (currentUser == null) return;
    final ref = _firestore.collection('users').doc(currentUser!.uid);
    final doc = await ref.get();
    List<String> favs = List<String>.from(doc.data()!['favorites'] ?? []);
    favs.contains(cakeId) ? favs.remove(cakeId) : favs.add(cakeId);
    await ref.update({'favorites': favs});
  }

  // === CART ===
  static Future<Map<String, dynamic>> getCart() async {
    if (currentUser == null) return {'items': [], 'total': 0};
    final doc = await _firestore
        .collection('carts')
        .doc(currentUser!.uid)
        .get();
    if (!doc.exists) return {'items': [], 'total': 0};
    return doc.data() ?? {'items': [], 'total': 0};
  }

  static Future<void> addToCart(
    String cakeId,
    String size,
    int quantity,
  ) async {
    if (currentUser == null) return; // Guest dùng local
    final ref = _firestore.collection('carts').doc(currentUser!.uid);
    final doc = await ref.get();
    List items = doc.exists ? (doc.data()!['items'] ?? []) : [];
    final cake = await getCakeById(cakeId);
    final multiplier = {'Nhỏ': 1.0, 'Trung bình': 1.5, 'Lớn': 2.0}[size] ?? 1.0;
    final price = (cake.price * multiplier).toInt();

    final existing = items.firstWhere(
      (i) => i['cakeId'] == cakeId && i['size'] == size,
      orElse: () => null,
    );
    if (existing != null) {
      existing['quantity'] += quantity;
      existing['subtotal'] = existing['quantity'] * price;
    } else {
      items.add({
        'cakeId': cakeId,
        'name': cake.name,
        'image': cake.image,
        'size': size,
        'price': price,
        'quantity': quantity,
        'subtotal': quantity * price,
      });
    }
    int total = items.map((i) => i['subtotal'] as int).sum;
    await ref.set({'items': items, 'total': total});
  }

  static Future<void> updateCartItem(
    String cakeId,
    String size,
    int quantity,
  ) async {
    if (currentUser == null) return;
    final ref = _firestore.collection('carts').doc(currentUser!.uid);
    final doc = await ref.get();
    List items = doc.exists ? (doc.data()!['items'] ?? []) : [];
    final item = items.firstWhere(
      (i) => i['cakeId'] == cakeId && i['size'] == size,
      orElse: () => null,
    );
    if (item == null) return;
    if (quantity <= 0) {
      items.remove(item);
    } else {
      item['quantity'] = quantity;
      item['subtotal'] = quantity * item['price'];
    }
    int total = items.map((i) => i['subtotal'] as int).sum;
    await ref.set({'items': items, 'total': total});
  }

  static Future<void> removeCartItem(String cakeId, String size) async {
    if (currentUser == null) return;
    final ref = _firestore.collection('carts').doc(currentUser!.uid);
    final doc = await ref.get();
    List items = doc.exists ? (doc.data()!['items'] ?? []) : [];
    items.removeWhere((i) => i['cakeId'] == cakeId && i['size'] == size);
    int total = items.map((i) => i['subtotal'] as int).sum;
    await ref.set({'items': items, 'total': total});
  }

  static Future<void> clearCart() async {
    if (currentUser == null) return;
    await _firestore.collection('carts').doc(currentUser!.uid).delete();
  }

  // === ORDERS ===
  static Future<String> createOrder({
    required List items,
    required int total,
    String? name,
    required String address,
    String? note,
    required String paymentMethod,
  }) async {
    final orderId = Uuid().v4();
    final data = {
      'orderId': orderId,
      'userId': currentUser?.uid,
      'name': name ?? (await getProfile())['name'],
      'address': address,
      'note': note,
      'paymentMethod': paymentMethod,
      'items': items,
      'total': total,
      'status': 'Pending',
      'timestamp': Timestamp.now(),
    };
    await _firestore.collection('orders').doc(orderId).set(data);
    if (currentUser != null) await clearCart();
    return orderId;
  }

  static Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    return doc.data();
  }

  static Future<List<Map<String, dynamic>>> getOrderHistory() async {
    if (currentUser == null) return [];
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}

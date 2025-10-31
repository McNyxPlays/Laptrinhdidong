// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/main_screen.dart';
import 'screens/cake_details_screen.dart';
import 'screens/cake_cart_screen.dart'; // THÊM
import 'screens/cake_favorites_screen.dart'; // THÊM
import 'screens/cake_checkout_screen.dart';
import 'screens/user_login_screen.dart';
import 'screens/user_register_screen.dart';
import 'screens/user_profile_screen.dart'; // THÊM
import 'screens/order_history_screen.dart'; // THÊM
import 'screens/order_status_screen.dart';
import 'screens/admin_cake_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: MaterialApp(
        title: 'Cửa Hàng Bánh Kem',
        theme: ThemeData(primarySwatch: Colors.pink),
        home: MainScreen(),
        routes: {
          '/details': (_) => CakeDetailsScreen(),
          '/favorites': (_) => FavoritesScreen(),
          '/cart': (_) => CartScreen(),
          '/orders': (_) => OrderHistoryScreen(),
          '/profile': (_) => UserProfileScreen(),
          '/checkout': (_) => CheckoutScreen(),
          '/login': (_) => LoginScreen(),
          '/register': (_) => RegisterScreen(),
          '/order_status': (_) => OrderStatusScreen(),
          '/admin': (_) => AdminCakeScreen(),
        },
      ),
    );
  }
}

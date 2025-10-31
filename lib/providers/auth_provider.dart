// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _profile;

  User? get user => _user;
  Map<String, dynamic> get profile => _profile ?? {};

  Future<void> register(String name, String email, String password) async {
    _user = await FirebaseService.register(name, email, password);
    await _loadProfile();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _user = await FirebaseService.login(email, password);
    await _loadProfile();
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseService.logout();
    _user = null;
    _profile = null;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    if (_user != null) {
      _profile = await FirebaseService.getProfile();
    }
  }

  Future<Map<String, dynamic>> getUserRole() async {
    if (_profile == null) await _loadProfile();
    return _profile ?? {};
  }

  bool get isAdmin => _profile?['role'] == 'admin';
}

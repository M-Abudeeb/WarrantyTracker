import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';

class StorageService {
  static const String _dummyDataPath = 'assets/dummy_data.json';
  static bool _assetsLoaded = false;
  // Keep a static copy of users for this demo app
  static List<User>? _cachedUsers;

  Future<List<User>> loadAllUsers() async {
    // Return cached users if available
    if (_cachedUsers != null) {
      return _cachedUsers!;
    }

    try {
      if (!_assetsLoaded) {
        await _loadAssets();
        _assetsLoaded = true;
      }
      
      final String jsonString = await rootBundle.loadString(_dummyDataPath);
      final jsonData = json.decode(jsonString);
      
      if (jsonData['users'] == null) {
        debugPrint('No users found in dummy data');
        return [];
      }
      
      final usersList = jsonData['users'] as List;
      _cachedUsers = usersList.map((userJson) => User.fromJson(userJson)).toList();
      return _cachedUsers!;
    } catch (e) {
      debugPrint('Error loading dummy data: $e');
      return [];
    }
  }

  Future<void> _loadAssets() async {
    try {
      await rootBundle.loadString(_dummyDataPath);
    } catch (e) {
      debugPrint('Failed to load assets: $e');
      throw Exception('Could not load assets. Make sure dummy_data.json exists in assets/');
    }
  }

  Future<User?> authenticateUser(String email, String password) async {
    try {
      final users = await loadAllUsers();
      final user = users.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      debugPrint('User authenticated: ${user.email}');
      return user;
    } on StateError catch (_) {
      debugPrint('User not found with email: $email');
      return null;
    } catch (e) {
      debugPrint('Authentication error: $e');
      return null;
    }
  }

  Future<bool> registerUser(String email, String password) async {
    try {
      // Load users (either from cache or file)
      final users = await loadAllUsers();
      
      // Check if email already exists
      final bool emailExists = users.any((user) => user.email == email);
      
      if (emailExists) {
        debugPrint('Email already exists: $email');
        return false;
      }
      
      // Create new user and add to memory cache
      final newUser = User(
        email: email,
        password: password,
        items: [],
      );
      
      _cachedUsers!.add(newUser);
      debugPrint('New user registered: $email (total users: ${_cachedUsers!.length})');
      
      // In a real app, we would save this back to persistent storage
      return true;
      
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }
}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageService {
  static const String _authTokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';
  static const String _lastEmailKey = 'last_email';

  /// Save authentication token
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  /// Save user data
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = json.encode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  /// Get user data
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        // If user data is corrupted, clear it
        await prefs.remove(_userKey);
        return null;
      }
    }
    
    return null;
  }

  /// Save remember me preference
  Future<void> saveRememberMe(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, remember);
  }

  /// Get remember me preference
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  /// Save last used email
  Future<void> saveLastEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastEmailKey, email);
  }

  /// Get last used email
  Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastEmailKey);
  }

  /// Clear all authentication data
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userKey);
  }

  /// Clear all stored data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null;
  }
}
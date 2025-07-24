import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import 'storage_service.dart';

class ApiService {
  static const String _baseUrl = kDebugMode 
    ? 'http://localhost:8000/api' 
    : 'https://your-production-domain.com/api';
  
  static const Duration _timeout = Duration(seconds: 30);
  
  final StorageService _storage = StorageService();

  // Headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'DrLab-Desktop/1.0.0',
  };

  // Headers with authentication token
  Future<Map<String, String>> get _authHeaders async {
    final token = await _storage.getAuthToken();
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Login with email and password
  Future<ApiResponse<LoginResult>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final user = User.fromJson(data['data']['user']);
          final token = data['data']['token'];
          
          // Store auth token
          await _storage.saveAuthToken(token);
          await _storage.saveUser(user);
          
          return ApiResponse.success(LoginResult(
            user: user,
            token: token,
            needsSetup: !user.accountIsSet,
          ));
        } else {
          return ApiResponse.error(data['message'] ?? 'Login failed');
        }
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        return ApiResponse.error(data['message'] ?? 'Invalid credentials');
      } else {
        return ApiResponse.error('Server error. Please try again.');
      }
    } on SocketException {
      return ApiResponse.error('No internet connection. Please check your network.');
    } on http.ClientException {
      return ApiResponse.error('Connection failed. Please try again.');
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Setup user account with new password
  Future<ApiResponse<User>> setupAccount(String password, String passwordConfirmation) async {
    try {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/setup-account'),
        headers: headers,
        body: json.encode({
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final user = User.fromJson(data['data']['user']);
          await _storage.saveUser(user);
          
          return ApiResponse.success(user);
        } else {
          return ApiResponse.error(data['message'] ?? 'Setup failed');
        }
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.containsKey('password')) {
          return ApiResponse.error(errors['password'][0]);
        }
        return ApiResponse.error(data['message'] ?? 'Validation failed');
      } else {
        return ApiResponse.error('Server error. Please try again.');
      }
    } on SocketException {
      return ApiResponse.error('No internet connection. Please check your network.');
    } catch (e) {
      if (kDebugMode) print('Setup account error: $e');
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Get current user profile
  Future<ApiResponse<User>> getProfile() async {
    try {
      final headers = await _authHeaders;
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/profile'),
        headers: headers,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final user = User.fromJson(data['data']['user']);
          await _storage.saveUser(user);
          
          return ApiResponse.success(user);
        } else {
          return ApiResponse.error(data['message'] ?? 'Failed to get profile');
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await _storage.clearAuthData();
        return ApiResponse.error('Session expired. Please login again.');
      } else {
        return ApiResponse.error('Server error. Please try again.');
      }
    } catch (e) {
      if (kDebugMode) print('Get profile error: $e');
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Update login timestamp
  Future<ApiResponse<void>> updateLogin() async {
    try {
      final headers = await _authHeaders;
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/update-login'),
        headers: headers,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error('Failed to update login timestamp');
      }
    } catch (e) {
      if (kDebugMode) print('Update login error: $e');
      return ApiResponse.error('Failed to update login timestamp');
    }
  }

  /// Logout from current device
  Future<ApiResponse<void>> logout() async {
    try {
      final headers = await _authHeaders;
      await http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: headers,
      ).timeout(_timeout);
      
      // Clear local storage regardless of API response
      await _storage.clearAuthData();
      
      return ApiResponse.success(null);
    } catch (e) {
      // Clear local storage even if API call fails
      await _storage.clearAuthData();
      return ApiResponse.success(null);
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storage.getAuthToken();
    return token != null;
  }
}

class LoginResult {
  final User user;
  final String token;
  final bool needsSetup;

  LoginResult({
    required this.user,
    required this.token,
    required this.needsSetup,
  });
}
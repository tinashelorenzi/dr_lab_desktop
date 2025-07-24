// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../models/login_result.dart';
import 'storage_service.dart';
import 'debug_logger.dart';

class ApiService {
  static String get _baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    // Use 127.0.0.1 instead of localhost for consistency
    return kDebugMode 
      ? 'http://127.0.0.1:8000/api' 
      : 'https://your-production-domain.com/api';
  }
  
  static Duration get _timeout {
    final envTimeout = dotenv.env['API_TIMEOUT'];
    if (envTimeout != null) {
      final timeoutMs = int.tryParse(envTimeout) ?? 30000;
      return Duration(milliseconds: timeoutMs);
    }
    return const Duration(seconds: 30);
  }
  
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

  /// Make authenticated HTTP request with debug logging and better error handling
  Future<http.Response> _makeRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final uri = Uri.parse(url);
    final requestHeaders = headers ?? _headers;
    final stopwatch = Stopwatch()..start();
    
    // Log the request
    DebugLogger.logRequest(
      method: method,
      url: url,
      headers: requestHeaders,
      body: body,
    );

    try {
      late http.Response response;
      
      // Add more detailed timeout and error handling
      final client = http.Client();
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await client.get(uri, headers: requestHeaders).timeout(_timeout);
          break;
        case 'POST':
          response = await client.post(uri, headers: requestHeaders, body: body).timeout(_timeout);
          break;
        case 'PUT':
          response = await client.put(uri, headers: requestHeaders, body: body).timeout(_timeout);
          break;
        case 'DELETE':
          response = await client.delete(uri, headers: requestHeaders).timeout(_timeout);
          break;
        case 'PATCH':
          response = await client.patch(uri, headers: requestHeaders, body: body).timeout(_timeout);
          break;
        default:
          throw UnsupportedError('HTTP method $method is not supported');
      }

      client.close();
      stopwatch.stop();
      
      // Log the response
      DebugLogger.logResponse(
        method: method,
        url: url,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      return response;
    } on SocketException catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print('SocketException: $e');
        print('Trying to connect to: $url');
        print('Make sure your Laravel server is running on http://127.0.0.1:8000');
      }
      
      // Log the error
      DebugLogger.logError(
        method: method,
        url: url,
        error: e,
        stackTrace: StackTrace.current,
      );
      
      rethrow;
    } on TimeoutException catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print('TimeoutException: $e');
        print('Request timed out after ${_timeout.inSeconds} seconds');
      }
      
      DebugLogger.logError(
        method: method,
        url: url,
        error: e,
        stackTrace: StackTrace.current,
      );
      
      rethrow;
    } catch (error, stackTrace) {
      stopwatch.stop();
      
      if (kDebugMode) {
        print('Request error: $error');
        print('URL: $url');
      }
      
      // Log the error
      DebugLogger.logError(
        method: method,
        url: url,
        error: error,
        stackTrace: stackTrace,
      );
      
      rethrow;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.getAuthToken();
      if (token == null) return false;
      
      // Verify token with server
      final response = await _makeRequest(
        method: 'GET',
        url: '$_baseUrl/auth/profile',
        headers: await _authHeaders,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Authentication check failed: $e');
      return false;
    }
  }

  /// Get user profile
  Future<ApiResponse<User>> getProfile() async {
    try {
      final response = await _makeRequest(
        method: 'GET',
        url: '$_baseUrl/auth/profile',
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final user = User.fromJson(data['data']);
          return ApiResponse.success(user);
        } else {
          return ApiResponse.error(data['message'] ?? 'Failed to get profile');
        }
      } else if (response.statusCode == 401) {
        // Token is invalid, clear it
        await _storage.clearAuthData();
        return ApiResponse.error('Authentication expired. Please login again.');
      } else {
        return ApiResponse.error('Server error. Please try again.');
      }
    } on SocketException {
      return ApiResponse.error('Cannot connect to server. Please check your connection.');
    } on TimeoutException {
      return ApiResponse.error('Request timed out. Please try again.');
    } catch (e) {
      if (kDebugMode) print('Profile error: $e');
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Login with email and password
  Future<ApiResponse<LoginResult>> login(String email, String password) async {
    try {
      final response = await _makeRequest(
        method: 'POST',
        url: '$_baseUrl/auth/login',
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
          'device_name': 'Dr Lab Desktop',
        }),
      );

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
      } else if (response.statusCode == 401) {
        final data = json.decode(response.body);
        return ApiResponse.error(data['message'] ?? 'Invalid credentials');
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        return ApiResponse.error(data['message'] ?? 'Invalid credentials');
      } else {
        return ApiResponse.error('Server error. Please try again.');
      }
    } on SocketException {
      return ApiResponse.error('Cannot connect to server. Please check if your Laravel server is running on http://127.0.0.1:8000');
    } on http.ClientException {
      return ApiResponse.error('Connection failed. Please try again.');
    } on TimeoutException {
      return ApiResponse.error('Request timed out. Please check your connection and try again.');
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Logout user
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _makeRequest(
        method: 'POST',
        url: '$_baseUrl/auth/logout',
        headers: await _authHeaders,
      );

      // Clear local auth data regardless of server response
      await _storage.clearAuthData();

      if (response.statusCode == 200) {
        return ApiResponse.success(null, 'Logged out successfully');
      } else {
        // Even if server logout fails, we've cleared local data
        return ApiResponse.success(null, 'Logged out successfully');
      }
    } catch (e) {
      // Clear local data even if network request fails
      await _storage.clearAuthData();
      if (kDebugMode) print('Logout error: $e');
      return ApiResponse.success(null, 'Logged out successfully');
    }
  }

  /// Setup account with password
  Future<ApiResponse<User>> setupAccount(String password, String confirmPassword) async {
    try {
      final response = await _makeRequest(
        method: 'POST',
        url: '$_baseUrl/auth/setup-account',
        headers: await _authHeaders,
        body: json.encode({
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final user = User.fromJson(data['data']['user']);
          // Update stored user
          await _storage.saveUser(user);
          return ApiResponse.success(user, 'Account setup completed successfully');
        } else {
          return ApiResponse.error(data['message'] ?? 'Account setup failed');
        }
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        return ApiResponse.error(data['message'] ?? 'Validation failed');
      } else {
        return ApiResponse.error('Server error. Please try again.');
      }
    } on SocketException {
      return ApiResponse.error('Cannot connect to server. Please check your connection.');
    } on TimeoutException {
      return ApiResponse.error('Request timed out. Please try again.');
    } catch (e) {
      if (kDebugMode) print('Setup account error: $e');
      return ApiResponse.error('An unexpected error occurred.');
    }
  }

  /// Update login timestamp
  Future<ApiResponse<void>> updateLogin() async {
    try {
      final response = await _makeRequest(
        method: 'POST',
        url: '$_baseUrl/auth/update-login',
        headers: await _authHeaders,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null, 'Login updated successfully');
      } else {
        // Don't fail the login flow if this fails
        return ApiResponse.success(null, 'Login updated');
      }
    } catch (e) {
      if (kDebugMode) print('Update login error: $e');
      // Don't fail the login flow if this fails
      return ApiResponse.success(null, 'Login updated');
    }
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import 'storage_service.dart';
import 'debug_logger.dart';

class ApiService {
  static String get _baseUrl {
    final envUrl = dotenv.env['API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    return kDebugMode 
      ? 'http://localhost:8000/api' 
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

  /// Make authenticated HTTP request with debug logging
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
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders).timeout(_timeout);
          break;
        case 'POST':
          response = await http.post(uri, headers: requestHeaders, body: body).timeout(_timeout);
          break;
        case 'PUT':
          response = await http.put(uri, headers: requestHeaders, body: body).timeout(_timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: requestHeaders).timeout(_timeout);
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: requestHeaders, body: body).timeout(_timeout);
          break;
        default:
          throw UnsupportedError('HTTP method $method is not supported');
      }

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
    } catch (error, stackTrace) {
      stopwatch.stop();
      
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

  /// Generic GET request with authentication
  Future<ApiResponse<T>> get<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final headers = await _authHeaders;
      final response = await _makeRequest(
        method: 'GET',
        url: '$_baseUrl$endpoint',
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ApiResponse.success(fromJson(data['data']));
        } else {
          return ApiResponse.error(data['message'] ?? 'Request failed');
        }
      } else {
        return ApiResponse.error('Server error: ${response.statusCode}');
      }
    } on SocketException {
      return ApiResponse.error('No internet connection.');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  /// Generic POST request with authentication
  Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final headers = await _authHeaders;
      final response = await _makeRequest(
        method: 'POST',
        url: '$_baseUrl$endpoint',
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return ApiResponse.success(fromJson(responseData['data']));
        } else {
          return ApiResponse.error(responseData['message'] ?? 'Request failed');
        }
      } else {
        return ApiResponse.error('Server error: ${response.statusCode}');
      }
    } on SocketException {
      return ApiResponse.error('No internet connection.');
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  /// Logout user
  Future<ApiResponse<void>> logout() async {
    try {
      final headers = await _authHeaders;
      await _makeRequest(
        method: 'POST',
        url: '$_baseUrl/auth/logout',
        headers: headers,
      );
      
      // Clear local storage regardless of response
      await _storage.clearAuthData();
      
      return ApiResponse.success(null);
    } catch (e) {
      // Still clear local data even if logout request fails
      await _storage.clearAuthData();
      return ApiResponse.success(null);
    }
  }
}

// LoginResult class for the login response
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
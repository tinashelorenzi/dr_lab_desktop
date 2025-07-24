// lib/services/api_service.dart
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

  // Rest of your methods remain the same...
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
}
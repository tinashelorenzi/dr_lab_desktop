import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DebugLogger {
  static bool get _isDebugMode {
    try {
      final debugMode = dotenv.env['DEBUG_MODE']?.toLowerCase();
      return debugMode == 'true' || debugMode == '1';
    } catch (e) {
      return false; // Default to false if .env is not loaded
    }
  }

  /// Logs HTTP request details to the terminal
  static void logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    if (!_isDebugMode) return;

    final buffer = StringBuffer();
    buffer.writeln('\n🚀 === HTTP REQUEST ===');
    buffer.writeln('📍 URL: $url');
    buffer.writeln('🔥 Method: $method');
    
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('📋 Headers:');
      headers.forEach((key, value) {
        // Mask sensitive headers
        final displayValue = _isSensitiveHeader(key) ? '***MASKED***' : value;
        buffer.writeln('   $key: $displayValue');
      });
    }
    
    if (body != null) {
      buffer.writeln('📦 Body:');
      try {
        if (body is String) {
          final jsonBody = json.decode(body);
          final prettyJson = JsonEncoder.withIndent('  ').convert(jsonBody);
          buffer.writeln(prettyJson);
        } else {
          buffer.writeln(body.toString());
        }
      } catch (e) {
        buffer.writeln(body.toString());
      }
    }
    
    buffer.writeln('========================\n');
    
    // Use developer.log for better formatting in terminal
    developer.log(
      buffer.toString(),
      name: 'API_REQUEST',
      time: DateTime.now(),
    );
  }

  /// Logs HTTP response details to the terminal
  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    Map<String, String>? headers,
    dynamic body,
    Duration? duration,
  }) {
    if (!_isDebugMode) return;

    final buffer = StringBuffer();
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final emoji = isSuccess ? '✅' : '❌';
    
    buffer.writeln('\n$emoji === HTTP RESPONSE ===');
    buffer.writeln('📍 URL: $url');
    buffer.writeln('🔥 Method: $method');
    buffer.writeln('📊 Status: $statusCode ${_getStatusText(statusCode)}');
    
    if (duration != null) {
      buffer.writeln('⏱️ Duration: ${duration.inMilliseconds}ms');
    }
    
    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('📋 Response Headers:');
      headers.forEach((key, value) {
        buffer.writeln('   $key: $value');
      });
    }
    
    if (body != null) {
      buffer.writeln('📦 Response Body:');
      try {
        if (body is String && body.isNotEmpty) {
          final jsonBody = json.decode(body);
          final prettyJson = JsonEncoder.withIndent('  ').convert(jsonBody);
          buffer.writeln(prettyJson);
        } else {
          buffer.writeln(body.toString());
        }
      } catch (e) {
        buffer.writeln(body.toString());
      }
    }
    
    buffer.writeln('==========================\n');
    
    developer.log(
      buffer.toString(),
      name: 'API_RESPONSE',
      time: DateTime.now(),
    );
  }

  /// Logs API errors to the terminal
  static void logError({
    required String method,
    required String url,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!_isDebugMode) return;

    final buffer = StringBuffer();
    buffer.writeln('\n💥 === HTTP ERROR ===');
    buffer.writeln('📍 URL: $url');
    buffer.writeln('🔥 Method: $method');
    buffer.writeln('⚠️ Error: $error');
    
    if (stackTrace != null) {
      buffer.writeln('📚 Stack Trace:');
      buffer.writeln(stackTrace.toString());
    }
    
    buffer.writeln('=====================\n');
    
    developer.log(
      buffer.toString(),
      name: 'API_ERROR',
      time: DateTime.now(),
      level: 1000, // Error level
    );
  }

  /// Check if header contains sensitive information
  static bool _isSensitiveHeader(String headerName) {
    final sensitive = [
      'authorization',
      'x-api-key',
      'x-auth-token',
      'cookie',
      'set-cookie',
    ];
    return sensitive.contains(headerName.toLowerCase());
  }

  /// Get human-readable status text
  static String _getStatusText(int statusCode) {
    switch (statusCode) {
      case 200: return '(OK)';
      case 201: return '(Created)';
      case 400: return '(Bad Request)';
      case 401: return '(Unauthorized)';
      case 403: return '(Forbidden)';
      case 404: return '(Not Found)';
      case 422: return '(Unprocessable Entity)';
      case 500: return '(Internal Server Error)';
      default: return '';
    }
  }
}
// lib/services/debug_logger.dart
import 'package:flutter/foundation.dart';

class DebugLogger {
  static const String _tag = '[DrLab API]';

  /// Log API request
  static void logRequest({
    required String method,
    required String url,
    required Map<String, String> headers,
    dynamic body,
  }) {
    if (!kDebugMode) return;

    print('$_tag ➡️ $method $url');
    
    // Log headers (excluding sensitive data)
    final safeHeaders = Map<String, String>.from(headers);
    if (safeHeaders.containsKey('Authorization')) {
      final auth = safeHeaders['Authorization']!;
      if (auth.startsWith('Bearer ')) {
        safeHeaders['Authorization'] = 'Bearer ${auth.substring(7, 17)}...';
      }
    }
    print('$_tag Headers: $safeHeaders');
    
    // Log body (be careful with sensitive data)
    if (body != null) {
      if (body is String && body.contains('"password"')) {
        print('$_tag Body: [Contains password - hidden for security]');
      } else {
        print('$_tag Body: $body');
      }
    }
  }

  /// Log API response
  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    required Map<String, String> headers,
    required String body,
    required Duration duration,
  }) {
    if (!kDebugMode) return;

    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    print('$_tag $emoji $method $url - $statusCode (${duration.inMilliseconds}ms)');
    
    // Log response body (truncate if too long)
    if (body.isNotEmpty) {
      final truncatedBody = body.length > 500 ? '${body.substring(0, 500)}...' : body;
      print('$_tag Response: $truncatedBody');
    }
  }

  /// Log API error
  static void logError({
    required String method,
    required String url,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;

    print('$_tag 💥 $method $url - ERROR: $error');
    if (stackTrace != null) {
      print('$_tag Stack trace: $stackTrace');
    }
  }

  /// Log general debug info
  static void logInfo(String message) {
    if (!kDebugMode) return;
    print('$_tag ℹ️ $message');
  }

  /// Log warning
  static void logWarning(String message) {
    if (!kDebugMode) return;
    print('$_tag ⚠️ $message');
  }
}
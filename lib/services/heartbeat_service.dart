import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class HeartbeatService {
  Timer? _timer;
  final ApiService _apiService = ApiService();
  bool _isRunning = false;

  /// Start the heartbeat service
  void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    if (kDebugMode) print('Heartbeat service started');
    
    // Send initial heartbeat
    _sendHeartbeat();
    
    // Set up periodic heartbeat (every 30 seconds)
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _sendHeartbeat();
    });
  }

  /// Stop the heartbeat service
  void stop() {
    if (!_isRunning) return;
    
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    
    if (kDebugMode) print('Heartbeat service stopped');
    
    // Send final offline status
    _setOffline();
  }

  /// Send heartbeat to server
  Future<void> _sendHeartbeat() async {
    try {
      final response = await _apiService.sendHeartbeat();
      
      if (response.isSuccess) {
        if (kDebugMode) print('Heartbeat sent successfully');
      } else {
        if (kDebugMode) print('Heartbeat failed: ${response.errorMessage}');
      }
    } catch (e) {
      if (kDebugMode) print('Heartbeat error: $e');
    }
  }

  /// Set user as offline
  Future<void> _setOffline() async {
    try {
      final response = await _apiService.setOffline();
      
      if (response.isSuccess) {
        if (kDebugMode) print('Offline status set successfully');
      } else {
        if (kDebugMode) print('Failed to set offline status: ${response.errorMessage}');
      }
    } catch (e) {
      if (kDebugMode) print('Set offline error: $e');
    }
  }

  /// Check if the service is running
  bool get isRunning => _isRunning;
}
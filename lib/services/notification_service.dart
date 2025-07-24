import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS/macOS initialization settings  
    const darwinSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      // Request permissions for macOS
      if (Platform.isMacOS) {
        await _notifications
            .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
      
      _initialized = true;
      if (kDebugMode) print('Notification service initialized successfully');
    } catch (e) {
      if (kDebugMode) print('Failed to initialize notifications: $e');
    }
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    // Handle notification tap actions here
    // For example, navigate to specific screens
  }

  /// Show login success notification
  Future<void> showLoginSuccessNotification(String userName) async {
    if (!_initialized) await initialize();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'security_channel',
        'Security Notifications',
        channelDescription: 'Notifications for security events',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'security_icon',
        color: Color(0xFF0078D4),
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        categoryIdentifier: 'security_category',
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        categoryIdentifier: 'security_category',
      ),
    );

    try {
      await _notifications.show(
        1001, // Notification ID for login events
        'Login Successful',
        'Welcome back, $userName! You have successfully signed in to Dr Lab.',
        notificationDetails,
        payload: 'login_success',
      );
      
      if (kDebugMode) print('Login success notification sent for: $userName');
    } catch (e) {
      if (kDebugMode) print('Failed to show login notification: $e');
    }
  }

  /// Show account setup notification
  Future<void> showAccountSetupNotification() async {
    if (!_initialized) await initialize();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'account_channel',
        'Account Notifications',
        channelDescription: 'Notifications for account events',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'account_icon',
        color: Color(0xFF107C10),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    try {
      await _notifications.show(
        1002, // Notification ID for account setup events
        'Account Setup Complete',
        'Your Dr Lab account has been successfully configured.',
        notificationDetails,
        payload: 'account_setup_complete',
      );
      
      if (kDebugMode) print('Account setup notification sent');
    } catch (e) {
      if (kDebugMode) print('Failed to show setup notification: $e');
    }
  }

  /// Show security alert notification
  Future<void> showSecurityAlertNotification(String message) async {
    if (!_initialized) await initialize();

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'security_channel',
        'Security Notifications',
        channelDescription: 'Notifications for security events',
        importance: Importance.max,
        priority: Priority.max,
        icon: 'security_alert_icon',
        color: Color(0xFFD13438),
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      ),
    );

    try {
      await _notifications.show(
        1003, // Notification ID for security alerts
        'Security Alert',
        message,
        notificationDetails,
        payload: 'security_alert',
      );
      
      if (kDebugMode) print('Security alert notification sent: $message');
    } catch (e) {
      if (kDebugMode) print('Failed to show security alert: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
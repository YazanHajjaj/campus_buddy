import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'local_notification_service.dart';

class LocalNotificationServiceImpl
    implements LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  // ───────────────── INITIALIZATION ─────────────────

  @override
  Future<void> initialize() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null) return;
        final payload =
        Map<String, dynamic>.from(jsonDecode(response.payload!));
        handleNotificationTap(payload);
      },
    );
  }

  // ───────────────── FOREGROUND NOTIFICATIONS ─────────────────

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'general',
        'General',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: jsonEncode(payload),
    );
  }

  // ───────────────── LOCAL REMINDERS ─────────────────
  @override
  Future<void> scheduleReminder({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminders',
        'Reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final tz.TZDateTime scheduled =
    tz.TZDateTime.from(scheduledAt, tz.local); // ✅ FIX

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode:
      AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode(payload),
    );
  }

  @override
  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  // ───────────────── TAP HANDLING ─────────────────

  @override
  Future<void> handleNotificationTap(
      Map<String, dynamic> payload) async {
    debugPrint('🔔 Notification tapped: $payload');

    // Routing logic will live here later
    // Example:
    // if (payload['type'] == NotificationPayload.studyGroupCreated) {
    //   navigatorKey.currentState?.pushNamed(...);
    // }
  }
}
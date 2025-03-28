import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'event_model.dart';
import 'recurrence.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

        // Request notification permission
    await Permission.notification.request();
    
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification taps here
      },
    );

    // Create notification channel (Android 8.0+)
    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'event_channel', // Must match channel ID in scheduleEventNotification
      'Event Reminders', // Channel name
      description: 'Notifications for upcoming events', // Channel description
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      ledColor: Colors.blue,
      enableLights: true,
    );
    
    try {
      await _notifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);
        print('✅ Notification channel created successfully');
    } catch (e) {
      print('❌ Failed to create channel: $e');
    }
  }

  static Future<void> scheduleEventNotification(Event event) async {
    final tzDateTime = tz.TZDateTime.from(
      event.notificationDateTime.toLocal(),
      tz.local,
    );

    if (tzDateTime.isBefore(DateTime.now().add(Duration(seconds: 10)))) {
      final adjustedTime = DateTime.now().add(Duration(seconds: 10));
      event.date = adjustedTime;
      event.time = TimeOfDay.fromDateTime(adjustedTime);
    }

    final androidDetails = AndroidNotificationDetails(
      'event_channel',
      'Event Reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    try {
      await _notifications.zonedSchedule(
        event.id.hashCode,
        event.title,
        event.description,
        tzDateTime,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: event.isRecurring 
            ? _getRecurrenceComponents(event) 
            : null,
      );
    } catch (e) {
      await _notifications.show(
        event.id.hashCode + 1,
        event.title,
        'Scheduled notification failed: ${event.description}',
        NotificationDetails(android: androidDetails),
      );
    }
  }

  static tz.TZDateTime _convertToTz(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  static DateTimeComponents? _getRecurrenceComponents(Event event) {
    if (!event.isRecurring) return null;
    
    switch (event.recurrence) {
      case Recurrence.daily:
        return DateTimeComponents.time;
      case Recurrence.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case Recurrence.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case Recurrence.yearly:
        return DateTimeComponents.dateAndTime;
      default:
        return null;
    }
  }

  static Future<void> cancelNotification(Event event) async {
    print('❌ Canceling notification for event "${event.title}" (ID: ${event.id.hashCode})');
    await _notifications.cancel(event.id.hashCode);
  }

  static Future<void> clearAllNotifications() async {
    await _notifications.cancelAll();
  }
}
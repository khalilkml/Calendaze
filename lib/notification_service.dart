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
      'event_channel',
      'Event Reminders',
      description: 'Notifications for upcoming events',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      ledColor: Colors.blue,
      enableLights: true,
      showBadge: true,
    );
    
    try {
      await _notifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(androidChannel);
      print('✅ Notification channel created successfully: $androidChannel');
    } catch (e) {
      print('❌ Failed to create channel: $e');
      // Try showing a regular notification to verify basic functionality
      await _notifications.show(
        9999,
        'Channel Creation Failed',
        'Could not create notification channel: $e',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'fallback_channel',
            'Fallback Channel',
            importance: Importance.high,
          ),
        ),
      );
    }
  }

  static Future<void> scheduleEventNotification(Event event) async {
  // Define AndroidNotificationDetails
  const androidDetails = AndroidNotificationDetails(
    'event_channel', // Channel ID must match the created channel
    'Event Reminders',
    channelDescription: 'Notifications for upcoming events',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );

  // Verify notification permission
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }

  // Convert to local timezone
  final localDateTime = event.notificationDateTime.toLocal();
  final tzDateTime = tz.TZDateTime.from(localDateTime, tz.local);

  // Debug print
  print('Scheduling notification for: $tzDateTime | Now: ${tz.TZDateTime.now(tz.local)}');

  // Only adjust time if it's in the past (with some buffer)
  if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local).add(Duration(minutes: 1)))) {
    print('Adjusting notification time to future');
    final adjustedTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: 1));
    await _notifications.zonedSchedule(
      event.id.hashCode,
      'Adjusted: ${event.title}',
      'Original time was in past: ${event.description}',
      adjustedTime,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    return;
  }

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
    print('✅ Notification scheduled successfully for ${event.title} at $tzDateTime');
  } catch (e) {
    print('❌ Error scheduling notification: $e');
    await _notifications.show(
      event.id.hashCode + 1,
      'Failed to schedule: ${event.title}',
      'Error: $e\nEvent: ${event.description}',
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
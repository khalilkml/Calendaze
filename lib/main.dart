import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'event_provider.dart';
import 'event_model.dart';
import 'notification_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io' show Platform;
import 'package:intl/intl.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.initialize();

   // Clear previous notifications
  await NotificationService.clearAllNotifications();

  // Welcome notification
  await FlutterLocalNotificationsPlugin().show(
    0, // Notification ID
    'Colondaze', // Notification title
    'Welcome to you Calendare app',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'event_channel', // Must match your channel ID
        'Event Reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
      ),
    ),
  );

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: Consumer<EventProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Calendaze',
            theme: provider.isDarkMode
                ? ThemeData.dark().copyWith(
                    primaryColor: Colors.blueGrey,
                    colorScheme: ThemeData.dark().colorScheme.copyWith(
                      secondary: Colors.tealAccent,
                    ),
                  )
                : ThemeData.light().copyWith(
                    primaryColor: Colors.blue,
                    colorScheme: ThemeData.light().colorScheme.copyWith(
                      secondary: Colors.lightBlueAccent,
                    ),
                  ),
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
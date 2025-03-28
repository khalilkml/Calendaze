import 'package:flutter/material.dart';
import 'package:calendaze/notification_service.dart';
import 'package:calendaze/event_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.initialize();
  
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Test Notification'),
              onPressed: () async {
              // Use DateTime.now().add() to ensure future time
              final notificationTime = DateTime.now().add(Duration(minutes: 1));
              
              await NotificationService.scheduleEventNotification(
                Event(
                  id: 'test-${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Test Notification',
                  description: 'This is a test',
                  date: notificationTime,
                  time: TimeOfDay.fromDateTime(notificationTime),
                  hasNotification: true,
                ),
              );
            },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Check Permissions'),
              onPressed: () async {
                final status = await Permission.notification.status;
                print('Notification permission: $status');
              },
            ),
          ],
        ),
      ),
    ),
  ));
}
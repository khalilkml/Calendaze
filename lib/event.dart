// event.dart
import 'package:flutter/material.dart';
import 'recurrence.dart';  // Import the enum

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final bool isRecurring;
  final Recurrence recurrence;
  final bool hasNotification;
  final Color color;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.isRecurring = false,
    this.recurrence = Recurrence.none,
    this.hasNotification = false,
    this.color = Colors.blue,
  });

  DateTime get notificationDateTime {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }
}
import 'package:flutter/material.dart';
import 'recurrence.dart';

class Event {
  String id;
  String title;
  String description;
  DateTime date;
  TimeOfDay time;
  bool isRecurring;
  Recurrence recurrence;
  bool hasNotification;
  Color color;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.isRecurring = false,
    this.recurrence = Recurrence.none,
    this.hasNotification = false,
    this.color = Colors.blue, // Add default color
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
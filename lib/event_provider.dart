import 'package:flutter/material.dart';
import 'event_model.dart';
import 'notification_service.dart';

class EventProvider with ChangeNotifier {

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  final List<Event> _events = [];

  List<Event> get events => _events;

  void addEvent(Event event) {
    _events.add(event);
    if (event.hasNotification) {
      NotificationService().scheduleNotification(event);
    }
    notifyListeners();
  }

  void updateEvent(Event oldEvent, Event newEvent) {
    final index = _events.indexOf(oldEvent);
    _events[index] = newEvent;
    if (newEvent.hasNotification) {
      NotificationService().scheduleNotification(newEvent);
    }
    notifyListeners();
  }

  void deleteEvent(Event event) {
    _events.remove(event);
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
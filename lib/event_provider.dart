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
      NotificationService.scheduleEventNotification(event);
    }
    notifyListeners();
  }

  void updateEvent(Event oldEvent, Event newEvent) {
    final index = _events.indexOf(oldEvent);
    _events[index] = newEvent;
    
    // Cancel old notification if it existed
    if (oldEvent.hasNotification) {
      NotificationService.cancelNotification(oldEvent);
    }
    
    // Schedule new notification if needed
    if (newEvent.hasNotification) {
      NotificationService.scheduleEventNotification(newEvent);
    }
    
    notifyListeners();
  }

  void deleteEvent(Event event) {
    _events.remove(event);
    
    // Cancel notification if it existed
    if (event.hasNotification) {
      NotificationService.cancelNotification(event);
    }
    
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
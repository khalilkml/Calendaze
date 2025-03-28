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
    print('Adding event: ${event.title} at ${event.notificationDateTime}');
    if (event.hasNotification) {
      print('Scheduling notification for event');
      NotificationService.scheduleEventNotification(event);
    }
    notifyListeners();
  }

  void updateEvent(Event oldEvent, Event newEvent) {
    final index = _events.indexOf(oldEvent);
    _events[index] = newEvent;
    print('Updating event: ${newEvent.title} at ${newEvent.notificationDateTime}');
    
    if (oldEvent.hasNotification) {
      print('Canceling old notification');
      NotificationService.cancelNotification(oldEvent);
    }
    
    if (newEvent.hasNotification) {
      print('Scheduling new notification');
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
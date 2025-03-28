import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event_model.dart';
import 'event_editor.dart';
import 'event_provider.dart';
import 'package:provider/provider.dart';
import 'recurrence.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final events = eventProvider.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendaze'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_selectedDay != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventEditor(
                      selectedDate: _selectedDay!,
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Provider.of<EventProvider>(context).isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => Provider.of<EventProvider>(context, listen: false).toggleDarkMode(),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) => setState(() => _calendarFormat = format),
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            eventLoader: (day) => _getEventsForDay(day, events),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${events.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          Expanded(
            child: _buildEventsList(events, eventProvider),
          ),
        ],
      ),
    );
  }

  List<Event> _getEventsForDay(DateTime day, List<Event> events) {
    return events.where((event) {
      if (event.isRecurring) {
        switch (event.recurrence) {
          case Recurrence.daily:
            return true;
          case Recurrence.weekly:
            return day.weekday == event.date.weekday;
          case Recurrence.monthly:
            return day.day == event.date.day;
          case Recurrence.yearly:
            return day.day == event.date.day && day.month == event.date.month;
          case Recurrence.none:
            return isSameDay(day, event.date);
        }
      }
      return isSameDay(day, event.date);
    }).toList();
  }

  Widget _buildEventsList(List<Event> events, EventProvider eventProvider) {
    final dayEvents = _getEventsForDay(_selectedDay ?? DateTime.now(), events);
    
    return dayEvents.isEmpty
        ? const Center(child: Text('No events for selected day'))
        : ListView.builder(
            itemCount: dayEvents.length,
            itemBuilder: (context, index) {
              final event = dayEvents[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: Container(
                    width: 12,
                    height: 40,
                    decoration: BoxDecoration(
                      color: event.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  title: Text(event.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.description),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.jm().format(DateTime(
                          event.date.year,
                          event.date.month,
                          event.date.day,
                          event.time.hour,
                          event.time.minute,
                        )),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (event.isRecurring) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.repeat, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              event.recurrence.toString().split('.').last,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => eventProvider.deleteEvent(event),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventEditor(
                        event: event,
                        selectedDate: event.date,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}
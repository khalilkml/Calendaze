import 'package:flutter/material.dart';
import 'event_model.dart';
import 'event_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'recurrence.dart';

class EventEditor extends StatefulWidget {
  final Event? event;
  final DateTime selectedDate;

  const EventEditor({
    super.key,
    this.event,
    required this.selectedDate,
  });

  @override
  _EventEditorState createState() => _EventEditorState();
}

class _EventEditorState extends State<EventEditor> {
  late String _title;
  late String _description;
  late DateTime _date;
  late TimeOfDay _time;
  late bool _isRecurring;
  late Recurrence _recurrence;
  late bool _hasNotification;
  late Color _eventColor;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Available colors for events
  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _title = widget.event!.title;
      _description = widget.event!.description;
      _date = widget.event!.date;
      _time = widget.event!.time;
      _isRecurring = widget.event!.isRecurring;
      _recurrence = widget.event!.recurrence;
      _hasNotification = widget.event!.hasNotification;
      _eventColor = widget.event!.color;
      
      _titleController.text = _title;
      _descriptionController.text = _description;
    } else {
      _title = '';
      _description = '';
      _date = widget.selectedDate;
      _time = TimeOfDay.now();
      _isRecurring = false;
      _recurrence = Recurrence.none;
      _hasNotification = false;
      _eventColor = Colors.blue; // Default color
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (pickedTime != null) {
      setState(() {
        _time = pickedTime;
      });
    }
  }

  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      final newEvent = Event(
        id: widget.event?.id ?? DateTime.now().toString(),
        title: _title,
        description: _description,
        date: _date,
        time: _time,
        isRecurring: _isRecurring,
        recurrence: _recurrence,
        hasNotification: _hasNotification,
        color: _eventColor,
      );

      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      if (widget.event == null) {
        eventProvider.addEvent(newEvent);
      } else {
        eventProvider.updateEvent(widget.event!, newEvent);
      }

      Navigator.pop(context);
    }
  }

  Widget _buildRecurrenceOptions() {
    if (!_isRecurring) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recurrence Pattern:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: Recurrence.values
                .where((r) => r != Recurrence.none)
                .map((recurrence) {
              return ChoiceChip(
                label: Text(
                  recurrence.toString().split('.').last,
                  style: TextStyle(
                    color: _recurrence == recurrence 
                        ? Colors.white 
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                selected: _recurrence == recurrence,
                selectedColor: Theme.of(context).primaryColor,
                onSelected: (selected) {
                  setState(() {
                    _recurrence = recurrence;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Color:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: _availableColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _eventColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: _eventColor == color
                        ? Border.all(
                            color: Colors.black,
                            width: 3,
                          )
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveEvent,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onChanged: (value) => _title = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => _description = value,
              ),
              SizedBox(height: 16),
              _buildColorSelection(),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text('Date'),
                        subtitle: Text(DateFormat.yMMMd().format(_date)),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                      Divider(),
                      ListTile(
                        title: Text('Time'),
                        subtitle: Text(_time.format(context)),
                        trailing: Icon(Icons.access_time),
                        onTap: () => _selectTime(context),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Recurring Event'),
                      value: _isRecurring,
                      onChanged: (value) {
                        setState(() {
                          _isRecurring = value;
                          if (!value) _recurrence = Recurrence.none;
                        });
                      },
                    ),
                    _buildRecurrenceOptions(),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: Text('Set Notification'),
                  value: _hasNotification,
                  onChanged: (value) {
                    setState(() {
                      _hasNotification = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveEvent,
                child: Text('SAVE EVENT'),
              ),
              if (widget.event != null) ...[
                SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.red),
                  ),
                  child: Text(
                    'DELETE EVENT',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Event'),
                        content: Text('Are you sure you want to delete this event?'),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Provider.of<EventProvider>(context, listen: false)
                                  .deleteEvent(widget.event!);
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Close editor
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
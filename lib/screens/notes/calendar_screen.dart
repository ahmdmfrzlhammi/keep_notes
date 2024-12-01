import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  Stream<QuerySnapshot> getCalendarEvents() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.empty();
    }
    return _db
        .collection('calendar_events')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .snapshots();
  }

  void _showEventsForDay(DateTime day) {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _db
        .collection('calendar_events')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(day))
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Events on ${day.day}/${day.month}/${day.year}'),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = snapshot.docs[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(doc['event']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditDialog(doc);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteEvent(doc.id);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      }
    });
  }

  void _showAddEventDialog() {
    TextEditingController eventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Event'),
        content: TextField(
          controller: eventController,
          decoration: InputDecoration(labelText: 'Event'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (eventController.text.isNotEmpty) {
                _addEvent(eventController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addEvent(String event) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _db.collection('calendar_events').add({
          'userId': userId,
          'event': event,
          'date': Timestamp.fromDate(_selectedDay),
        });
      }
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  void _showEditDialog(DocumentSnapshot event) {
    TextEditingController eventController =
        TextEditingController(text: event['event']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Event'),
        content: TextField(
          controller: eventController,
          decoration: InputDecoration(labelText: 'Event'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _updateEvent(event.id, eventController.text);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateEvent(String docId, String event) async {
    try {
      await _db.collection('calendar_events').doc(docId).update({
        'event': event,
      });
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  Future<void> _deleteEvent(String docId) async {
    try {
      await _db.collection('calendar_events').doc(docId).delete();
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Your Events',
          textAlign: TextAlign.center, // Title center alignment
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Ensuring navigation back works properly
            context.go('/');
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getCalendarEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading events'));
          }

          Map<DateTime, List<dynamic>> eventDates = {};
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              DateTime date = (doc['date'] as Timestamp).toDate();
              DateTime normalizedDate = DateTime(date.year, date.month, date.day);
              if (eventDates[normalizedDate] == null) {
                eventDates[normalizedDate] = [];
              }
              eventDates[normalizedDate]!.add(doc['event']);
            }
          }

          return Column(
            children: [
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime(2020),
                lastDay: DateTime(2025),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _showEventsForDay(selectedDay);
                },
                eventLoader: (day) {
                  return eventDates[DateTime(day.year, day.month, day.day)] ?? [];
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _showAddEventDialog,
                child: Text('Add Event'),
              ),
            ],
          );
        },
      ),
    );
  }
}

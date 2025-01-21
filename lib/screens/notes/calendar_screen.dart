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
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _focusedDay = DateTime(now.year, now.month, now.day);
  }

  Stream<QuerySnapshot> getCalendarEvents() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.empty();
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
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        'Events on ${day.day}/${day.month}/${day.year}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.docs[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            doc['event'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit_rounded, color: Colors.blue[600]),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showEditDialog(doc);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_rounded, color: Colors.red[400]),
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
              ],
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add New Event',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: eventController,
          decoration: InputDecoration(
            labelText: 'Event Details',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (eventController.text.isNotEmpty) {
                _addEvent(eventController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Add Event',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
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
    TextEditingController eventController = TextEditingController(text: event['event']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Event',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: eventController,
          decoration: InputDecoration(
            labelText: 'Event Details',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _updateEvent(event.id, eventController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Save Changes',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
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
    final now = DateTime.now();
    final firstDay = DateTime(now.year - 2, now.month, now.day);
    final lastDay = DateTime(now.year + 2, now.month, now.day);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'My Calendar',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => context.go('/'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getCalendarEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading events',
                style: TextStyle(color: Colors.red[400]),
              ),
            );
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
              Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: firstDay,
                  lastDay: lastDay,
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
                  calendarStyle: CalendarStyle(
                    markersAlignment: Alignment.bottomCenter,
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isNotEmpty) {
                        return Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: _showAddEventDialog,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    minimumSize: Size(double.infinity, 0),
                  ),
                  child: Text(
                    'Add New Event',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
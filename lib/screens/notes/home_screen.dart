import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_notes/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Keep Notes"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.read(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notes available.'));
          }

          final notes = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Jumlah kolom
                crossAxisSpacing: 8, // Jarak horizontal antar kotak
                mainAxisSpacing: 8, // Jarak vertikal antar kotak
                childAspectRatio: 1, // Proporsi lebar dan tinggi kotak
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                var note = notes[index];
                var createdAt = note['timestamp'] as Timestamp?;
                var formattedDate = createdAt != null
                    ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
                    : 'No date';

                return GestureDetector(
                  onTap: () => context.go('/edit/${note.id}'),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            note['content'],
                            style: TextStyle(fontSize: 14),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacer(),
                          Text(
                            'Created: $formattedDate',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create'),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      persistentFooterButtons: [
        ElevatedButton.icon(
          onPressed: () {
            context.go('/calendar');
          },
          icon: Icon(Icons.calendar_today),
          label: Text('Go to Calendar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 243, 33, 33),
          ),
        ),
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_notes/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  Future<String?> _getUsername(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return data['username'] as String?;
      }
    } catch (e) {
      debugPrint("Error fetching username: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = _isDarkMode 
      ? ThemeData.dark().copyWith(
          primaryColor: Colors.tealAccent,
          scaffoldBackgroundColor: Color(0xFF121212),
          cardColor: Color(0xFF1E1E1E),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF121212),
            elevation: 0,
          ),
        )
      : ThemeData.light().copyWith(
          primaryColor: Theme.of(context).primaryColor,
          scaffoldBackgroundColor: Colors.white,
        );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: FutureBuilder<String?>(
            future: _getUsername(FirebaseAuth.instance.currentUser!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading...", 
                  style: TextStyle(color: _isDarkMode ? Colors.grey : Colors.grey[600]));
              } else if (snapshot.hasError) {
                return Text("Error", style: TextStyle(color: Colors.red));
              } else if (snapshot.hasData) {
                return Text(
                  "Hello ${snapshot.data}!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                );
              } else {
                return Text(
                  "Keep Notes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                );
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: _isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
              onPressed: _toggleTheme,
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                color: _isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                context.go('/login');
              },
            ),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                color: _isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
              onPressed: () {
                context.go('/about');
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _isDarkMode
                  ? [
                      Color(0xFF1A1A1A),
                      Color(0xFF121212),
                    ]
                  : [
                      Colors.grey.withOpacity(0.1),
                      Colors.white,
                    ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: _isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search notes...',
                      hintStyle: TextStyle(
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _firestoreService.read() as Stream<QuerySnapshot>,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isDarkMode ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red),
                            SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.note_add,
                              size: 48,
                              color: _isDarkMode ? Colors.white54 : Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No notes available.\nCreate your first note!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isDarkMode ? Colors.white54 : Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final notes = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title = data['title'].toString().toLowerCase();
                      final content = data['content'].toString().toLowerCase();
                      return title.contains(_searchQuery) ||
                          content.contains(_searchQuery);
                    }).toList();

                    if (notes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: _isDarkMode ? Colors.white54 : Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No matching notes found',
                              style: TextStyle(
                                color: _isDarkMode ? Colors.white54 : Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final doc = notes[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final createdAt = data['timestamp'] as Timestamp?;
                          final formattedDate = createdAt != null
                              ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
                              : 'No date';

                          return GestureDetector(
                            onTap: () => context.go('/edit/${doc.id}'),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: _isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _isDarkMode
                                        ? [
                                            Color(0xFF2C2C2C),
                                            Color(0xFF252525),
                                          ]
                                        : [
                                            Colors.white,
                                            Colors.grey.shade50,
                                          ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: _isDarkMode ? Colors.white : Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    Expanded(
                                      child: Text(
                                        data['content'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                          height: 1.5,
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Divider(
                                      color: _isDarkMode
                                          ? Colors.white24
                                          : Colors.grey[300],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: _isDarkMode
                                              ? Colors.white54
                                              : Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _isDarkMode
                                                ? Colors.white54
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
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
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/create'),
          child: Icon(Icons.add),
          backgroundColor: _isDarkMode ? Colors.tealAccent : Theme.of(context).primaryColor,
          foregroundColor: _isDarkMode ? Colors.black : Colors.white,
          elevation: 4,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        persistentFooterButtons: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/calendar'),
                    icon: Icon(Icons.calendar_today),
                    label: Text(
                      'Calendar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDarkMode
                          ? Colors.tealAccent
                          : const Color.fromARGB(255, 72, 78, 97),
                      foregroundColor: _isDarkMode ? Colors.black : Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/archives'),
                    icon: Icon(Icons.archive),
                    label: Text(
                      'Archives',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isDarkMode
                          ? Colors.tealAccent
                          : const Color.fromARGB(255, 72, 78, 97),
                      foregroundColor: _isDarkMode ? Colors.black : Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
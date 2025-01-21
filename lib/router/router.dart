import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_notes/screens/auth/forgot_password_screen.dart';
import 'package:keep_notes/screens/auth/login_screen.dart';
import 'package:keep_notes/screens/auth/register_screen.dart';
import 'package:keep_notes/screens/notes/archived_notes_screen.dart';
import 'package:keep_notes/screens/notes/biodata_screen.dart';
import 'package:keep_notes/screens/notes/calendar_screen.dart';
import 'package:keep_notes/screens/notes/home_screen.dart';
import 'package:keep_notes/screens/notes/add_note_screen.dart';
import 'package:keep_notes/screens/notes/edit_note_screen.dart';

final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoggingIn = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/register' ||
                       state.matchedLocation == '/forgot-password';
    
    if (!isLoggedIn && !isLoggingIn) {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    // Halaman Register
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => ForgotPasswordScreen(),
    ),
    // Halaman Home
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    // Halaman untuk Menambahkan Catatan
    GoRoute(
      path: '/create',
      builder: (context, state) => CreateNoteScreen(),
    ),
    GoRoute(
      path: '/about',
       builder: (context, state) => BiodataScreen(),
    ),
    // Halaman untuk Mengedit Catatan
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final noteId = state.pathParameters['id']!;
        return EditNoteScreen(noteId: noteId);
      },
    ),
    GoRoute(
      path: '/archives',
       builder: (context, state) => ArchivedNotesScreen(),
    ),
    GoRoute(
    path: '/calendar',
    builder: (context, state) => CalendarScreen(),
    ),
  ],
);

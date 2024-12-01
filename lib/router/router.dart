import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_notes/screens/auth/login_screen.dart';
import 'package:keep_notes/screens/auth/register_screen.dart';
import 'package:keep_notes/screens/notes/calendar_screen.dart';
import 'package:keep_notes/screens/notes/home_screen.dart';
import 'package:keep_notes/screens/notes/add_note_screen.dart';
import 'package:keep_notes/screens/notes/edit_note_screen.dart';

final router = GoRouter(
  initialLocation: '/login', // Arahkan awal ke halaman login
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    // Jika pengguna tidak login dan mencoba mengakses halaman selain login/register
    if (!isLoggedIn && !isLoggingIn) {
      return '/login'; // Jika belum login, arahkan ke halaman login
    }

    return null; // Tidak ada pengalihan jika pengguna sudah login atau berada di halaman login/register
  },
  routes: [
    // Halaman Login
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    // Halaman Register
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
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
    // Halaman untuk Mengedit Catatan
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final noteId = state.pathParameters['id']!;
        return EditNoteScreen(noteId: noteId);
      },
    ),
    GoRoute(
    path: '/calendar',
    builder: (context, state) => CalendarScreen(),
    ),
  ],
);

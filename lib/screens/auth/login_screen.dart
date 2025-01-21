import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;  // Untuk menambahkan indikator loading

  // Fungsi untuk login
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cek apakah email dan password tidak kosong
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        _showErrorDialog("Login Failed", "Email or password cannot be empty");
        return;
      }

      // Cek format email
      if (!_isValidEmail(_emailController.text)) {
        _showErrorDialog("Login Failed", "Please enter a valid email address");
        return;
      }

      // Melakukan login menggunakan Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Arahkan ke halaman utama setelah login berhasil
      context.go('/');
    } on FirebaseAuthException catch (e) {
      // Menampilkan error jika login gagal
      _showErrorDialog("Login Failed", e.message ?? "An error occurred");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk validasi format email
  bool _isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  // Fungsi untuk menampilkan dialog error
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk reset password
  Future<void> _resetPassword() async {
    try {
      if (_emailController.text.isEmpty) {
        throw Exception("Please enter your email address");
      }
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Password Reset Email Sent"),
          content: Text("Please check your email to reset your password."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorDialog("Password Reset Failed", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 36, 76, 163), const Color.fromARGB(255, 64, 151, 251)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 39, 39, 39),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Selamat datang di aplikasi KeepNotes',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _resetPassword,
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login, // Nonaktifkan tombol saat loading
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 2, 1, 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: Text(
                            "Don't have an account? Register here",
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

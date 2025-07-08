import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;

  Future<void> loginUser() async {
    setState(() => loading = true);
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      // Sign in with Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      prefs.setString('userEmail', email);

      // Fetch user document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();

      if (!userDoc.exists) {
        showError("User document not found. Please sign up first.");
        Navigator.pushReplacementNamed(context, '/donorSignUp');
        return;
      }

      final role = userDoc.data()?['role'] ?? 'unknown';
      prefs.setString('userRole', role);

      switch (role) {
        case 'volunteer':
          Navigator.pushReplacementNamed(context, '/volunteerDashboard');
          break;
        case 'admin':
          Navigator.pushReplacementNamed(context, '/adminDashboard');
          break;
        case 'donor':
          Navigator.pushReplacementNamed(context, '/donorDashboard');
          break;
        case 'employee':
          Navigator.pushReplacementNamed(context, '/employeeDashboard');
          break;
        default:
          showError('Unknown role: $role');
      }
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? 'Login failed.');
    } catch (e) {
      showError('Something went wrong.');
    } finally {
      setState(() => loading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginUser,
                    child: const Text('Login'),
                  ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/donorSignUp');
              },
              child: const Text("Don't have an account? Sign up here"),
            ),
          ],
        ),
      ),
    );
  }
}

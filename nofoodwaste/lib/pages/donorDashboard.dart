import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Donordashboard extends StatelessWidget {
  const Donordashboard({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(
      context,
      '/login',
    ); // Ensure '/login' is defined in your routes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donor Dashboard'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Raise Donation Request'),
              onPressed: () {
                Navigator.pushNamed(context, '/DonarRequestForm');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('View Donation History'),
              onPressed: () {
                Navigator.pushNamed(context, '/DonationHistoryPage');
              },
            ),
          ],
        ),
      ),
    );
  }
}

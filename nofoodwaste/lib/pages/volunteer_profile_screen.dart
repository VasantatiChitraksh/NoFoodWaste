import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VolunteerProfileScreen extends StatefulWidget {
  const VolunteerProfileScreen({super.key});

  @override
  State<VolunteerProfileScreen> createState() => _VolunteerProfileScreenState();
}

class _VolunteerProfileScreenState extends State<VolunteerProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? volunteerData;

  @override
  void initState() {
    super.initState();
    fetchVolunteerInfo();
  }

  Future<void> fetchVolunteerInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          volunteerData = doc.data();
        });
      }
    }
  }

  void logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Adjust route as needed
  }

  @override
  Widget build(BuildContext context) {
    final String name = volunteerData?['name'] ?? 'Volunteer';
    final String email = _auth.currentUser?.email ?? 'No Email';
    final String phone = volunteerData?['phone'] ?? 'Not Available';

    return Scaffold(
      appBar: AppBar(title: Text('Profile'), backgroundColor: Colors.green, automaticallyImplyLeading: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.person, size: 80, color: Colors.green),
            SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(email),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text("Phone"),
              subtitle: Text(phone),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: logout,
              icon: Icon(Icons.logout),
              label: Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

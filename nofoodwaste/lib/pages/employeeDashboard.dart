import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic>? taskData;
  String? taskDocId;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    fetchTask();
  }

  Future<void> fetchTask() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('employee_tasks')
        .doc(user!.email)
        .get();

    if (doc.exists) {
      setState(() {
        taskData = doc.data();
        taskDocId = doc.id;
      });
    }
  }

  void logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> markAsCompleted() async {
    if (user == null || taskDocId == null) return;

    await FirebaseFirestore.instance
        .collection('employee_tasks')
        .doc(taskDocId!)
        .update({'availability': true, 'task': '', 'location': GeoPoint(0, 0)});

    await fetchTask();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Task marked as completed")));
  }

  @override
  Widget build(BuildContext context) {
    final String name = user?.displayName ?? "Employee";
    final String email = user?.email ?? "No Email";

    double lat = 13.0827;
    double lng = 80.2707;

    if (taskData?['location'] != null && taskData!['location'] is GeoPoint) {
      final GeoPoint geo = taskData!['location'];
      lat = geo.latitude;
      lng = geo.longitude;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Dashboard"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),

            taskData != null
                ? Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Assigned Task",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text("Task: ${taskData?['task'] ?? 'N/A'}"),
                          SizedBox(height: 8),
                          Text("Donor Location:"),
                          SizedBox(height: 10),
                          Container(
                            height: 150,
                            child: FlutterMap(
                              options: MapOptions(
                                center: LatLng(lat, lng),
                                zoom: 14.0,
                                interactiveFlags: InteractiveFlag.none,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: ['a', 'b', 'c'],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(lat, lng),
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        Icons.location_pin,
                                        color: Colors.red,
                                        size: 36,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text("Latitude: $lat"),
                          Text("Longitude: $lng"),
                          SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: markAsCompleted,
                              icon: Icon(Icons.check),
                              label: Text("Mark as Completed"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(child: Text("No task assigned currently.")),
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

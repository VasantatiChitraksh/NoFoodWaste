import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nofoodwaste/pages/updateHungerSpot.dart';
import 'volunteer_history_screen.dart';
import 'food_acceptance_page.dart';

class Volunteerdashboard extends StatefulWidget {
  const Volunteerdashboard({super.key});

  @override
  State<Volunteerdashboard> createState() => _VolunteerdashboardState();
}

class _VolunteerdashboardState extends State<Volunteerdashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isAvailable = true;
  Map<String, dynamic>? volunteerData;
  int _currentIndex = 0;
  Position? _currentPosition;
  List<DocumentSnapshot> _filteredDonations = [];

  @override
  void initState() {
    super.initState();
    fetchVolunteerInfo();
    fetchDonations();
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
          isAvailable = doc['available'] ?? true;
        });
      }
    }
  }

<<<<<<< HEAD
  Future<void> determinePositionAndFetchDonations() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print(
      'Current volunteer location: ${position.latitude}, ${position.longitude}',
    );
    setState(() => _currentPosition = position);
    final donations = await getValidDonations(position);
    setState(() => _filteredDonations = donations);
  }

  double getDistance(lat1, lon1, lat2, lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<DocumentSnapshot?> getNearestHungerPoint(Position volunteerPos) async {
    final points = await FirebaseFirestore.instance
        .collection('hunger_points')
        .where('validity', isEqualTo: true)
        .get();

    double minDistance = double.infinity;
    DocumentSnapshot? nearestPoint;

    for (var doc in points.docs) {
      List location = doc['location'];
      double dist = getDistance(
        volunteerPos.latitude,
        volunteerPos.longitude,
        location[0],
        location[1],
      );
      if (dist < minDistance) {
        minDistance = dist;
        nearestPoint = doc;
      }
    }

    return nearestPoint;
  }

  Future<List<DocumentSnapshot>> getValidDonations(
    Position volunteerPos,
  ) async {
    final nearestPoint = await getNearestHungerPoint(volunteerPos);
    if (nearestPoint == null) return [];

    List hpLoc = nearestPoint['location'];
    final allDonations = await FirebaseFirestore.instance
        .collection('donation_requests')
        .get();

=======
  Future<void> fetchDonations() async {
    final allDonations = await FirebaseFirestore.instance
        .collection('donation_requests')
        .get();
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
    final now = DateTime.now();
    List<DocumentSnapshot> valid = [];

    for (var doc in allDonations.docs) {
      final data = doc.data();

<<<<<<< HEAD
      if (data['accept'] == true || data['picked'] == true) continue;
      if (data['location'] == null || data['location'].length != 2) continue;
      if (data['cookedTime'] == null || data['cookedTime'] is! Timestamp)
        continue;

      List loc = data['location'];
      final cookedTime = (data['cookedTime'] as Timestamp).toDate();
      final expiryTime = cookedTime.add(Duration(hours: 2));
      final timeLeft = expiryTime.difference(now).inMinutes;
      if (timeLeft <= 45) continue;

      final distance = getDistance(loc[0], loc[1], hpLoc[0], hpLoc[1]) / 1000;
      if (distance <= 22.5) {
        valid.add(doc);
=======
      if (data['accept'] == true && data['acceptedBy'] == "none") {
        if (data['meals'] != null && data['meals'] < 50) {
          valid.add(doc);
        }
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
      }
    }

    setState(() => _filteredDonations = valid);
  }

  Future<void> updateAvailability(bool value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'available': value},
      );
    }
  }

  Future<void> acceptDonation(String donationId, String location) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('donation_requests')
          .doc(donationId)
          .update({'accept': true, 'acceptedBy': user.email});
<<<<<<< HEAD
=======
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodAcceptancePage(location: location),
        ),
      );
      fetchDonations();
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
    }
  }

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 1:
        Navigator.push(
          context,
<<<<<<< HEAD
          MaterialPageRoute(builder: (context) => VolunteerHistoryScreen()),
=======
          MaterialPageRoute(
            builder: (context) => const VolunteerHistoryScreen(),
          ),
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UpdateHungerSpotScreen()),
        );
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String volunteerName = volunteerData?['name'] ?? 'Volunteer';
    final String volunteerPhone = volunteerData?['phone'] ?? 'Not Available';

    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: Text("Volunteer Dashboard"),
=======
        title: const Text("Volunteer Dashboard"),
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Container(
<<<<<<< HEAD
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(10),
=======
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(10),
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      volunteerName,
<<<<<<< HEAD
                      style: TextStyle(
=======
                      style: const TextStyle(
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
<<<<<<< HEAD
                    SizedBox(height: 4),
=======
                    const SizedBox(height: 4),
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
                    Text("Phone: $volunteerPhone"),
                  ],
                ),
                Column(
                  children: [
<<<<<<< HEAD
                    Text("Available"),
=======
                    const Text("Available"),
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
                    Switch(
                      value: isAvailable,
                      onChanged: (value) {
                        setState(() => isAvailable = value);
                        updateAvailability(value);
                      },
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredDonations.isEmpty
                ? const Center(child: Text("No valid donations available now."))
                : ListView.builder(
                    itemCount: _filteredDonations.length,
                    itemBuilder: (context, index) {
                      final data =
                          _filteredDonations[index].data()
                              as Map<String, dynamic>;
                      return Card(
<<<<<<< HEAD
                        margin: EdgeInsets.symmetric(
=======
                        margin: const EdgeInsets.symmetric(
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Contact: ${data['contact'] ?? 'N/A'}",
<<<<<<< HEAD
                                style: TextStyle(fontWeight: FontWeight.bold),
=======
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
                              ),
                              Text(
                                "Description: ${data['description'] ?? 'N/A'}",
                              ),
                              Text("Meals: ${data['meals'] ?? 'N/A'}"),
                              Text("Location: ${data['location'] ?? 'N/A'}"),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () => acceptDonation(
                                    _filteredDonations[index].id,
<<<<<<< HEAD
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text("Accept"),
=======
                                    (data['location']?.toString() ?? 'N/A'),
                                  ),
                                  child: const Text("Accept"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
>>>>>>> f093567fce221ccdf6327905de419734bf02a151
                                ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Update HungerSpot",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

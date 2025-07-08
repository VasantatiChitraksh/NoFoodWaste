// File: update_hunger_spot_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'HungerSpotUpdate.dart';

class UpdateHungerSpotScreen extends StatefulWidget {
  const UpdateHungerSpotScreen({super.key});

  @override
  State<UpdateHungerSpotScreen> createState() => _UpdateHungerSpotScreenState();
}

class _UpdateHungerSpotScreenState extends State<UpdateHungerSpotScreen> {
  final CollectionReference _spotsRef =
      FirebaseFirestore.instance.collection('hunger_points');

  String location = '';
  GeoPoint? geoLocation;

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        location = 'Permission denied';
        geoLocation = null;
      });
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      geoLocation = GeoPoint(pos.latitude, pos.longitude);
      location = '${pos.latitude}, ${pos.longitude}';
    });
  }

  String formatLocation(dynamic loc) {
    if (loc is List && loc.length == 2) {
      return '${loc[0]}, ${loc[1]}';
    } else if (loc is GeoPoint) {
      return '${loc.latitude}, ${loc.longitude}';
    } else {
      return 'Unknown Location';
    }
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update HungerSpots"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Available HungerSpots:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: _spotsRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              final spots = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: spots.length,
                itemBuilder: (context, index) {
                  final data = spots[index].data() as Map<String, dynamic>? ?? {};
                  final docId = spots[index].id;

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text(data['Name']?.toString() ?? 'No Name'),
                      subtitle: Text(formatLocation(data['location'])),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HungerSpotUpdateRequestPage(
                                name: data['Name'] ?? '',
                                isAddition: false,
                              ),
                            ),
                          );
                        },
                        child: Text("Request Delete"),
                        style:
                            ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HungerSpotUpdateRequestPage(
                        name: '',
                        isAddition: true,
                      ),
                    ),
                  );
                },
                child: Text("Request Add HungerSpot"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
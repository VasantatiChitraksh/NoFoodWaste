import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'food_details_form_page.dart';

class FoodAcceptancePage extends StatelessWidget {
  final String location;

  const FoodAcceptancePage({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    // Expecting location format as "latitude,longitude"
    final List<String> parts = location.split(',');
    final double latitude = double.tryParse(parts[0].trim()) ?? 13.0827;
    final double longitude = double.tryParse(parts[1].trim()) ?? 80.2707;

    return Scaffold(
      appBar: AppBar(
        title: Text('Food Acceptance'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              "Accepted the Request",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Please go to the specified Location given below",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // MAP DISPLAY
            GestureDetector(
              onTap: () {
                // Enlarged map view on tap
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Location Preview'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 200,
                          child: FlutterMap(
                            options: MapOptions(
                              center: LatLng(latitude, longitude),
                              zoom: 15.0,
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
                                    point: LatLng(latitude, longitude),
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
                        SizedBox(height: 10),
                        Text('Latitude: $latitude\nLongitude: $longitude'),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                height: 150,
                margin: EdgeInsets.symmetric(vertical: 10),
                child: FlutterMap(
                  options: MapOptions(
                    center: LatLng(latitude, longitude),
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
                          point: LatLng(latitude, longitude),
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
            ),

            // DISPLAY LAT LNG BELOW MAP
            Text(
              'Latitude: $latitude',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Text(
              'Longitude: $longitude',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),

            SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FoodDetailsFormPage(location: location),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text("Accept Food"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Food Declined')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text("Decline Food"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

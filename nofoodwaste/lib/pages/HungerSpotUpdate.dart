// File 2: hunger_spot_update_request_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class HungerSpotUpdateRequestPage extends StatefulWidget {
  final String name;
  final bool isAddition;

  const HungerSpotUpdateRequestPage({
    super.key,
    required this.name,
    required this.isAddition,
  });

  @override
  State<HungerSpotUpdateRequestPage> createState() => _HungerSpotUpdateRequestPageState();
}

class _HungerSpotUpdateRequestPageState extends State<HungerSpotUpdateRequestPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  bool isSubmitting = false;

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
    });
  }

  Future<void> _submitUpdate() async {
    final name = _nameController.text.trim();
    final detail = _detailController.text.trim();
    final lat = double.tryParse(_latitudeController.text.trim());
    final lng = double.tryParse(_longitudeController.text.trim());

    if (name.isEmpty || detail.isEmpty || lat == null || lng == null) return;

    setState(() => isSubmitting = true);
    await FirebaseFirestore.instance.collection('hunger_spots_update').add({
      'name': name,
      'detail': detail,
      'request': widget.isAddition,
      'location': [lat, lng],
    });

    setState(() => isSubmitting = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update request submitted')),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Submit Update Request"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Spot Name", style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _nameController,
                readOnly: !widget.isAddition,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              Text("Details", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: _detailController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Describe the update...",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text("Latitude", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: _latitudeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Latitude",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text("Longitude", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: _longitudeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Longitude",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: Text("Use Current Location"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submitUpdate,
                child: isSubmitting ? CircularProgressIndicator() : Text("Submit"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              )
            ],
          ),
        ),
      ),
    );
  }
}

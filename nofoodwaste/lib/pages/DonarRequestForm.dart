import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geocoding_platform_interface/src/models/placemark.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
double? capturedLat;
double? capturedLon;


class DonarRequestForm extends StatefulWidget {
  const DonarRequestForm({super.key});

  @override
  State<DonarRequestForm> createState() => _DonarRequestFormState();
}

class _DonarRequestFormState extends State<DonarRequestForm> {
  final TextEditingController donorNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController prepTimeController = TextEditingController();
  final TextEditingController expiryTimeController = TextEditingController();
  final TextEditingController specialNotesController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String urgency = 'Today';
  File? _selectedImage;

  // ✅ Nominatim fallback if geocoding fails
  Future<String> getAddressFromNominatim(double lat, double lon) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon',
  );

  final response = await http.get(url, headers: {
    'User-Agent': 'nofoodwaste-app/1.0 (youremail@example.com)' // Update this!
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['display_name'] ?? 'Unknown location';
  } else {
    throw Exception('Failed to fetch address');
  }
}


  // ✅ LOCATION FETCH
Future<void> _getCoordinatesOnly() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('❌ Location services are disabled. Enable them in settings.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      _showError('❌ Location permission permanently denied. Enable it from app settings.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    double lat = position.latitude;
    double lon = position.longitude;

    _showError("📍 Coordinates captured: ($lat, $lon)");

    setState(() {
      capturedLat = lat;
      capturedLon = lon;
      locationController.text = "$lat, $lon"; // 💡 Fill the field
    });

  } catch (e) {
    _showError('❌ Error fetching location: $e');
  }
}



  // ✅ IMAGE PICKER
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        print("✅ Selected Image: ${pickedFile.path}");
      } else {
        _showError('No image selected.');
      }
    } catch (e) {
      _showError('Error picking image: $e');
      print("❌ Image picker error: $e");
    }
  }

  // ✅ SnackBar Utility
  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ✅ UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raise a Food Donation Request'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField('Donor Name', donorNameController),
            _buildInputField('Contact Number / Email', contactController),
      

            const SizedBox(height: 10),
            _buildInputField('Location (Latitude, Longitude)', locationController, readOnly: true),

              ElevatedButton.icon(
  onPressed: _getCoordinatesOnly,
  icon: const Icon(Icons.location_on),
  label: const Text("Capture Coordinates"),
),

            const SizedBox(height: 16),
            _buildInputField('Quantity (No. of People)', quantityController),
            _buildInputField('Preparation Time', prepTimeController),
            _buildInputField('Expiry Time', expiryTimeController),
            _buildInputField('Special Notes (optional)', specialNotesController),

            const SizedBox(height: 16),
            const Text("Urgency Level"),
            DropdownButton<String>(
              value: urgency,
              items: ['Within 1 hour', 'Today', 'Tomorrow']
                  .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                  .toList(),
              onChanged: (value) => setState(() => urgency = value!),
            ),

            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.image),
                label: const Text('Upload Food Image'),
              ),
            ),

            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(child: Image.file(_selectedImage!, height: 200)),
              ),

            const SizedBox(height: 20),
            Center(
  child: ElevatedButton(
    onPressed: () async {
      try {
        if (contactController.text.isEmpty ||
    quantityController.text.isEmpty ||
    prepTimeController.text.isEmpty ||
    specialNotesController.text.isEmpty) {
  _showError("⚠️ Please fill all required fields.");
  return;
}


    // 🌍 Convert address to coordinates
if (capturedLat == null || capturedLon == null) {
  _showError("⚠️ Please capture your coordinates first.");
  return;
}
double lat = capturedLat!;
double lon = capturedLon!;

// 🍛 Meals
int meals = int.tryParse(quantityController.text.trim()) ?? 0;

// 🕒 Parse preparation time to DateTime
final now = DateTime.now();
final timeParts = prepTimeController.text.split(":");
final cookedTime = DateTime(
  now.year,
  now.month,
  now.day,
  int.parse(timeParts[0]),
  int.parse(timeParts[1]),
);

// ✅ Accept logic based on latitude and meals
bool accept = (lat >= 11.098 && lat <= 14.098) && meals > 50;

// 🔥 Upload to Firestore
await FirebaseFirestore.instance.collection('donation_requests').add({
  "acceptedBy": null,
  "contact": contactController.text.trim(),
  "cookedTime": Timestamp.fromDate(cookedTime),
  "description": specialNotesController.text.trim(),
  "location": [lat, lon],
  "meals": meals,
  "accept": accept,
});


        _showError("✅ Donation submitted successfully!");
      } catch (e) {
        _showError("❌ Error: $e");
      }
    }, // ✅ Comma added here
    child: const Text('Submit Donation Request'),
  ),
),

          ],
        ),
      ),
    );
  }

 Widget _buildInputField(String label, TextEditingController controller, {bool readOnly = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

}

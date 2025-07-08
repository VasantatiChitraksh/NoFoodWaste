import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
// ignore: depend_on_referenced_packages
import 'package:gal/gal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FoodDetailsFormPage extends StatefulWidget {
  final String location;

  const FoodDetailsFormPage({super.key, required this.location});

  @override
  _FoodDetailsFormPageState createState() => _FoodDetailsFormPageState();
}

class _FoodDetailsFormPageState extends State<FoodDetailsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _foodItemsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    // Request camera permission for camera, photos permission for gallery
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      // For newer Android versions, use photos permission
      status = await Permission.photos.request();
      // Fallback to storage permission for older versions
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
    }

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(source == ImageSource.camera 
              ? "Camera permission is required." 
              : "Photos permission is required."),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveImageToGallery() async {
    if (_image == null) return;

    try {
      // Check if gal has permission
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        // Request permission
        final hasPermission = await Gal.requestAccess();
        if (!hasPermission) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gallery permission required to save image")),
          );
          return;
        }
      }

      // Save image to gallery using gal
      await Gal.putImage(_image!.path);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image saved to gallery successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving image: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _foodItemsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = _auth.currentUser;
        if (user == null) {
          throw Exception("User not authenticated");
        }

        // Save image to gallery if available
        if (_image != null) {
          await _saveImageToGallery();
        }

        // Save form data to Firestore
        await FirebaseFirestore.instance.collection('food_distributions').add({
          'foodItems': _foodItemsController.text.trim(),
          'description': _descriptionController.text.trim(),
          'location': widget.location,
          'volunteerEmail': user.email,
          'volunteerUid': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'hasImage': _image != null,
          'status': 'completed',
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Food distribution details saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _foodItemsController.clear();
        _descriptionController.clear();
        setState(() {
          _image = null;
        });

        await FirebaseFirestore.instance.collection('volunteer_history').add({
          'volunteerEmail': user.email,
          'timestamp': FieldValue.serverTimestamp(),
          'foodItems': _foodItemsController.text.trim(),
          'description': _descriptionController.text.trim(),
          'location': widget.location,
          'imageSaved': _image != null,
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.email)
            .update({
          'volunteers': FieldValue.increment(1)
        });

        // Navigate back after a short delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushNamed(context, '/volunteerDashboard');
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error submitting form: $e"),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_image != null)
                ListTile(
                  leading: Icon(Icons.save_alt),
                  title: Text('Save Current Image to Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _saveImageToGallery();
                  },
                ),
              if (_image != null)
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Remove Image'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _image = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Distribution Details"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Record Food Distribution",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Fill in the details of the food distribution",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 24),

              // Food items
              TextFormField(
                controller: _foodItemsController,
                decoration: InputDecoration(
                  labelText: "Food Items Distributed",
                  hintText: "e.g., Rice, Dal, Vegetables",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.restaurant),
                ),
                maxLines: 2,
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter food items" : null,
              ),
              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Additional Details",
                  hintText: "Number of people served, special notes, etc.",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter description" : null,
              ),
              SizedBox(height: 16),

              // Location (read-only)
              TextFormField(
                initialValue: widget.location,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Distribution Location",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.location_on),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              SizedBox(height: 24),

              // Image section
              Text(
                "Photo Documentation",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: 8),
              
              // Image display area
              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Tap to add photo",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "(Optional)",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              if (_image != null) ...[
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _saveImageToGallery,
                      icon: Icon(Icons.save_alt),
                      label: Text("Save to Gallery"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _showImageOptions,
                      icon: Icon(Icons.edit),
                      label: Text("Change Image"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text("Submitting..."),
                          ],
                        )
                      : Text(
                          "Submit Distribution Record",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 16),
              
              // Note
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Images will be saved to your device gallery and distribution details will be recorded.",
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'updateHungerSpot.dart';

class VolunteerHistoryScreen extends StatefulWidget {
  const VolunteerHistoryScreen({super.key});

  @override
  State<VolunteerHistoryScreen> createState() => _VolunteerHistoryScreenState();
}

class _VolunteerHistoryScreenState extends State<VolunteerHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String volunteerId = '';
  int totalMealsDelivered = 0;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        volunteerId = user.uid;
      });
      _calculateTotalMeals();
    }
  }

  Future<void> _calculateTotalMeals() async {
    try {
      print('Calculating meals for email: ${_auth.currentUser?.email}');
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('volunteer_history')
          .where('volunteerEmail', isEqualTo: _auth.currentUser?.email ?? '')
          .get();

      print('Found ${querySnapshot.docs.length} documents');

      int totalMeals = 0;
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        print('Document data: $data');
        final foodItems = data['foodItems'] as String? ?? '';
        // Count meals based on food items (you can adjust this logic)
        // For now, counting each delivery as helping 3-5 people on average
        int meals = _estimateMealsFromFoodItems(foodItems);
        totalMeals += meals;
        print('Food items: $foodItems, Estimated meals: $meals');
      }

      print('Total meals calculated: $totalMeals');
      setState(() {
        totalMealsDelivered = totalMeals;
      });
    } catch (e) {
      print('Error calculating meals: $e');
    }
  }

  int _estimateMealsFromFoodItems(String foodItems) {
    // Simple estimation logic - you can make this more sophisticated
    if (foodItems.toLowerCase().contains('rice') || 
        foodItems.toLowerCase().contains('meal') ||
        foodItems.toLowerCase().contains('dinner') ||
        foodItems.toLowerCase().contains('lunch')) {
      return 5; // Assume full meals serve 5 people
    } else if (foodItems.toLowerCase().contains('snack') ||
               foodItems.toLowerCase().contains('bread')) {
      return 3; // Snacks serve 3 people
    }
    return 4; // Default estimation
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'N/A';
      }
      
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatLocation(dynamic location) {
    if (location == null) return 'N/A';
    
    if (location is String) {
      // If it's a string that looks like coordinates
      if (location.startsWith('[') && location.endsWith(']')) {
        try {
          final coords = location.substring(1, location.length - 1).split(',');
          if (coords.length == 2) {
            final lat = double.parse(coords[0].trim());
            final lng = double.parse(coords[1].trim());
            return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
          }
        } catch (e) {
          // If parsing fails, return as is
        }
      }
    }
    
    return location.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delivery History"),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            tooltip: 'Update HungerSpot',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateHungerSpotScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Impact Summary Card
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 10),
                Text(
                  'You have helped feed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '$totalMealsDelivered',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'people with meals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // History List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('volunteer_history')
                  .where('volunteerEmail', isEqualTo: _auth.currentUser?.email ?? '')
                  .snapshots(),
              builder: (context, snapshot) {
                print('Stream state: ${snapshot.connectionState}');
                print('Has data: ${snapshot.hasData}');
                print('Data: ${snapshot.data?.docs.length}');
                print('Current user email: ${_auth.currentUser?.email}');
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 80, color: Colors.red),
                        SizedBox(height: 20),
                        Text('Error loading history: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No delivery history found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Your completed deliveries will appear here",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final historyDocs = snapshot.data!.docs;
                
                // Sort manually since we removed orderBy
                historyDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  
                  final aTimestamp = aData['timestamp'];
                  final bTimestamp = bData['timestamp'];
                  
                  if (aTimestamp == null && bTimestamp == null) return 0;
                  if (aTimestamp == null) return 1;
                  if (bTimestamp == null) return -1;
                  
                  try {
                    DateTime aDate, bDate;
                    
                    if (aTimestamp is Timestamp) {
                      aDate = aTimestamp.toDate();
                    } else if (aTimestamp is String) {
                      aDate = DateTime.parse(aTimestamp);
                    } else {
                      return 0;
                    }
                    
                    if (bTimestamp is Timestamp) {
                      bDate = bTimestamp.toDate();
                    } else if (bTimestamp is String) {
                      bDate = DateTime.parse(bTimestamp);
                    } else {
                      return 0;
                    }
                    
                    return bDate.compareTo(aDate); // Descending order
                  } catch (e) {
                    return 0;
                  }
                });

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: historyDocs.length,
                  itemBuilder: (context, index) {
                    final data = historyDocs[index].data() as Map<String, dynamic>;
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with timestamp
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Delivered',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatTimestamp(data['timestamp']),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            
                            // Food Items
                            _buildInfoRow(
                              Icons.restaurant,
                              'Food Items',
                              data['foodItems']?.toString() ?? 'N/A',
                              Colors.orange,
                            ),
                            SizedBox(height: 8),
                            
                            // Description
                            if (data['description'] != null && data['description'].toString().isNotEmpty)
                              _buildInfoRow(
                                Icons.description,
                                'Description',
                                data['description'].toString(),
                                Colors.blue,
                              ),
                            SizedBox(height: 8),
                            
                            // Location
                            _buildInfoRow(
                              Icons.location_on,
                              'Delivery Location',
                              _formatLocation(data['location']),
                              Colors.red,
                            ),
                            SizedBox(height: 8),
                            
                            // Estimated people helped
                            _buildInfoRow(
                              Icons.people,
                              'People Helped',
                              '~${_estimateMealsFromFoodItems(data['foodItems']?.toString() ?? '')} people',
                              Colors.green,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
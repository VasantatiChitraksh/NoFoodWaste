import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // for formatting timestamp

class DonationHistoryPage extends StatelessWidget {
  const DonationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donation History"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('donation_requests')
             .where('meals', isGreaterThan: 25)
            // .orderBy('cookedTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No accepted donations yet."));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;

              final acceptedBy = data['acceptedBy']?.toString() ?? 'Unknown';
              final contact = data['contact']?.toString() ?? 'N/A';
              final meals = data['meals']?.toString() ?? 'N/A';
              final description = data['description']?.toString() ?? 'N/A';

              final cookedTime = (data['cookedTime'] as Timestamp?)?.toDate();
              final formattedDate = cookedTime != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(cookedTime)
                  : 'N/A';

              final location = data['location'];
              String locationText = "Location not available";
              if (location is List && location.length == 2) {
                locationText = "📍 ${location[0]}, ${location[1]}";
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📅 Cooked Time: $formattedDate",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text("🍱 Meals: $meals"),
                      const SizedBox(height: 4),
                      Text("📝 Description: $description"),
                      const SizedBox(height: 8),
                      Text("🙋 Volunteer: $acceptedBy"),
                      Text("📞 Phone: $contact"),
                      const SizedBox(height: 8),
                      Text(locationText),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

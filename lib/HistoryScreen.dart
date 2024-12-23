import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> healthRecords = [];
  bool isLoading = true;

  Future<void> fetchHealthData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      print("No user is logged in.");
      return;
    }

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('WatchUsersDB')
          .doc(user.uid)
          .collection('History')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        healthRecords = snapshot.docs.map((doc) {
          Timestamp timestamp = doc['createdAt'];
          DateTime date = timestamp.toDate();
          String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(date);
          return {
            'date_time': formattedDate,
            'heart_rate': doc['heartRate'],
            'steps': doc['steps'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching data from Firestore: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHealthData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Health Records',style: Theme.of(context).textTheme.titleMedium,),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : healthRecords.isEmpty
          ? const Center(child: Text('No records available'))
          : ListView.builder(
        itemCount: healthRecords.length,
        itemBuilder: (context, index) {
          final record = healthRecords[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(record['date_time']),
              subtitle: Text(
                  'Heart Rate: ${record['heart_rate']} BPM\nSteps: ${record['steps']}'),
              leading: const Icon(Icons.favorite, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}

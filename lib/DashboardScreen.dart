import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:watch_data_app/MockBluetoothSdk.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MockBluetoothSDK bluetoothSDK = MockBluetoothSDK();
  bool isBluetoothConnected = false;

  final user = FirebaseAuth.instance.currentUser;
  String heartRate = 'N/A';
  String steps = 'N/A';
  String userName = 'User';


  void saveDailyRecord(int heartRate, int steps) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      String today = DateTime.now().toIso8601String().split('T')[0];

      try {
        final docRef = FirebaseFirestore.instance
            .collection('WatchUsersDB')
            .doc(userId)
            .collection('History')
            .doc(today);
        DocumentSnapshot doc = await docRef.get();

        if (doc.exists) {
          await docRef.update({
            "heartRate": heartRate,
            "steps": steps,
            "lastUpdated": FieldValue.serverTimestamp(),
          });
          print("Today's record updated!");
        } else {

          await docRef.set({
            "heartRate": heartRate,
            "steps": steps,
            "createdAt": FieldValue.serverTimestamp(),
          });
          print("New record added for today!");
        }
      } catch (e) {
        print("Error saving daily record: $e");
      }
    }
  }


  Future<void> _fetchUserData() async {
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('WatchUsersDB')
            .doc(user!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? 'User';
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }
  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _checkAndSaveDailyRecord();
  }

  Future<void> _checkAndSaveDailyRecord() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DateTime now = DateTime.now();
    String today = '${now.year}-${now.month}-${now.day}';

    try {
      DocumentSnapshot todayRecord = await FirebaseFirestore.instance
          .collection('WatchUsersDB')
          .doc(user.uid)
          .collection('UserHistoryDB')
          .doc(today)
          .get();

      if (!todayRecord.exists) {
        int latestHeartRate = await bluetoothSDK.getHeartRateStream().first;
        int latestSteps = await bluetoothSDK.getStepCountStream().first;

        saveDailyRecord(latestHeartRate, latestSteps);
      }
    } catch (e) {
      print("Error checking/saving daily record: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard',style: Theme.of(context).textTheme.titleMedium,),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                  'Welcome, $userName',
                  style: Theme.of(context).textTheme.titleSmall
              ),
              Text(user?.email ?? 'Not Logged In',
                  style: Theme.of(context).textTheme.titleSmall
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      StreamBuilder<int>(
                        stream: bluetoothSDK.getHeartRateStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              'Heart Rate: Waiting...',
                              style: TextStyle(fontSize: 18),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            );
                          } else {
                            heartRate = snapshot.data.toString();
                            return Text(
                              'Heart Rate: $heartRate BPM',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 20),
                      StreamBuilder<int>(
                        stream: bluetoothSDK.getStepCountStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              'Steps: Waiting...',
                              style: TextStyle(fontSize: 18),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            );
                          } else {
                            steps = snapshot.data.toString();
                            return Text(
                              'Steps: $steps',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20,),
                      StreamBuilder<bool>(
                        stream: bluetoothSDK.getConnectionStatusStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              'Bluetooth: Checking...',
                              style: TextStyle(fontSize: 18),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            );
                          } else {
                            isBluetoothConnected = snapshot.data ?? false;
                            return Text(
                              'Bluetooth: ${isBluetoothConnected ? 'Connected' : 'Disconnected'}',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isBluetoothConnected ? Colors.green : Colors.red
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),


    );
  }
}
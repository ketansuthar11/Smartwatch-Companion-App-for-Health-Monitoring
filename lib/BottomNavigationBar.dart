import 'package:flutter/material.dart';

import 'DashboardScreen.dart';
import 'HistoryScreen.dart';
import 'SettingScreen.dart';

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int currentpage = 0;
  List <Widget> page = [DashboardScreen(),HistoryScreen(),SettingsScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async => false,
        child: IndexedStack(
          index: currentpage,
          children: page,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.blueAccent,
          onTap: (value){
            setState(() {
              currentpage = value;
            });
          },
          currentIndex: currentpage,
          items:const  [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ]
      ),
    );
  }
}

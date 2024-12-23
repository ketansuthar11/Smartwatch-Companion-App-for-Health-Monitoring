import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'BluetoothProvider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  CustomBluetoothService bluetoothService = CustomBluetoothService();  // Renamed class
  bool isScanningEnabled = false;
  List<ScanResult> devicesList = [];

  void toggleBluetoothScan(bool value) {
    setState(() {
      isScanningEnabled = value;
    });

    if (isScanningEnabled) {
      bluetoothService.startScan();
    } else {
      bluetoothService.stopScan();
    }
  }

  @override
  void initState() {
    super.initState();

    bluetoothService.scanResultsStream.listen((scanResults) {
      setState(() {
        devicesList = scanResults;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Enable Bluetooth Scanning'),
              trailing: Switch(
                value: isScanningEnabled,
                onChanged: toggleBluetoothScan,
              ),
            ),
            SizedBox(height: 20),
            Text('Nearby Devices:', style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 10),
            if (isScanningEnabled) CircularProgressIndicator(),
            SizedBox(height: 10),
            Expanded(
              child: devicesList.isEmpty
                  ? Center(child: Text('No devices found'))
                  : ListView.builder(
                itemCount: devicesList.length,
                itemBuilder: (context, index) {
                  ScanResult device = devicesList[index];
                  return ListTile(
                    title: Text(device.device.name.isNotEmpty ? device.device.name : "Unnamed Device"),
                    subtitle: Text('RSSI: ${device.rssi}'),
                    onTap: () {
                      // Handle device tap
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

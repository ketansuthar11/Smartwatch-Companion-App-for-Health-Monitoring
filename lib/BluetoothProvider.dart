import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class CustomBluetoothService {

  Stream<List<ScanResult>> get scanResultsStream {
    return FlutterBluePlus.scanResults;
  }

  void startScan() {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }
}

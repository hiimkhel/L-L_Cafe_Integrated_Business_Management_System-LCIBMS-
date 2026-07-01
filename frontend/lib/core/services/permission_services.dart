import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<void> requestBluetoothPermissions() async {
    // Web browsers don't support permission_handler Bluetooth permissions.
    if (kIsWeb) return;

    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  Future<bool> hasPermissions() async {
    // Nothing to request on the web.
    if (kIsWeb) return true;

    return await Permission.bluetooth.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted;
  }
}
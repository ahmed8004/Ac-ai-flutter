import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WiFiService {
  final Connectivity _connectivity = Connectivity();
  bool _isOn = false;

  bool get isOn => _isOn;

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _isOn = result != ConnectivityResult.none;
    debugPrint('WiFi initialized: $_isOn');
  }

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  Future<bool> isMobileData() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }

  Future<bool> hasInternet() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<String> getConnectionType() async {
    final result = await _connectivity.checkConnectivity();
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      default:
        return 'No Connection';
    }
  }

  void dispose() {
    debugPrint('WiFi Service disposed');
  }
}

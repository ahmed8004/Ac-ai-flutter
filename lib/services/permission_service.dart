import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  bool _micGranted = false;
  bool _cameraGranted = false;
  bool _contactsGranted = false;
  bool _locationGranted = false;
  bool _phoneGranted = false;
  bool _smsGranted = false;

  bool get micGranted => _micGranted;
  bool get cameraGranted => _cameraGranted;
  bool get contactsGranted => _contactsGranted;
  bool get locationGranted => _locationGranted;
  bool get phoneGranted => _phoneGranted;
  bool get smsGranted => _smsGranted;

  Future<void> initialize() async {
    await checkAllPermissions();
    debugPrint('Permission Service initialized');
  }

  Future<void> checkAllPermissions() async {
    _micGranted = await Permission.microphone.isGranted;
    _cameraGranted = await Permission.camera.isGranted;
    _contactsGranted = await Permission.contacts.isGranted;
    _locationGranted = await Permission.location.isGranted;
    _phoneGranted = await Permission.phone.isGranted;
    _smsGranted = await Permission.sms.isGranted;
    
    debugPrint('''
Permission Status:
- Microphone: $_micGranted
- Camera: $_cameraGranted
- Contacts: $_contactsGranted
- Location: $_locationGranted
- Phone: $_phoneGranted
- SMS: $_smsGranted
    ''');
  }

  Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    _micGranted = status.isGranted;
    debugPrint('Microphone permission: $status');
    return _micGranted;
  }

  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    _cameraGranted = status.isGranted;
    debugPrint('Camera permission: $status');
    return _cameraGranted;
  }

  Future<bool> requestContacts() async {
    final status = await Permission.contacts.request();
    _contactsGranted = status.isGranted;
    debugPrint('Contacts permission: $status');
    return _contactsGranted;
  }

  Future<bool> requestLocation() async {
    final status = await Permission.location.request();
    _locationGranted = status.isGranted;
    debugPrint('Location permission: $status');
    return _locationGranted;
  }

  Future<bool> requestPhone() async {
    final status = await Permission.phone.request();
    _phoneGranted = status.isGranted;
    debugPrint('Phone permission: $status');
    return _phoneGranted;
  }

  Future<bool> requestSMS() async {
    final status = await Permission.sms.request();
    _smsGranted = status.isGranted;
    debugPrint('SMS permission: $status');
    return _smsGranted;
  }

  Future<Map<String, bool>> requestAll() async {
    final results = await [
      Permission.microphone,
      Permission.camera,
      Permission.contacts,
      Permission.location,
      Permission.phone,
      Permission.sms,
    ].request();

    _micGranted = results[Permission.microphone] ?? PermissionStatus.denied == PermissionStatus.granted;
    _cameraGranted = results[Permission.camera] ?? PermissionStatus.denied == PermissionStatus.granted;
    _contactsGranted = results[Permission.contacts] ?? PermissionStatus.denied == PermissionStatus.granted;
    _locationGranted = results[Permission.location] ?? PermissionStatus.denied == PermissionStatus.granted;
    _phoneGranted = results[Permission.phone] ?? PermissionStatus.denied == PermissionStatus.granted;
    _smsGranted = results[Permission.sms] ?? PermissionStatus.denied == PermissionStatus.granted;

    await checkAllPermissions();
    
    return {
      'microphone': _micGranted,
      'camera': _cameraGranted,
      'contacts': _contactsGranted,
      'location': _locationGranted,
      'phone': _phoneGranted,
      'sms': _smsGranted,
    };
  }

  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  bool get allGranted =>
      _micGranted &&
      _cameraGranted &&
      _contactsGranted &&
      _locationGranted &&
      _phoneGranted &&
      _smsGranted;

  bool get essentialGranted => _micGranted;

  void dispose() {
    debugPrint('Permission Service disposed');
  }
}

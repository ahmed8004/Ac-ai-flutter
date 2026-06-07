import 'package:flutter/foundation.dart';
import 'call_service.dart';
import 'sms_service.dart';
import 'youtube_service.dart';
import 'volume_service.dart';
import 'camera_service.dart';
import 'torch_service.dart';
import 'bluetooth_service.dart';
import 'wifi_service.dart';
import 'brightness_service.dart';
import 'screenshot_service.dart';
import 'webscraper_service.dart';
import 'file_manager_service.dart';
import 'download_service.dart';
import 'pdf_service.dart';
import 'app_launcher_service.dart';

enum CommandType {
  call,
  message,
  youtube,
  search,
  volume,
  app,
  camera,
  time,
  date,
  weather,
  location,
  torch,
  bluetooth,
  wifi,
  brightness,
  screenshot,
  websearch,
  file,
  download,
  pdf,
  reminder,
  unknown,
}

class CommandResult {
  final bool success;
  final String message;
  final CommandType type;
  final Map<String, dynamic> data;

  CommandResult({
    required this.success,
    required this.message,
    required this.type,
    this.data = const {},
  });
}

class CommandProcessor {
  final CallService _callService;
  final SMSService _smsService;
  final YouTubeService _youtubeService;
  final VolumeService _volumeService;
  final CameraService _cameraService;
  final TorchService _torchService;
  final BluetoothService _bluetoothService;
  final WiFiService _wifiService;
  final BrightnessService _brightnessService;
  final ScreenshotService _screenshotService;
  final WebScraperService _webScraperService;
  final FileManagerService _fileManagerService;
  final DownloadService _downloadService;
  final PDFService _pdfService;
  final AppLauncherService _appLauncherService;

  CommandProcessor({
    CallService? callService,
    SMSService? smsService,
    YouTubeService? youtubeService,
    VolumeService? volumeService,
    CameraService? cameraService,
    TorchService? torchService,
    BluetoothService? bluetoothService,
    WiFiService? wifiService,
    BrightnessService? brightnessService,
    ScreenshotService? screenshotService,
    WebScraperService? webScraperService,
    FileManagerService? fileManagerService,
    DownloadService? downloadService,
    PDFService? pdfService,
    AppLauncherService? appLauncherService,
  })  : _callService = callService ?? CallService(),
        _smsService = smsService ?? SMSService(),
        _youtubeService = youtubeService ?? YouTubeService(),
        _volumeService = volumeService ?? VolumeService(),
        _cameraService = cameraService ?? CameraService(),
        _torchService = torchService ?? TorchService(),
        _bluetoothService = bluetoothService ?? BluetoothService(),
        _wifiService = wifiService ?? WiFiService(),
        _brightnessService = brightnessService ?? BrightnessService(),
        _screenshotService = screenshotService ?? ScreenshotService(),
        _webScraperService = webScraperService ?? WebScraperService(),
        _fileManagerService = fileManagerService ?? FileManagerService(),
        _downloadService = downloadService ?? DownloadService(),
        _pdfService = pdfService ?? PDFService(),
        _appLauncherService = appLauncherService ?? AppLauncherService();

  Future<CommandResult> processCommand(String input) async {
    final lowerInput = input.toLowerCase();

    if (_matchesCommand(lowerInput, ['torch', 'flashlight', 'tourch'])) {
      return await _processTorchCommand(input);
    }

    if (_matchesCommand(lowerInput, ['bluetooth', 'ब्लूटूथ'])) {
      return await _processBluetoothCommand(input);
    }

    if (_matchesCommand(lowerInput, ['wifi', 'वाईफाई', 'wi-fi'])) {
      return await _processWifiCommand(input);
    }

    if (_matchesCommand(lowerInput, ['brightness', 'screen', 'ब्राइटनेस'])) {
      return await _processBrightnessCommand(input);
    }

    if (_matchesCommand(lowerInput, ['screenshot', 'स्क्रीनशॉट'])) {
      return await _processScreenshotCommand();
    }

    if (_matchesCommand(lowerInput, ['open', 'खोलो', 'launch'])) {
      return await _processAppCommand(input);
    }

    if (_matchesCommand(lowerInput, ['search web', 'google', 'वेब सर्च'])) {
      return await _processWebSearchCommand(input);
    }

    if (_matchesCommand(lowerInput, ['download', 'डाउनलोड'])) {
      return await _processDownloadCommand(input);
    }

    if (_matchesCommand(lowerInput, ['pdf', 'create pdf', 'पीडीएफ'])) {
      return await _processPDFCommand(input);
    }

    if (_matchesCommand(lowerInput, ['file', 'फाइल', 'pick file'])) {
      return await _processFileCommand(input);
    }

    if (_matchesCommand(lowerInput, ['call', 'फोन', 'कॉल'])) {
      return await _processCallCommand(input);
    }

    if (_matchesCommand(lowerInput, ['message', 'sms', 'msg', 'संदेश'])) {
      return await _processMessageCommand(input);
    }

    if (_matchesCommand(lowerInput, ['youtube', 'yt', 'play'])) {
      return await _processYouTubeCommand(input);
    }

    if (_matchesCommand(lowerInput, ['volume', 'awaaz', 'आवाज़', 'sound'])) {
      return await _processVolumeCommand(input);
    }

    if (_matchesCommand(lowerInput, ['time', 'समय', 'टाइम'])) {
      return _processTimeCommand();
    }

    if (_matchesCommand(lowerInput, ['date', 'tarikh', 'तारीख', 'tarik'])) {
      return _processDateCommand();
    }

    if (_matchesCommand(lowerInput, ['camera', 'selfie', 'photo', 'foto', 'tphoto'])) {
      return await _processCameraCommand(input);
    }

    if (_matchesCommand(lowerInput, ['location', 'kahan', 'कहां'])) {
      return _processLocationCommand();
    }

    return CommandResult(
      success: false,
      message: 'Command not recognized',
      type: CommandType.unknown,
    );
  }

  bool _matchesCommand(String input, List<String> keywords) {
    return keywords.any((keyword) => input.contains(keyword));
  }

  // TORCH
  Future<CommandResult> _processTorchCommand(String input) async {
    final lower = input.toLowerCase();

    if (lower.contains('on') || lower.contains('चालू')) {
      final success = await _torchService.turnOn();
      return CommandResult(
        success: success,
        message: success ? 'Torch is now ON' : 'Failed to turn on torch',
        type: CommandType.torch,
      );
    }

    if (lower.contains('off') || lower.contains('बंद')) {
      final success = await _torchService.turnOff();
      return CommandResult(
        success: success,
        message: success ? 'Torch is now OFF' : 'Failed to turn off torch',
        type: CommandType.torch,
      );
    }

    final success = await _torchService.toggle();
    return CommandResult(
      success: success,
      message: success ? 'Torch toggled' : 'Failed to toggle torch',
      type: CommandType.torch,
    );
  }

  // BLUETOOTH
  Future<CommandResult> _processBluetoothCommand(String input) async {
    final lower = input.toLowerCase();

    if (lower.contains('on') || lower.contains('चालू') || lower.contains('enable')) {
      final success = await _bluetoothService.turnOn();
      return CommandResult(
        success: success,
        message: success ? 'Bluetooth ON kar diya' : 'Bluetooth ON nahi ho paya. Settings me jaake manually ON karo.',
        type: CommandType.bluetooth,
      );
    }

    if (lower.contains('off') || lower.contains('बंद') || lower.contains('disable')) {
      final success = await _bluetoothService.turnOff();
      return CommandResult(
        success: success,
        message: success ? 'Bluetooth OFF kar diya' : 'Bluetooth OFF nahi ho paya. Settings me jaake manually OFF karo.',
        type: CommandType.bluetooth,
      );
    }

    return CommandResult(
      success: true,
      message: 'Bluetooth ${_bluetoothService.isEnabled ? "ON hai" : "OFF hai"}. Bolo "Bluetooth on" ya "Bluetooth off"',
      type: CommandType.bluetooth,
    );
  }

  // WIFI
  Future<CommandResult> _processWifiCommand(String input) async {
    final lower = input.toLowerCase();

    if (lower.contains('on') || lower.contains('चालू') || lower.contains('enable')) {
      final success = await _wifiService.turnOn();
      return CommandResult(
        success: success,
        message: success ? 'WiFi ON kar diya' : 'WiFi ON nahi ho paya. Settings me jaake manually ON karo.',
        type: CommandType.wifi,
      );
    }

    if (lower.contains('off') || lower.contains('बंद') || lower.contains('disable')) {
      final success = await _wifiService.turnOff();
      return CommandResult(
        success: success,
        message: success ? 'WiFi OFF kar diya' : 'WiFi OFF nahi ho paya. Settings me jaake manually OFF karo.',
        type: CommandType.wifi,
      );
    }

    if (lower.contains('status') || lower.contains('check')) {
      final connectionType = await _wifiService.getConnectionType();
      return CommandResult(
        success: true,
        message: 'Connection: $connectionType',
        type: CommandType.wifi,
      );
    }

    final isConnected = await _wifiService.isConnected();
    final connType = await _wifiService.getConnectionType();
    return CommandResult(
      success: true,
      message: isConnected ? 'WiFi Connected: $connType' : 'WiFi Disconnected',
      type: CommandType.wifi,
    );
  }

  // BRIGHTNESS
  Future<CommandResult> _processBrightnessCommand(String input) async {
    final lower = input.toLowerCase();

    if (lower.contains('bright') || lower.contains('full') || lower.contains('100')) {
      await _brightnessService.bright();
      return CommandResult(
        success: true,
        message: 'Brightness set to maximum',
        type: CommandType.brightness,
      );
    }

    if (lower.contains('dim') || lower.contains('low') || lower.contains('minimum')) {
      await _brightnessService.dim();
      return CommandResult(
        success: true,
        message: 'Brightness set to minimum',
        type: CommandType.brightness,
      );
    }

    if (lower.contains('medium') || lower.contains('50')) {
      await _brightnessService.medium();
      return CommandResult(
        success: true,
        message: 'Brightness set to medium',
        type: CommandType.brightness,
      );
    }

    if (lower.contains('auto')) {
      await _brightnessService.auto();
      return CommandResult(
        success: true,
        message: 'Auto brightness enabled',
        type: CommandType.brightness,
      );
    }

    return CommandResult(
      success: true,
      message: 'Say "brightness bright/dim/medium/auto"',
      type: CommandType.brightness,
    );
  }

  // SCREENSHOT
  Future<CommandResult> _processScreenshotCommand() async {
    final path = await _screenshotService.capture();
    if (path != null) {
      return CommandResult(
        success: true,
        message: 'Screenshot saved successfully',
        type: CommandType.screenshot,
        data: {'path': path},
      );
    }
    return CommandResult(
      success: false,
      message: 'Failed to take screenshot',
      type: CommandType.screenshot,
    );
  }

  // APP LAUNCHER
  Future<CommandResult> _processAppCommand(String input) async {
    final lower = input.toLowerCase();
    
    final appName = lower
        .replaceAll(RegExp(r'(open|launch|खोलो|start)'), '')
        .trim();

    if (appName.isEmpty) {
      return CommandResult(
        success: true,
        message: 'Which app do you want to open? Available: WhatsApp, YouTube, Instagram, Gmail, etc.',
        type: CommandType.app,
      );
    }

    final success = await _appLauncherService.openApp(appName);
    return CommandResult(
      success: success,
      message: success ? 'Opening $appName' : 'Failed to open $appName',
      type: CommandType.app,
    );
  }

  // WEB SEARCH
  Future<CommandResult> _processWebSearchCommand(String input) async {
    final query = input
        .replaceAll(RegExp(r'(search web|web search|google|search for)', caseSensitive: false), '')
        .trim();

    if (query.isEmpty) {
      return CommandResult(
        success: true,
        message: 'What do you want to search?',
        type: CommandType.websearch,
      );
    }

    final result = await _webScraperService.searchWeb(query);
    return CommandResult(
      success: true,
      message: result ?? 'No results found for "$query"',
      type: CommandType.websearch,
      data: {'query': query, 'result': result},
    );
  }

  // DOWNLOAD
  Future<CommandResult> _processDownloadCommand(String input) async {
    return CommandResult(
      success: true,
      message: 'Download feature ready. Provide a URL to download.',
      type: CommandType.download,
      data: {'needsUrl': true},
    );
  }

  // PDF
  Future<CommandResult> _processPDFCommand(String input) async {
    return CommandResult(
      success: true,
      message: 'PDF creation feature ready. What should I create PDF for?',
      type: CommandType.pdf,
      data: {'needsContent': true},
    );
  }

  // FILE
  Future<CommandResult> _processFileCommand(String input) async {
    final lower = input.toLowerCase();

    if (lower.contains('pick') || lower.contains('select')) {
      final path = await _fileManagerService.pickFile();
      if (path != null) {
        return CommandResult(
          success: true,
          message: 'File selected: $path',
          type: CommandType.file,
          data: {'path': path},
        );
      }
      return CommandResult(
        success: false,
        message: 'No file selected',
        type: CommandType.file,
      );
    }

    return CommandResult(
      success: true,
      message: 'File manager ready. Say "pick file" or "select file"',
      type: CommandType.file,
    );
  }

  String _extractPhoneNumber(String input) {
    final phoneRegex = RegExp(r'\b\d{10}\b');
    final match = phoneRegex.firstMatch(input);
    return match?.group(0) ?? '';
  }

  String _extractContactName(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('mamma') || lower.contains('मम्मी') || lower.contains('mom')) {
      return 'mamma';
    }
    if (lower.contains('papa') || lower.contains('पापा')) {
      return 'papa';
    }
    return '';
  }

  Future<CommandResult> _processCallCommand(String input) async {
    final phoneNumber = _extractPhoneNumber(input);
    final contactName = _extractContactName(input);

    if (phoneNumber.isNotEmpty) {
      final success = await _callService.makeCall(phoneNumber);
      return CommandResult(
        success: success,
        message: success ? 'Calling $phoneNumber...' : 'Failed to make call',
        type: CommandType.call,
        data: {'phoneNumber': phoneNumber},
      );
    }

    if (contactName.isNotEmpty) {
      return CommandResult(
        success: false,
        message: 'I recognized you want to call $contactName, but I need their phone number. Please say it.',
        type: CommandType.call,
        data: {'contactName': contactName, 'needsPhone': true},
      );
    }

    return CommandResult(
      success: true,
      message: 'Call command recognized. Who do you want to call?',
      type: CommandType.call,
      data: {'needsContact': true},
    );
  }

  Future<CommandResult> _processMessageCommand(String input) async {
    final phoneNumber = _extractPhoneNumber(input);
    
    if (input.toLowerCase().contains('emergency') || input.toLowerCase().contains('आपातकाल')) {
      return CommandResult(
        success: true,
        message: 'Emergency SMS feature ready. Who should I send it to?',
        type: CommandType.message,
        data: {'emergency': true},
      );
    }

    if (phoneNumber.isNotEmpty) {
      return CommandResult(
        success: true,
        message: 'SMS ready. What message should I send to $phoneNumber?',
        type: CommandType.message,
        data: {'phoneNumber': phoneNumber, 'needsMessage': true},
      );
    }

    return CommandResult(
      success: true,
      message: 'SMS command recognized. Who do you want to message?',
      type: CommandType.message,
      data: {'needsContact': true},
    );
  }

  Future<CommandResult> _processYouTubeCommand(String input) async {
    if (input.toLowerCase().contains('open') || input.toLowerCase().contains('खोलो')) {
      final success = await _youtubeService.openYouTube();
      return CommandResult(
        success: success,
        message: success ? 'Opening YouTube...' : 'Failed to open YouTube',
        type: CommandType.youtube,
      );
    }

    final searchQuery = input
        .replaceAll(RegExp(r'(youtube|play|search)', caseSensitive: false), '')
        .replaceAll(RegExp(r'लगाओ|खोलो|play', caseSensitive: false), '')
        .trim();

    if (searchQuery.isNotEmpty) {
      final success = await _youtubeService.searchYouTube(searchQuery);
      return CommandResult(
        success: success,
        message: success 
          ? 'Searching YouTube for "$searchQuery"...' 
          : 'Failed to search YouTube',
        type: CommandType.youtube,
        data: {'query': searchQuery},
      );
    }

    return CommandResult(
      success: true,
      message: 'YouTube command recognized. What do you want to watch?',
      type: CommandType.youtube,
      data: {'needsQuery': true},
    );
  }

  Future<CommandResult> _processVolumeCommand(String input) async {
    final lower = input.toLowerCase();

    if (lower.contains('up') || lower.contains('बढ़ा') || lower.contains('badha')) {
      await _volumeService.volumeUp();
      return CommandResult(
        success: true,
        message: 'Volume increased',
        type: CommandType.volume,
      );
    }

    if (lower.contains('down') || lower.contains('कम') || lower.contains('kam')) {
      await _volumeService.volumeDown();
      return CommandResult(
        success: true,
        message: 'Volume decreased',
        type: CommandType.volume,
      );
    }

    if (lower.contains('mute') || lower.contains('चुप') || lower.contains('chup')) {
      await _volumeService.mute();
      return CommandResult(
        success: true,
        message: 'Volume muted',
        type: CommandType.volume,
      );
    }

    if (lower.contains('max') || lower.contains('full') || lower.contains('पूरा')) {
      await _volumeService.maxVolume();
      return CommandResult(
        success: true,
        message: 'Volume set to maximum',
        type: CommandType.volume,
      );
    }

    return CommandResult(
      success: true,
      message: 'Volume command recognized. Say "volume up", "volume down", "mute", or "max volume".',
      type: CommandType.volume,
    );
  }

  CommandResult _processTimeCommand() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    final timeStr = '$displayHour:$minute $ampm';
    
    return CommandResult(
      success: true,
      message: 'Current time is $timeStr',
      type: CommandType.time,
    );
  }

  CommandResult _processDateCommand() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final dateStr = '${months[now.month - 1]} ${now.day}, ${now.year}';
    
    return CommandResult(
      success: true,
      message: 'Today is $dateStr',
      type: CommandType.date,
    );
  }

  Future<CommandResult> _processCameraCommand(String input) async {
    final lower = input.toLowerCase();

    if (lower.contains('selfie') || lower.contains('front')) {
      final photoPath = await _cameraService.takeSelfie();
      if (photoPath != null) {
        return CommandResult(
          success: true,
          message: 'Selfie taken successfully!',
          type: CommandType.camera,
          data: {'path': photoPath, 'type': 'selfie'},
        );
      } else {
        return CommandResult(
          success: false,
          message: 'Failed to take selfie. Camera permission needed.',
          type: CommandType.camera,
        );
      }
    }

    if (lower.contains('photo') || lower.contains('picture') || lower.contains('foto')) {
      final photoPath = await _cameraService.takePhoto();
      if (photoPath != null) {
        return CommandResult(
          success: true,
          message: 'Photo taken successfully!',
          type: CommandType.camera,
          data: {'path': photoPath, 'type': 'photo'},
        );
      } else {
        return CommandResult(
          success: false,
          message: 'Failed to take photo. Camera permission needed.',
          type: CommandType.camera,
        );
      }
    }

    return CommandResult(
      success: true,
      message: 'Camera command recognized. Say "take a selfie" or "take a photo".',
      type: CommandType.camera,
    );
  }

  CommandResult _processLocationCommand() {
    return CommandResult(
      success: true,
      message: 'Location feature needs permission. Enable location services.',
      type: CommandType.location,
      data: {'needsPermission': true},
    );
  }

  void dispose() {
    _callService.dispose();
    _smsService.dispose();
    _youtubeService.dispose();
    _volumeService.dispose();
    _cameraService.dispose();
    _torchService.dispose();
    _bluetoothService.dispose();
    _wifiService.dispose();
    _brightnessService.dispose();
    _screenshotService.dispose();
    _webScraperService.dispose();
    _fileManagerService.dispose();
    _downloadService.dispose();
    _pdfService.dispose();
    _appLauncherService.dispose();
    debugPrint('Command Processor disposed');
  }
}

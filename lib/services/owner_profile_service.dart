import 'package:flutter/foundation.dart';

class OwnerProfileService {
  // Owner Information
  static const String _ownerName = 'Ahmed Chaudhari';
  static const String _ownerProfession = 'Ethical Hacker, Cyber Security Expert, Network Administrator';
  static const String _ownerAddress = 'Sangamner, Maharashtra';
  static const List<String> _ownerSkills = [
    'Cybersecurity',
    'Ethical Hacking',
    'Network Administration',
    'Penetration Testing',
    'Security Analysis',
    'Linux Administration',
  ];

  String get ownerName => _ownerName;
  String get ownerProfession => _ownerProfession;
  String get ownerAddress => _ownerAddress;
  List<String> get ownerSkills => _ownerSkills;

  String getOwnerInfo() {
    return "Mere owner $ownerName hain. $ownerProfession. Location: $ownerAddress";
  }

  String getOwnerBio() {
    return '''
Ahmed Chaudhari ek talented Ethical Hacker aur Cyber Security Expert hain.
Wo Network Administrator bhi hain aur Sangamner, Maharashtra me rehte hain.

Skills:
${_ownerSkills.map((s) => '• $s').join('\n')}

Wo technology ke field me expert hain aur security research me specialize kiye hain.
''';
  }

  String getCapabilities() {
    return '''
Main AC AI, tumhara personal voice assistant. Main ye sab kar sakta hoon:

📱 DEVICE CONTROL:
• Torch/Flashlight on/off
• WiFi on/off/status
• Bluetooth on/off
• Volume up/down/mute/max
• Brightness control
• Camera (photo, selfie)
• Screenshot

📞 COMMUNICATION:
• Call karo (phone number se)
• SMS bhejo
• WhatsApp, Gmail open

🌐 INTERNET:
• YouTube search & play
• Web search (Google)
• Website open
• File download

📂 FILE MANAGEMENT:
• File picker
• PDF create
• File save/open

🤖 AI ASSISTANT:
• General knowledge
• Owner info (mera malik Ahmed Chaudhari)
• Date/Time
• Jokes & motivation
• Smart replies

Bas bolo "AC" ya "Hey AC AI" aur apna command do! 🚀
''';
  }

  String getWelcomeMessage() {
    return 'Namaste! Main AC AI hoon, tumhara voice assistant. Ahmed Chaudhari ne mujhe banaya hai. Kya help chahiye?';
  }

  bool isOwnerMentioned(String query) {
    final lowerQuery = query.toLowerCase();
    return lowerQuery.contains('owner') ||
           lowerQuery.contains('ahmed') ||
           lowerQuery.contains('chaudhari') ||
           lowerQuery.contains('tumhara owner') ||
           lowerQuery.contains('kaun banaya') ||
           lowerQuery.contains('teri khalakat') ||
           lowerQuery.contains('malik');
  }

  bool isCapabilitiesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return lowerQuery.contains('kya kar sakte') ||
           lowerQuery.contains('kya kar sakti') ||
           lowerQuery.contains('what can you do') ||
           lowerQuery.contains('features') ||
           lowerQuery.contains('capabilities') ||
           lowerQuery.contains('help') ||
           lowerQuery.contains('madad');
  }

  bool isWelcomeQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return lowerQuery.contains('hello') ||
           lowerQuery.contains('hi ') ||
           lowerQuery.contains('hey') ||
           lowerQuery.contains('namaste') ||
           lowerQuery.contains('namaskar');
  }

  String getResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    if (isCapabilitiesQuery(query)) {
      return getCapabilities();
    }
    
    if (lowerQuery.contains('owner kaun') || lowerQuery.contains('tumhara owner') || lowerQuery.contains('malik kaun')) {
      return 'Mera owner Ahmed Chaudhari hain, jo ek Ethical Hacker aur Cyber Security Expert hain. Sangamner, Maharashtra me rehte hain.';
    }
    
    if (lowerQuery.contains('owner ka naam') || lowerQuery.contains('owner name')) {
      return 'Mera owner ka naam Ahmed Chaudhari hain.';
    }
    
    if (lowerQuery.contains('owner ka address') || lowerQuery.contains('address') || lowerQuery.contains('kahan rehte')) {
      return 'Mera owner Ahmed Chaudhari Sangamner, Maharashtra me rehte hain.';
    }
    
    if (lowerQuery.contains('owner ki profession') || lowerQuery.contains('profession') || lowerQuery.contains('kya karte')) {
      return 'Mera owner Ahmed Chaudhari Ethical Hacker, Cyber Security Expert aur Network Administrator hain.';
    }
    
    if (lowerQuery.contains('owner ke baare') || lowerQuery.contains('owner ke bare') || lowerQuery.contains('about owner')) {
      return getOwnerBio();
    }

    if (lowerQuery.contains('owner ki skills') || lowerQuery.contains('skills')) {
      return 'Mere owner ki skills:\n${_ownerSkills.map((s) => '• $s').join('\n')}';
    }
    
    return getOwnerInfo();
  }

  void dispose() {
    debugPrint('Owner Profile Service disposed');
  }
}

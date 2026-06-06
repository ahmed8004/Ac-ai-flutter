import 'package:flutter/foundation.dart';

class OwnerProfileService {
  // Owner Information
  static const String _ownerName = 'Ahmed Chaudhari';
  static const String _ownerProfession = 'Ethical Hacker, Cyber Security Expert, Network Administrator';
  static const String _ownerAddress = 'Sangamner, Maharashtra';
  static const String _ownerDescription = '''
Owner: Ahmed Chaudhari
Profession: Ethical Hacker, Cyber Security Expert, Network Administrator
Location: Sangamner, Maharashtra
Skills: 
  - Cybersecurity
  - Ethical Hacking
  - Network Administration
  - Penetration Testing
  - Security Analysis
''';

  String get ownerName => _ownerName;
  String get ownerProfession => _ownerProfession;
  String get ownerAddress => _ownerAddress;

  String getOwnerInfo() {
    return "Mer owner $ownerName hain. $ownerProfession. Location: $ownerAddress";
  }

  String getOwnerBio() {
    return '''
Ahmed Chaudhari ek talented Ethical Hacker aur Cyber Security Expert hain.
Wo Network Administrator bhi hain aur Sangamner, Maharashtra me rehte hain.
Unke skills:
- Ethical Hacking
- Cyber Security
- Network Administration
- Penetration Testing
- Security Analysis

Wo technology ke field me expert hain aur security research me specialize kiye hain.
''';
  }

  bool isOwnerMentioned(String query) {
    final lowerQuery = query.toLowerCase();
    return lowerQuery.contains('owner') ||
           lowerQuery.contains('ahmed') ||
           lowerQuery.contains('chaudhari') ||
           lowerQuery.contains('tumhara owner') ||
           lowerQuery.contains('kaun banaya') ||
           lowerQuery.contains('teri khalakat');
  }

  String getResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    if (lowerQuery.contains('owner kaun') || lowerQuery.contains('tumhara owner')) {
      return 'Mera owner Ahmed Chaudhari hain, jo ek Ethical Hacker aur Cyber Security Expert hain. Sangamner, Maharashtra me rehte hain.';
    }
    
    if (lowerQuery.contains('owner ka naam') || lowerQuery.contains('owner name')) {
      return 'Mera owner ka naam Ahmed Chaudhari hain.';
    }
    
    if (lowerQuery.contains('owner ka address') || lowerQuery.contains('address')) {
      return 'Mera owner Ahmed Chaudhari Sangamner, Maharashtra me rehte hain.';
    }
    
    if (lowerQuery.contains('owner ki profession') || lowerQuery.contains('profession')) {
      return 'Mera owner Ahmed Chaudhari Ethical Hacker, Cyber Security Expert aur Network Administrator hain.';
    }
    
    if (lowerQuery.contains('owner ke baare') || lowerQuery.contains('batao')) {
      return getOwnerBio();
    }
    
    return getOwnerInfo();
  }

  void dispose() {
    debugPrint('Owner Profile Service disposed');
  }
}

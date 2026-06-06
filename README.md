# AC AI - Your Intelligent Voice Companion

A complete Flutter voice assistant with real device control.

## Features

### ✅ Core Features
- 🎤 **Speech Recognition** - Real-time voice input (Hindi/English)
- 🔊 **Text-to-Speech** - Natural Hindi voice output
- 🤖 **Groq AI** - Fast, intelligent responses (Llama 3.3 70B)
- ⚪ **Animated Orb** - 7 reactive states with smooth animations
- ⏸ **Pause/Stop** - Full control over services
- ⚙️ **Settings** - Language, speed, and more

### ✅ Device Control (NEW!)
- 📞 **Make Calls** - "Call [phone number]"
- 💬 **Send SMS** - "Send SMS to [number]"
- ▶️ **YouTube** - "Play [song] on YouTube"
- 🔊 **Volume Control** - "Volume up/down/mute/max"
- 📷 **Camera** - "Take a selfie" or "Take a photo"
- 📍 **Location** - Location sharing (future)
- ⏰ **Time/Date** - "What time is it?"

## Supported Commands

### Voice Commands:

| Command | Action |
|---------|--------|
| "Hello" / "Hi" / "Namaste" | AI responds in Hindi/English |
| "Call 9876543210" | Opens phone dialer |
| "Call mamma" | Asks for phone number |
| "Send SMS to 9876543210" | Opens SMS app |
| "Play [song] on YouTube" | Searches on YouTube |
| "Open YouTube" | Opens YouTube app |
| "Volume up" | Increases volume |
| "Volume down" | Decreases volume |
| "Volume mute" | Mutes device |
| "Max volume" | Sets to 100% |
| "Take a selfie" | Opens front camera |
| "Take a photo" | Opens rear camera |
| "What time is it?" | Tells current time |
| "What's the date?" | Tells current date |
| "Kya hal hai?" | Conversational response |
| Any question | AI answers intelligently |

## Architecture

```
lib/
├── main.dart                    # App entry point
├── theme/app_theme.dart         # Theme & colors
├── models/orb_state.dart        # State management
├── screens/home_screen.dart     # Main UI screen
├── services/                    # Core functionality
│   ├── stt_service.dart         # Speech-to-Text
│   ├── tts_service.dart         # Text-to-Speech
│   ├── ai_brain_service.dart    # Groq API
│   ├── command_processor.dart   # Command parser
│   ├── app_controller.dart      # Master controller
│   ├── permission_service.dart  # Permission handler
│   ├── call_service.dart        # Phone calls
│   ├── sms_service.dart         # SMS messages
│   ├── youtube_service.dart     # YouTube integration
│   ├── volume_service.dart      # Volume control
│   └── camera_service.dart      # Camera access
└── widgets/                     # UI components
    ├── orb_widget.dart          # Animated orb
    ├── control_buttons.dart     # Pause/Stop
    ├── settings_panel.dart      # Settings UI
    └── background_effect.dart   # Particle effects
```

## Setup

### 1. Install Flutter
```bash
flutter doctor
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Configure Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

### 4. Run
```bash
flutter run
```

### 5. Build APK
```bash
flutter build apk --release
```

## API Key

Groq API key is embedded in `ai_brain_service.dart`.

## Testing Checklist

- ✅ App opens with animated orb
- ✅ Tap orb → starts listening
- ✅ Voice input recognized
- ✅ Hindi TTS responds
- ✅ Call command works
- ✅ YouTube command works
- ✅ Volume control works
- ✅ Camera works
- ✅ Pause/Stop buttons work
- ✅ Settings panel opens

## Dependencies

- `speech_to_text: ^6.6.0` - Voice recognition
- `flutter_tts: ^3.8.5` - Text-to-speech
- `http: ^1.2.0` - API calls
- `provider: ^6.1.1` - State management
- `url_launcher: ^6.2.4` - Open apps/URLs
- `image_picker: ^1.0.7` - Camera access
- `permission_handler: ^11.3.0` - Permissions

## Limitations

- Volume control requires native Android setup
- Contact lookup needs contacts_service plugin
- Full background service needs flutter_background_service

## Future

- Phase 4: Contact lookup by name
- Phase 5: Background service (always listening)
- Phase 6: Wake word detection
- Phase 7: Smart home integration

## Developer

AC AI Team

## License

MIT License

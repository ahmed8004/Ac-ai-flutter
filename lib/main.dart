import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'models/orb_state.dart';
import 'screens/home_screen.dart';
import 'services/app_controller.dart';
import 'services/stt_service.dart';
import 'services/tts_service.dart';
import 'services/ai_brain_service.dart';
import 'services/command_processor.dart';
import 'services/permission_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const ACAIApp());
}

class ACAIApp extends StatelessWidget {
  const ACAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppController>(
          create: (_) => AppController(
            sttService: STTService(),
            ttsService: TTSService(),
            aiBrainService: AIBrainService(),
            commandProcessor: CommandProcessor(),
            permissionService: PermissionService(),
          ),
        ),
        ChangeNotifierProxyProvider<AppController, OrbController>(
          create: (_) => OrbController(),
          update: (_, appController, orbController) {
            return orbController ?? OrbController();
          },
        ),
      ],
      child: MaterialApp(
        title: 'AC AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}

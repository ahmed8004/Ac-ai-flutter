import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/orb_state.dart';
import '../services/app_controller.dart';
import '../widgets/orb_widget.dart';
import '../widgets/control_buttons.dart';
import '../widgets/settings_panel.dart';
import '../widgets/background_effect.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.4, begin: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppController()..initialize(),
      child: Consumer<AppController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundDark,
            body: Stack(
              children: [
                const BackgroundEffect(),
                
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: controller.statusMessage == 'Ready'
                              ? AppTheme.primaryCyan.withOpacity(0.2)
                              : AppTheme.orbProcessing.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: controller.statusMessage == 'Ready'
                                ? AppTheme.primaryCyan.withOpacity(0.5)
                                : AppTheme.orbProcessing.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          controller.statusMessage,
                          style: AppTheme.bodyText.copyWith(
                            color: controller.statusMessage == 'Ready'
                                ? AppTheme.primaryCyan
                                : AppTheme.orbProcessing,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      Expanded(
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return OrbWidget(
                                state: controller.isProcessingCommand
                                    ? OrbState.processing
                                    : OrbState.idle,
                                intensity: 0.5,
                              );
                            },
                          ),
                        ),
                      ),
                      
                      if (controller.lastAIResponse.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Text(
                            controller.lastAIResponse,
                            style: AppTheme.bodyText.copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      
                      const ControlButtons(),
                      
                      const SizedBox(height: 20),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.primaryCyan.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Say "AC AI" to activate',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.primaryCyan,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: AppTheme.primaryCyan,
                          size: 24,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: AppTheme.backgroundDark,
                            builder: (context) => const SettingsPanel(),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

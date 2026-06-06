import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ac_ai/models/orb_state.dart';
import 'package:ac_ai/widgets/orb_widget.dart';
import 'package:ac_ai/widgets/control_buttons.dart';
import 'package:ac_ai/widgets/settings_panel.dart';
import 'package:ac_ai/widgets/background_effect.dart';
import 'package:ac_ai/theme/app_theme.dart';
import 'package:ac_ai/services/app_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final appController = context.read<AppController>();
    await appController.initialize();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Consumer2<AppController, OrbController>(
        builder: (context, appController, orbController, child) {
          return Stack(
            children: [
              _buildBackground(),
              BackgroundEffect(
                state: orbController.state,
                color: orbController.currentColor,
              ),
              const OrbWidget(),
              const ControlButtons(),
              _buildSettingsFAB(),
              if (orbController.state == OrbState.listening ||
                  orbController.state == OrbState.processing ||
                  orbController.state == OrbState.speaking)
                _buildStatusText(orbController, appController),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.primaryCyan,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryCyan,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'AC AI',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Consumer<AppController>(
          builder: (context, controller, child) {
            return Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: controller.statusMessage == 'Ready'
                    ? AppTheme.primaryCyan.withValues(alpha: 0.2)
                    : AppTheme.orbProcessing.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.statusMessage == 'Ready'
                      ? AppTheme.primaryCyan.withValues(alpha: 0.5)
                      : AppTheme.orbProcessing.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Text(
                controller.statusMessage.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: controller.statusMessage == 'Ready'
                      ? AppTheme.primaryCyan
                      : AppTheme.orbProcessing,
                  letterSpacing: 1,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFF1A1A1A),
            AppTheme.bgPrimary,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsFAB() {
    return Positioned(
      right: 24,
      bottom: 140,
      child: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _fabController.value * 1.57,
            child: FloatingActionButton(
              heroTag: 'settings',
              onPressed: _openSettings,
              child: const Icon(Icons.settings),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusText(OrbController orbController, AppController appController) {
    String text;
    switch (orbController.state) {
      case OrbState.listening:
        text = 'Listening...';
        break;
      case OrbState.processing:
        text = 'Processing...';
        break;
      case OrbState.speaking:
        text = 'Speaking...';
        break;
      default:
        text = '';
    }

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.65,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: orbController.currentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: orbController.currentColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 14,
                  color: orbController.currentColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              if (appController.lastUserInput.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    appController.lastUserInput,
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    _fabController.forward();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return const SettingsPanel();
        },
      ),
    ).then((_) {
      _fabController.reverse();
    });
  }
}

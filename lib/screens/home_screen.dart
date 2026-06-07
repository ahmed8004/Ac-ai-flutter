import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/orb_state.dart';
import '../services/app_controller.dart';
import '../widgets/breathing_orb.dart';
import '../widgets/control_buttons.dart';
import '../widgets/settings_panel.dart';
import '../widgets/background_effect.dart';
import 'document_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
            backgroundColor: AppTheme.bgPrimary,
            body: Stack(
              children: [
                const BackgroundEffect(),
                
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      
                      // Status Bar with Material Design
                      _buildStatusBar(controller),
                      
                      const SizedBox(height: 8),
                      
                      // Document Button
                      _buildDocumentButton(context),
                      
                      Expanded(
                        child: Center(
                          child: BreathingOrb(
                            state: _getOrbState(controller),
                            onTap: () => controller.processVoiceInput(),
                          ),
                        ),
                      ),
                      
                      // Response Text
                      if (controller.lastAIResponse.isNotEmpty)
                        _buildResponseCard(controller.lastAIResponse),
                      
                      const ControlButtons(),
                      
                      const SizedBox(height: 16),
                      
                      // Quick Actions
                      _buildQuickActions(context, controller),
                      
                      const SizedBox(height: 16),
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

  Widget _buildStatusBar(AppController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getStatusColor(controller.statusMessage).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(controller.statusMessage),
            color: _getStatusColor(controller.statusMessage),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            controller.statusMessage,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DocumentScreen()),
          );
        },
        icon: const Icon(Icons.document_scanner, color: Colors.white),
        label: const Text(
          'Read Document',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryCyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildResponseCard(String response) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryCyan.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        response,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionChip('Torch', Icons.flashlight_on, () {
            controller.processTextInput('AC torch on');
          }),
          _buildActionChip('WiFi', Icons.wifi, () {
            controller.processTextInput('AC WiFi status');
          }),
          _buildActionChip('Volume', Icons.volume_up, () {
            controller.processTextInput('AC volume up');
          }),
          _buildActionChip('Settings', Icons.settings, () {
            showModalBottomSheet(
              context: context,
              backgroundColor: AppTheme.bgSecondary,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (context) => const SettingsPanel(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.primaryCyan, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  OrbState _getOrbState(AppController controller) {
    if (controller.isProcessingCommand) {
      if (controller.statusMessage.contains('Listening')) {
        return OrbState.listening;
      } else if (controller.statusMessage.contains('Processing')) {
        return OrbState.processing;
      } else if (controller.statusMessage.contains('Speaking')) {
        return OrbState.speaking;
      }
    }
    if (controller.statusMessage.contains('Error')) {
      return OrbState.error;
    }
    return OrbState.idle;
  }

  Color _getStatusColor(String status) {
    if (status.contains('Listening')) return AppTheme.listeningColor;
    if (status.contains('Processing')) return AppTheme.processingColor;
    if (status.contains('Speaking')) return AppTheme.speakingColor;
    if (status.contains('Error')) return AppTheme.errorColor;
    return AppTheme.primaryCyan;
  }

  IconData _getStatusIcon(String status) {
    if (status.contains('Listening')) return Icons.mic;
    if (status.contains('Processing')) return Icons.memory;
    if (status.contains('Speaking')) return Icons.volume_up;
    if (status.contains('Error')) return Icons.error_outline;
    return Icons.check_circle;
  }
}

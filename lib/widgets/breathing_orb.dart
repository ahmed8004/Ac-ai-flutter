import 'package:flutter/material.dart';
import '../models/orb_state.dart';
import '../theme/app_theme.dart';

class BreathingOrb extends StatefulWidget {
  final OrbState state;
  final VoidCallback? onTap;

  const BreathingOrb({
    super.key,
    required this.state,
    this.onTap,
  });

  @override
  State<BreathingOrb> createState() => _BreathingOrbState();
}

class _BreathingOrbState extends State<BreathingOrb>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _rotateController;
  late Animation<double> _breathAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didUpdateWidget(BreathingOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateAnimationForState();
    }
  }

  void _setupAnimations() {
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _breathAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.linear,
      ),
    );

    _updateAnimationForState();
  }

  void _updateAnimationForState() {
    switch (widget.state) {
      case OrbState.idle:
        _breathController.duration = const Duration(seconds: 3);
        _breathController.repeat(reverse: true);
        _rotateController.stop();
        break;
      case OrbState.listening:
        _breathController.duration = const Duration(milliseconds: 800);
        _breathController.repeat(reverse: true);
        _rotateController.stop();
        break;
      case OrbState.processing:
        _breathController.duration = const Duration(seconds: 1);
        _breathController.repeat(reverse: true);
        _rotateController.repeat();
        break;
      case OrbState.speaking:
        _breathController.duration = const Duration(milliseconds: 600);
        _breathController.repeat(reverse: true);
        _rotateController.stop();
        break;
      case OrbState.error:
        _breathController.duration = const Duration(milliseconds: 300);
        _breathController.repeat(reverse: true);
        _rotateController.stop();
        break;
      default:
        _breathController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathController, _rotateController]),
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotateAnimation.value * 2 * 3.14159,
            child: Transform.scale(
              scale: _breathAnimation.value,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getInnerColor(),
                      _getOuterColor(),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getGlowColor().withOpacity(0.6),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: _getGlowColor().withOpacity(0.3),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _getStateIcon(),
                    size: 60,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getInnerColor() {
    switch (widget.state) {
      case OrbState.idle:
        return AppTheme.idleColor.withOpacity(0.8);
      case OrbState.listening:
        return AppTheme.listeningColor;
      case OrbState.processing:
        return AppTheme.processingColor;
      case OrbState.speaking:
        return AppTheme.speakingColor;
      case OrbState.error:
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryCyan;
    }
  }

  Color _getOuterColor() {
    switch (widget.state) {
      case OrbState.idle:
        return AppTheme.idleColor.withOpacity(0.3);
      case OrbState.listening:
        return AppTheme.listeningColor.withOpacity(0.3);
      case OrbState.processing:
        return AppTheme.processingColor.withOpacity(0.3);
      case OrbState.speaking:
        return AppTheme.speakingColor.withOpacity(0.3);
      case OrbState.error:
        return AppTheme.errorColor.withOpacity(0.3);
      default:
        return AppTheme.primaryCyan.withOpacity(0.3);
    }
  }

  Color _getGlowColor() {
    switch (widget.state) {
      case OrbState.idle:
        return AppTheme.idleColor;
      case OrbState.listening:
        return AppTheme.listeningColor;
      case OrbState.processing:
        return AppTheme.processingColor;
      case OrbState.speaking:
        return AppTheme.speakingColor;
      case OrbState.error:
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryCyan;
    }
  }

  IconData _getStateIcon() {
    switch (widget.state) {
      case OrbState.idle:
        return Icons.mic_none;
      case OrbState.listening:
        return Icons.mic;
      case OrbState.processing:
        return Icons.memory;
      case OrbState.speaking:
        return Icons.volume_up;
      case OrbState.error:
        return Icons.error_outline;
      default:
        return Icons.circle;
    }
  }
}

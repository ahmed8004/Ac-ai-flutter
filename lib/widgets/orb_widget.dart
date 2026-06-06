import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/orb_state.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';

class OrbWidget extends StatefulWidget {
  const OrbWidget({Key? key}) : super(key: key);

  @override
  State<OrbWidget> createState() => _OrbWidgetState();
}

class _OrbWidgetState extends State<OrbWidget>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _rotationController;
  late AnimationController _rippleController;
  late AnimationController _shakeController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationUtils.createBreathingController(this);
    _rotationController = AnimationUtils.createRotationController(this);
    _rippleController = AnimationUtils.createRippleController(this);
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _breathingAnimation = AnimationUtils.createPulseAnimation(_breathingController);
    _shakeAnimation = AnimationUtils.createShakeAnimation(_shakeController);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _rotationController.dispose();
    _rippleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orbSize = screenWidth * 0.4;

    return Consumer<OrbController>(
      builder: (context, controller, child) {
        _handleStateAnimations(controller.state);

        final config = OrbStateConfig.getConfig(controller.state);
        
        return GestureDetector(
          onTap: () => _handleOrbTap(controller),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (controller.state == OrbState.listening)
                  _buildRipples(orbSize, config.color),
                _buildOrb(controller, config, orbSize),
                if (controller.state == OrbState.paused ||
                    controller.state == OrbState.stopped)
                  _buildStateIcon(controller.state),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStateAnimations(OrbState state) {
    switch (state) {
      case OrbState.idle:
        if (!_breathingController.isAnimating) {
          _breathingController.repeat(reverse: true);
        }
        break;
      case OrbState.error:
        _shakeController.forward(from: 0);
        break;
      case OrbState.paused:
      case OrbState.stopped:
        _breathingController.stop();
        break;
      default:
        break;
    }
  }

  Widget _buildRipples(double size, Color color) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return CustomPaint(
          size: Size(size * 3, size * 3),
          painter: RipplePainter(
            progress: _rippleController.value,
            color: color,
            rippleCount: 3,
          ),
        );
      },
    );
  }

  Widget _buildOrb(OrbController controller, OrbStateConfig config, double size) {
    Widget orb = AnimatedBuilder(
      animation: Listenable.merge([
        _breathingController,
        _rotationController,
        _shakeController,
      ]),
      builder: (context, child) {
        double scale = 1.0;
        double rotation = 0.0;
        double translateX = 0.0;

        switch (controller.state) {
          case OrbState.idle:
            scale = _breathingAnimation.value;
            break;
          case OrbState.listening:
          case OrbState.speaking:
            scale = AnimationUtils.getVoiceScale(controller.voiceLevel);
            break;
          case OrbState.processing:
            scale = _breathingAnimation.value;
            rotation = _rotationController.value;
            break;
          case OrbState.error:
            translateX = _shakeAnimation.value;
            break;
          case OrbState.stopped:
            scale = 0.9;
            break;
          default:
            scale = 1.0;
        }

        return Transform.translate(
          offset: Offset(translateX, 0),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: config.color.withOpacity(0.1),
                border: Border.all(
                  color: config.color,
                  width: controller.state == OrbState.paused ? 2 : 3,
                  style: BorderStyle.solid,
                ),
                boxShadow: AppTheme.getGlow(
                  config.color,
                  config.glowOpacity,
                  config.glowRadius,
                ),
              ),
              child: Stack(
                children: [
                  if (controller.state == OrbState.processing)
                    CustomPaint(
                      size: Size(size, size),
                      painter: RotatingGradientPainter(
                        rotation: rotation,
                        color: config.color,
                      ),
                    ),
                  if (controller.state == OrbState.speaking)
                    CustomPaint(
                      size: Size(size, size),
                      painter: WavePainter(
                        progress: controller.voiceLevel,
                        color: config.color,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return orb;
  }

  Widget _buildStateIcon(OrbState state) {
    IconData icon;
    if (state == OrbState.paused) {
      icon = Icons.pause;
    } else {
      icon = Icons.stop;
    }

    return Icon(
      icon,
      size: 60,
      color: Colors.white.withOpacity(0.8),
    );
  }

  void _handleOrbTap(OrbController controller) {
    if (controller.state == OrbState.idle) {
      controller.startListening();
    } else if (controller.state == OrbState.paused) {
      controller.resume();
    } else if (controller.state == OrbState.stopped) {
      controller.reset();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/orb_state.dart';
import '../theme/app_theme.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrbController>(
      builder: (context, controller, child) {
        return Stack(
          children: [
            Positioned(
              left: 24,
              bottom: 40,
              child: _ControlButton(
                icon: Icons.pause,
                color: AppTheme.buttonPause,
                onPressed: () => _handlePause(context, controller),
                isActive: !controller.isPaused && !controller.isStopped,
              ),
            ),
            Positioned(
              right: 24,
              bottom: 40,
              child: _ControlButton(
                icon: Icons.stop,
                color: AppTheme.buttonStop,
                onPressed: () => _handleStop(context, controller),
                isActive: !controller.isStopped,
              ),
            ),
          ],
        );
      },
    );
  }

  void _handlePause(BuildContext context, OrbController controller) {
    HapticFeedback.mediumImpact();
    
    if (controller.isPaused) {
      controller.resume();
      _showSnackBar(context, 'System resumed', AppTheme.buttonPause);
    } else {
      controller.pause();
      _showSnackBar(context, 'System paused', AppTheme.buttonPause);
    }
  }

  void _handleStop(BuildContext context, OrbController controller) {
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      builder: (context) => _StopConfirmationDialog(
        onConfirm: () {
          controller.stop();
          Navigator.pop(context);
          _showSnackBar(context, 'System stopped', AppTheme.buttonStop);
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'RobotoMono'),
        ),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isActive;

  const _ControlButton({
    Key? key,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isActive = true,
  }) : super(key: key);

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        if (widget.isActive) {
          widget.onPressed();
        }
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: AppTheme.getButtonDecoration(
                widget.color,
                _isPressed ? 0.5 : 0.3,
              ),
              child: Icon(
                widget.icon,
                color: widget.isActive
                    ? widget.color
                    : widget.color.withOpacity(0.5),
                size: 36,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StopConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _StopConfirmationDialog({
    Key? key,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.bgElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppTheme.buttonStop.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_rounded,
              color: AppTheme.buttonStop,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Stop AC AI?',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'This will shut down all services and stop the voice assistant.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(color: AppTheme.textSecondary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.buttonStop,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Stop'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimationUtils {
  static AnimationController createBreathingController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(seconds: 3),
      vsync: vsync,
    )..repeat(reverse: true);
  }

  static AnimationController createRotationController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    )..repeat();
  }

  static AnimationController createRippleController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    )..repeat();
  }

  static Animation<double> createPulseAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  static double getVoiceScale(double voiceLevel) {
    return 0.9 + (voiceLevel * 0.3);
  }

  static Animation<double> createShakeAnimation(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(controller);
  }
}

class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int rippleCount;

  RipplePainter({
    required this.progress,
    required this.color,
    this.rippleCount = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < rippleCount; i++) {
      final rippleProgress = (progress + (i / rippleCount)) % 1.0;
      final radius = maxRadius * rippleProgress;
      final opacity = (1.0 - rippleProgress) * 0.6;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + (progress * 2 * math.pi);
      final waveRadius = radius * (0.8 + 0.2 * math.sin(progress * 2 * math.pi));
      
      final x = center.dx + waveRadius * math.cos(angle);
      final y = center.dy + waveRadius * math.sin(angle);

      final paint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 8, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class RotatingGradientPainter extends CustomPainter {
  final double rotation;
  final Color color;

  RotatingGradientPainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);

    final gradient = SweepGradient(
      colors: [
        color.withOpacity(0.0),
        color.withOpacity(0.5),
        color.withOpacity(0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.8, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(RotatingGradientPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}

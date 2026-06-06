import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/orb_state.dart';

class BackgroundEffect extends StatefulWidget {
  final OrbState state;
  final Color color;

  const BackgroundEffect({
    Key? key,
    required this.state,
    required this.color,
  }) : super(key: key);

  @override
  State<BackgroundEffect> createState() => _BackgroundEffectState();
}

class _BackgroundEffectState extends State<BackgroundEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final int _particleCount = 20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _initializeParticles();
    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 100 + 50,
        speed: random.nextDouble() * 0.5 + 0.2,
        opacity: random.nextDouble() * 0.3 + 0.1,
      ));
    }
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.update();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state == OrbState.stopped || widget.state == OrbState.paused) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: ParticlePainter(
        particles: _particles,
        color: widget.color,
        progress: _controller.value,
      ),
      child: Container(),
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  void update() {
    y -= speed * 0.001;
    if (y < -0.1) {
      y = 1.1;
      x = math.Random().nextDouble();
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;
  final double progress;

  ParticlePainter({
    required this.particles,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final center = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      final gradient = RadialGradient(
        colors: [
          color.withOpacity(particle.opacity),
          color.withOpacity(0),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: particle.size),
        );

      canvas.drawCircle(center, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class BlurWave extends StatelessWidget {
  final Color color;
  final double delay;

  const BlurWave({
    Key? key,
    required this.color,
    this.delay = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 2000 + (delay * 1000).toInt()),
      builder: (context, value, child) {
        return Opacity(
          opacity: (1 - value) * 0.3,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0),
                ],
              ),
            ),
          ),
        );
      },
      onEnd: () {
      },
    );
  }
}

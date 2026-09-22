import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double rotation;
  double rotationSpeed;
  Color color;
  double opacity;
  int shape; // 0 = Circle, 1 = Star, 2 = Rectangle

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.opacity,
    required this.shape,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.25; // gravity
    vx *= 0.98; // air resistance
    vy *= 0.98;
    rotation += rotationSpeed;
    if (opacity > 0.006) {
      opacity -= 0.006;
    } else {
      opacity = 0;
    }
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      if (p.opacity <= 0) continue;
      paint.color = p.color.withValues(alpha: p.opacity);

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      if (p.shape == 0) {
        // Circle
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else if (p.shape == 1) {
        // 5-point Star
        _drawStar(canvas, Offset.zero, p.size, paint);
      } else {
        // Rectangle / Ribbon
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size * 1.5,
            height: p.size * 0.7,
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const int points = 5;
    final double innerRadius = size / 2.5;
    final double outerRadius = size;
    const double step = math.pi / points;
    double angle = -math.pi / 2;

    path.moveTo(
      center.dx + outerRadius * math.cos(angle),
      center.dy + outerRadius * math.sin(angle),
    );

    for (int i = 0; i < points * 2; i++) {
      angle += step;
      final double r = i.isEven ? innerRadius : outerRadius;
      path.lineTo(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConfettiOverlay extends StatefulWidget {
  final Widget? child;
  final Duration duration;
  final int particleCount;

  const ConfettiOverlay({
    super.key,
    this.child,
    this.duration = const Duration(seconds: 4),
    this.particleCount = 90,
  });

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  void play({Offset? origin}) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? MediaQuery.of(context).size;
    final startX = origin?.dx ?? size.width / 2;
    final startY = origin?.dy ?? size.height * 0.35;

    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      final double angle = -math.pi / 4 - _random.nextDouble() * (math.pi / 2);
      final double speed = 6 + _random.nextDouble() * 14;

      _particles.add(
        ConfettiParticle(
          x: startX,
          y: startY,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          size: 5 + _random.nextDouble() * 11,
          rotation: _random.nextDouble() * math.pi * 2,
          rotationSpeed: -0.15 + _random.nextDouble() * 0.3,
          color: _getRandomColor(),
          opacity: 1.0,
          shape: _random.nextInt(3),
        ),
      );
    }

    _animationController.reset();
    _animationController.repeat();
  }

  Color _getRandomColor() {
    const colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      Color(0xFFFF9F0A), // Orange
      Color(0xFFFFD60A), // Gold/Yellow
      Color(0xFF30D158), // Light Green
      Color(0xFF0A84FF), // Blue
      Color(0xFFFF453A), // Red
      Color(0xFFBF5AF2), // Purple
      Color(0xFFFF375F), // Pink
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (_animationController.isAnimating) {
                for (var p in _particles) {
                  p.update();
                }
                _particles.removeWhere((p) => p.opacity <= 0);
                if (_particles.isEmpty) {
                  _animationController.stop();
                }
              }
              return CustomPaint(
                size: Size.infinite,
                painter: ConfettiPainter(particles: _particles),
              );
            },
          ),
        ),
      ],
    );
  }
}

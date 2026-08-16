import 'dart:math';

import 'package:flutter/material.dart';

import '../models/logic_puzzle.dart';

class ShapeDiagram extends StatelessWidget {
  final ShapeSpec spec;
  final double size;

  const ShapeDiagram({super.key, required this.spec, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShapePainter(spec, Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final ShapeSpec spec;
  final Color inkColor;

  const _ShapePainter(this.spec, this.inkColor);

  @override
  void paint(Canvas canvas, Size size) {
    final mainRadius = size.shortestSide * 0.26 * spec.sizeScale;
    final mainCenter = Offset(size.width / 2, size.height * 0.4);

    final mainPaint = Paint()
      ..color = inkColor
      ..style = spec.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      _polygonPath(mainCenter, mainRadius, spec.shape.sides, spec.rotationSteps * pi / 4),
      mainPaint,
    );

    if (spec.secondaryCount > 0) {
      final rowY = size.height * 0.82;
      final dotRadius = size.shortestSide * 0.055;
      final spacing = dotRadius * 2.8;
      final totalWidth = (spec.secondaryCount - 1) * spacing;
      final startX = size.width / 2 - totalWidth / 2;
      final dotPaint = Paint()..color = inkColor;
      for (var i = 0; i < spec.secondaryCount; i++) {
        final center = Offset(startX + i * spacing, rowY);
        canvas.drawPath(_polygonPath(center, dotRadius, spec.secondaryShape.sides, 0), dotPaint);
      }
    }
  }

  Path _polygonPath(Offset center, double radius, int sides, double rotation) {
    if (sides <= 0) {
      return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    }
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = rotation + (2 * pi * i / sides) - pi / 2;
      final point = Offset(center.dx + radius * cos(angle), center.dy + radius * sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.spec != spec || oldDelegate.inkColor != inkColor;
}

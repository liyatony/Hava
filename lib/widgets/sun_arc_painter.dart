import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class SunArcPainter extends CustomPainter {
  final double progress;
  final DateTime sunriseTime;
  final DateTime sunsetTime;
  final DateTime currentTime;
  final bool isNight;

  SunArcPainter({
    required this.progress,
    required this.sunriseTime,
    required this.sunsetTime,
    required this.currentTime,
    required this.isNight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Define the arc's bounding rectangle
    final rect = Rect.fromLTRB(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.9,
      size.height * 1.8
    );

    // Draw the dashed part
    if (progress < 1.0) {
      final dashPath = Path()
        ..addArc(rect, pi, pi);
      
      final dashedPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      
      drawDashedPath(canvas, dashPath, dashedPaint);
    }

    // Draw progress path
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = isNight ? Colors.blue.shade400 : Colors.yellow.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        pi,
        pi * progress,
        false,
        progressPaint,
      );
    }

    // Calculate position exactly on the arc
    final angle = pi + (pi * progress);
    final a = rect.width / 2;  // Semi-major axis
    final b = rect.height / 2; // Semi-minor axis
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    
    // Parametric equations for ellipse
    final posX = centerX + a * cos(angle);
    final posY = centerY + b * sin(angle);

    // Draw sun/moon icon
    canvas.save();
    canvas.translate(posX, posY);
    
    if (isNight) {
      _drawMoon(canvas, 8);
    } else {
      _drawSun(canvas, 6);
    }
    
    canvas.restore();
  }

  void _drawSun(Canvas canvas, double radius) {
    final paint = Paint()
      ..color = Colors.yellow.shade600
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, radius, paint);

    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;

    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final start = Offset(cos(angle) * (radius + 2), sin(angle) * (radius + 2));
      final end = Offset(cos(angle) * (radius + 4), sin(angle) * (radius + 4));
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawMoon(Canvas canvas, double radius) {
    final paint = Paint()
      ..color = Colors.blue.shade400
      ..style = PaintingStyle.fill;

    // Define the main moon shape
    final moonPath = Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: radius * 1.2));

    // Define the cutout circle for the crescent effect
    final cutoutPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(radius * 0.6, 0), radius: radius * 0.95));

    // Subtract the cutout from the main moon to create a perfect crescent
    final crescentPath = Path.combine(PathOperation.difference, moonPath, cutoutPath);

    // Draw the crescent
    canvas.drawPath(crescentPath, paint);
  }

  void drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashWidth = 3.0;
    final dashSpace = 5.0;
    final metrics = path.computeMetrics().first;
    var distance = 0.0;
    
    while (distance < metrics.length) {
      if (distance + dashWidth > metrics.length) {
        final pathSegment = metrics.extractPath(distance, metrics.length);
        canvas.drawPath(pathSegment, paint);
        break;
      } else {
        final pathSegment = metrics.extractPath(distance, distance + dashWidth);
        canvas.drawPath(pathSegment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.sunriseTime != sunriseTime ||
           oldDelegate.sunsetTime != sunsetTime ||
           oldDelegate.currentTime != currentTime ||
           oldDelegate.isNight != isNight;
  }
}
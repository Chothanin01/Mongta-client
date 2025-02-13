// custom_step_indicator.dart
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';


class CustomStepIndicator extends StatelessWidget {
  final PageController controller;
  final int count;
  final Color activeColor;
  final Color inactiveColor;

  const CustomStepIndicator({
    super.key,
    required this.controller,
    required this.count,
    this.activeColor = MainTheme.activeDot,
    this.inactiveColor = MainTheme.redWarning,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double page = controller.hasClients ? controller.page ?? 0 : 0;
        return CustomPaint(
          size: Size(200, 30), // Increased width for better spacing
          painter: StepPainter(
            currentStep: page.round(),
            totalSteps: count,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            progress: page - page.floor(),
          ),
        );
      },
    );
  }
}

class StepPainter extends CustomPainter {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;
  final double progress;

  StepPainter({
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final double circleRadius = 12; // Increased circle size
    final double spacing = (size.width - (circleRadius * 2 * totalSteps)) / (totalSteps - 1);

    // Draw lines first (behind circles)
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    for (int i = 0; i < totalSteps - 1; i++) {
      final start = Offset(circleRadius + (i * (spacing + circleRadius * 2)), size.height / 2);
      final end = Offset(start.dx + spacing + circleRadius * 2, size.height / 2);
      
      if (i < currentStep) {
        paint.color = activeColor;
      } else if (i == currentStep) {
        paint.color = Color.lerp(inactiveColor, activeColor, progress) ?? inactiveColor;
      } else {
        paint.color = inactiveColor;
      }
      canvas.drawLine(start, end, paint);
    }

    // Draw circles
    for (int i = 0; i < totalSteps; i++) {
      final center = Offset(circleRadius + (i * (spacing + circleRadius * 2)), size.height / 2);
      
      if (i < currentStep) {
        // Completed step
        paint.style = PaintingStyle.fill;
        paint.color = activeColor;
        canvas.drawCircle(center, circleRadius, paint);

        // Draw checkmark
        final checkPath = Path();
        checkPath.moveTo(center.dx - 4, center.dy);
        checkPath.lineTo(center.dx - 1, center.dy + 3);
        checkPath.lineTo(center.dx + 4, center.dy - 2);

        final checkPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawPath(checkPath, checkPaint);

      } else if (i == currentStep) {
        // Current step
        paint.style = PaintingStyle.fill;
        paint.color = activeColor;
        canvas.drawCircle(center, circleRadius, paint);
        
        // Draw number
        _drawNumber(canvas, center, (i + 1).toString());

      } else {
        // Future step
        paint.style = PaintingStyle.stroke;
        paint.color = inactiveColor;
        canvas.drawCircle(center, circleRadius, paint);
        
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(center, circleRadius - 1, Paint()..color = Colors.white);
        
        _drawNumber(canvas, center, (i + 1).toString(), isActive: false);
      }
    }
  }

  void _drawNumber(Canvas canvas, Offset center, String number, {bool isActive = true}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: number,
        style: TextStyle(
          color: isActive ? MainTheme.white : inactiveColor,
          fontSize: 14,
          fontFamily: 'BaiJamjuree',
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center + Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(StepPainter oldDelegate) =>
      oldDelegate.currentStep != currentStep ||
      oldDelegate.progress != progress ||
      oldDelegate.activeColor != activeColor ||
      oldDelegate.inactiveColor != inactiveColor;
}
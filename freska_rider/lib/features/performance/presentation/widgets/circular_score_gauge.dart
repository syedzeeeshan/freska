import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/stitch_colors.dart';

class CircularScoreGauge extends StatelessWidget {
  final double score;
  final double maxScore;
  final String label;
  final double size;
  final Color activeColor;

  const CircularScoreGauge({
    super.key,
    required this.score,
    this.maxScore = 5.0,
    required this.label,
    this.size = 110,
    this.activeColor = StitchColors.accentGold,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (score / (maxScore > 0 ? maxScore : 5.0)).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GaugePainter(
              progress: progress,
              color: activeColor,
              backgroundColor: StitchColors.darkSurfaceElevated,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: size * 0.26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.10,
                  color: StitchColors.textSecondaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

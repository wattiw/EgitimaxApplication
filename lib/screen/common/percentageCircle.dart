import 'package:flutter/material.dart';

class PercentageCircle extends StatefulWidget {
  final double percentage;

  PercentageCircle({required this.percentage});

  @override
  _PercentageCircleState createState() => _PercentageCircleState();
}

class _PercentageCircleState extends State<PercentageCircle> {
  double maxSize = 400.0; // Maksimum boyut

  @override
  Widget build(BuildContext context) {
    Color greenColor = Colors.green;
    Color redColor = Colors.red;

    double size = widget.percentage * maxSize / 100.0;

    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CirclePainter(
          percentage: widget.percentage,
          greenColor: greenColor,
          redColor: redColor,
        ),
        child: Center(
          child: Text(
            '${widget.percentage.toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final double percentage;
  final Color greenColor;
  final Color redColor;

  CirclePainter({required this.percentage, required this.greenColor, required this.redColor});

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    Paint greenPaint = Paint()
      ..color = redColor
      ..style = PaintingStyle.fill;

    Paint redPaint = Paint()
      ..color = greenColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, greenPaint);

    double sweepAngle = 2 * percentage * 3.14 / 100;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14 / 2,
      sweepAngle,
      true,
      redPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

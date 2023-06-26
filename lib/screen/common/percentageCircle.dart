import 'package:flutter/material.dart';

class PercentageCircle extends StatefulWidget {
  final double percentage;

  PercentageCircle({required this.percentage});

  @override
  _PercentageCircleState createState() => _PercentageCircleState();
}

class _PercentageCircleState extends State<PercentageCircle> {
  double maxSize = 200.0; // Maksimum boyut

  @override
  Widget build(BuildContext context) {
    Color greenColor =  Color(int.parse('0xFF20C966')) ;
    Color redColor =  Color(int.parse('0xFFF6CECC'));

    double size = maxSize;//widget.percentage * maxSize / 100.0;

    if (widget.percentage == 0) {
      return Container(
        width: size,
        height: size,
        child: const Center(
          child: Text(
            '0%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

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

    if (percentage > 0) {
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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_card, size: 75, color: Colors.grey),
              SizedBox(height: 20),
            ],
          ),
        ),
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                const Text(
                  "No items so far.\nClick '+' to start",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                CustomPaint(
                  size: const Size(380, 100),
                  painter: ArcArrowPainter(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ArcArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();

    // Starting point (center, slightly below the text)
    path.moveTo(size.width - size.width / 3.2, 0);

    // Draw the arc
    path.arcToPoint(
      Offset(size.width / 1.67, size.height),
      radius: Radius.circular(size.height),
      clockwise: true,
    );

    canvas.drawPath(path, paint);

    // Draw arrowhead
    const arrowSize = 10.0;
    final arrowPath = Path();
    arrowPath.moveTo(size.width / 1.67 - arrowSize, size.height * 1.05);
    arrowPath.lineTo(size.width / 1.67 + arrowSize / 1.65, size.height - arrowSize / 0.6);
    arrowPath.lineTo(size.width / 1.67 + arrowSize / 1.1, size.height + arrowSize / 5);
    arrowPath.close();

    final arrowPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
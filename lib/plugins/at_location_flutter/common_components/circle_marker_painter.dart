import 'package:flutter/material.dart';

class CircleMarkerPainter extends CustomPainter {
  Color color;
  CircleMarkerPainter({this.color});
  final _paint = Paint()
    ..color = Colors.orange
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = color ?? Colors.orange;
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class _GroupPoints {
  Offset offset;
  Color color;
  _GroupPoints({this.offset, this.color});
}

class Signature extends CustomPainter {
  List<_GroupPoints> points;
  Color color;
  Signature({
    this.color,
    this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      // if you need this next params as dynamic, you can move it inside the for part
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (var i = 0; i < newPoints.length - 1; i++) {
      paint.color = points[i].color;
      if (points[i].offset != null && points[i + 1].offset != null) {
        canvas.drawLine(points[i].offset, points[i + 1].offset, paint);
      }
      canvas.clipRect(Offset.zero & size);
    }
  }

  @override
  bool shouldRepaint(Signature oldDelegate) => true;
}

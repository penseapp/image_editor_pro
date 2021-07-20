part of image_editor_pro;

class IndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path;

    // The arrows usually looks better with rounded caps.
    var paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0;

    /// Draw a single arrow.
    path = Path();
    path.moveTo(pointInitial.dx, pointInitial.dy);
    path.cubicTo(pointFinal.dx, pointFinal.dy, pointFinal.dx, pointFinal.dy,
        pointFinal.dx, pointFinal.dy);
    path = ArrowPath.make(path: path);

    canvas.drawPath(path, paint..color = Colors.blue);

    indicators.forEach((offset) {
      path = Path();
      path.moveTo(offset.pointInitial.dx, offset.pointInitial.dy);
      path.cubicTo(
        offset.pointFinal.dx,
        offset.pointFinal.dy,
        offset.pointFinal.dx,
        offset.pointFinal.dy,
        offset.pointFinal.dx,
        offset.pointFinal.dy,
      );
      path = ArrowPath.make(path: path);

      canvas.drawPath(path, paint..color = Colors.blue);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

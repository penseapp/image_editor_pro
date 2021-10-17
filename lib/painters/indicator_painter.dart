part of image_editor_pro;

class IndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path;

    // The arrows usually looks better with rounded caps.
    var paint = Paint()
      ..color = selectedColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = selectedSize;

    /// Draw a single arrow.
    path = Path();
    path.moveTo(pointInitial.dx, pointInitial.dy);
    path.cubicTo(pointFinal.dx, pointFinal.dy, pointFinal.dx, pointFinal.dy,
        pointFinal.dx, pointFinal.dy);
    try {
      path = ArrowPath.make(path: path);
    } catch (e) {}

    canvas.drawPath(
        path,
        paint
          ..color = selectedColor
          ..strokeWidth = selectedSize);

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

      canvas.drawPath(
          path,
          paint
            ..color = offset.color
            ..strokeWidth = offset.size);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

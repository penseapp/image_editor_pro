part of image_editor_pro;

const double STROKE = 9.0;
const double ARROW_ANGLE = 75.0;

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
      ..strokeWidth = 1;

    /// Draw a single arrow.
    path = Path();
    path.moveTo(pointInitial.dx, pointInitial.dy);
    path.cubicTo(pointFinal.dx, pointFinal.dy, pointFinal.dx, pointFinal.dy, pointFinal.dx, pointFinal.dy);
    try {
      path = ArrowPath.make(
        path: path,
        tipAngle: ARROW_ANGLE,
        tipLength: ARROW_ANGLE,
        isAdjusted: true,
      );
    } catch (e) {}

    canvas.drawPath(
        path,
        paint
          ..color = selectedColor
          ..strokeWidth = STROKE);

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
      path = ArrowPath.make(
        path: path,
        tipAngle: ARROW_ANGLE,
        tipLength: ARROW_ANGLE,
        isAdjusted: true,
      );

      canvas.drawPath(
          path,
          paint
            ..color = offset.color
            ..strokeWidth = STROKE);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

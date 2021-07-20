part of image_editor_pro;

class SquarePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = selectedColor
      ..strokeWidth = selectedSize
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromPoints(globalSquareA, globalSquareB), paint);

    squares.forEach((offset) => canvas.drawRect(
        Rect.fromPoints(offset.a, offset.b),
        paint
          ..color = offset.color
          ..strokeWidth = offset.size));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

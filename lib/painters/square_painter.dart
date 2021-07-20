part of image_editor_pro;

class SquarePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromPoints(globalSquareA, globalSquareB), paint);

    squares.forEach((offset) =>
        canvas.drawRect(Rect.fromPoints(offset.a, offset.b), paint));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

part of image_editor_pro;

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = selectedColor
      ..strokeWidth = selectedSize
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
        radiusCenter,
        sizeCircle.toDouble(),
        paint
          ..color = selectedColor
          ..strokeWidth = selectedSize);

    circles.forEach((offset) => canvas.drawCircle(
        offset.radiusCenter,
        offset.sizeCircle.toDouble(),
        paint
          ..color = offset.color
          ..strokeWidth = offset.size));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

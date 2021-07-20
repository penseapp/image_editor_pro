part of image_editor_pro;

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(radiusCenter, sizeCircle.toDouble(), paint);

    circles.forEach((offset) => canvas.drawCircle(
        offset.radiusCenter, offset.sizeCircle.toDouble(), paint));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

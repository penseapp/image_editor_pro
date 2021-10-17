part of image_editor_pro;

class StartEnd {
  StartEnd({
    this.start,
    this.end,
  });

  int start;
  int end;
}

class PointsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = selectedColor
      ..strokeWidth = selectedSize
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // ignore: omit_local_variable_types
    var myList = {};

    var actualIndex = 0;
    var lastIndex = 0;
    points.asMap().forEach((index, element) {
      if (element == null) {
        actualIndex++;
        lastIndex = index;
      } else {
        // myList.update(
        // actualIndex, (value) => List.from(points).sublist(lastIndex));
        myList.putIfAbsent(
            actualIndex, () => List.from(points).sublist(lastIndex));
      }
    });

    myList.forEach((key, pointsArr) {
      List<dynamic> tmp = pointsArr;
      tmp.asMap().forEach((index, value) {
        // print("index: " + index.toString());
        // print("element: " + value.toString());
        if (value != null && tmp[index + 1] != null) {
          canvas.drawLine(value, tmp[index + 1], paint);
        }
      });
    });
    // canvas.drawPoints(PointMode.polygon, internalPoints, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

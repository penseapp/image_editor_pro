import 'package:flutter/painting.dart';

class OffsetSquare {
  Offset a;
  Offset b;
  Color color;
  double size;

  OffsetSquare(this.a, this.b, this.color, this.size);
}

class OffsetCircle {
  Offset radiusCenter;
  int sizeCircle;
  Color color;
  double size;

  OffsetCircle({
    this.radiusCenter,
    this.sizeCircle,
    this.color,
    this.size
  });
}

class OffsetIndicator {
  Offset pointInitial;
  Offset pointFinal;
  Color color;
  double size;

  OffsetIndicator({
    this.pointInitial,
    this.pointFinal,
    this.color,
    this.size
  });
}

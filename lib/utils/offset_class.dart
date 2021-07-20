import 'package:flutter/painting.dart';

class OffsetSquare {
  Offset a;
  Offset b;

  OffsetSquare(this.a, this.b);
}

class OffsetCircle {
  Offset radiusCenter;
  int sizeCircle;

  OffsetCircle({
    this.radiusCenter,
    this.sizeCircle,
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

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:arrow_path/arrow_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_editor_pro/modules/bottombar_container.dart';
import 'package:image_editor_pro/modules/colors_picker.dart';
import 'package:image_editor_pro/modules/textview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';

TextEditingController heightcontroler = TextEditingController();
TextEditingController widthcontroler = TextEditingController();
var width = 300;
var height = 300;
Offset squareA;
Offset squareB;
Offset radiusCenter;
Offset pointInitial;
Offset pointFinal;
var sizeCircle = 0;
var componentState;
var component;
var drawState;
var squareStack = CustomPaint(
  painter: SquarePainter(),
  child: Container(),
);

final List<OffsetBla> squares = [];

List fontsize = [];
var howmuchwidgetis = 0;
List multiwidget = [];
Color currentcolors = Colors.white;
var opicity = 0.0;
SignatureController _controller =
    SignatureController(penStrokeWidth: 5, penColor: Colors.green);

class ImageEditorPro extends StatefulWidget {
  final Color appBarColor;
  final Color bottomBarColor;

  ImageEditorPro({this.appBarColor, this.bottomBarColor});

  @override
  _ImageEditorProState createState() => _ImageEditorProState();
}

var slider = 0.0;

class _ImageEditorProState extends State<ImageEditorPro> {
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
    var points = _controller.points;
    _controller =
        SignatureController(penStrokeWidth: 5, penColor: color, points: points);
  }

  List<Offset> offsets = [];
  Offset offset1 = Offset.zero;
  Offset offset2 = Offset.zero;
  final scaf = GlobalKey<ScaffoldState>();
  var openbottomsheet = false;
  List<Offset> _points = <Offset>[];
  List type = [];
  List aligment = [];

  final GlobalKey container = GlobalKey();
  final GlobalKey globalKey = GlobalKey();
  File _image;
  ScreenshotController screenshotController = ScreenshotController();
  Timer timeprediction;

  void timers() {
    Timer.periodic(Duration(milliseconds: 10), (tim) {
      setState(() {});
      timeprediction = tim;
    });
  }

  @override
  void dispose() {
    timeprediction.cancel();

    super.dispose();
  }

  @override
  void initState() {
    timers();
    _controller.clear();
    type.clear();
    fontsize.clear();
    offsets.clear();
    multiwidget.clear();
    howmuchwidgetis = 0;
    componentState = 'Square';
    component = square();
    squareA = Offset(0.0, 0.0);
    squareB = Offset(0.0, 0.0);
    radiusCenter = Offset(0.0, 0.0);
    pointInitial = Offset(0.0, 0.0);
    pointFinal = Offset(0.0, 0.0);
    drawState = 'Brush';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        key: scaf,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _controller.points.clear();
                  setState(() {});
                }),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _controller.clear();
                  type.clear();
                  fontsize.clear();
                  offsets.clear();
                  multiwidget.clear();
                  howmuchwidgetis = 0;
                  setState(() {});
                }),
            IconButton(icon: Icon(Icons.check), onPressed: captureImg),
          ],
          backgroundColor: widget.appBarColor,
        ),
        body: Center(
          child: Screenshot(
            controller: screenshotController,
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RepaintBoundary(
                  key: globalKey,
                  child: Stack(
                    children: <Widget>[
                      _image != null
                          ? Image.file(
                              _image,
                              height: height.toDouble(),
                              width: width.toDouble(),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                            ),
                      drawSelector(),
                      Stack(
                        children: multiwidget.asMap().entries.map((f) {
                          return type[f.key] == 2
                              ? TextView(
                                  left: offsets[f.key].dx,
                                  top: offsets[f.key].dy,
                                  ontap: () {
                                    scaf.currentState
                                        .showBottomSheet((context) {
                                      return Sliders(
                                        size: f.key,
                                        sizevalue: fontsize[f.key].toDouble(),
                                      );
                                    });
                                  },
                                  onpanupdate: (details) {
                                    setState(() {
                                      offsets[f.key] = Offset(
                                          offsets[f.key].dx + details.delta.dx,
                                          offsets[f.key].dy + details.delta.dy);
                                    });
                                  },
                                  value: f.value.toString(),
                                  fontsize: fontsize[f.key].toDouble(),
                                  align: TextAlign.center,
                                )
                              : Container();
                        }).toList(),
                      )
                    ],
                  )),
            ),
          ),
        ),
        bottomNavigationBar: openbottomsheet
            ? Container()
            : Container(
                decoration: BoxDecoration(
                    color: widget.bottomBarColor,
                    boxShadow: [BoxShadow(blurRadius: 10.9)]),
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    brush(),
                    BottomBarContainer(
                      icons: Icons.text_fields,
                      ontap: () async {
                        String value;

                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: SingleChildScrollView(
                                child: TextField(
                                  decoration: InputDecoration(
                                      labelText: "Adicione um texto"),
                                  keyboardType: TextInputType.multiline,
                                  onChanged: (r) => value = r,
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: const Text('Salvar'),
                                  onPressed: () {
                                    if (value != null) {
                                      type.add(2);
                                      fontsize.add(20);
                                      offsets.add(Offset.zero);
                                      multiwidget.add(value);
                                      howmuchwidgetis++;
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      title: 'Texto',
                    ),
                    BottomBarContainer(
                      icons: Icons.camera,
                      ontap: () {
                        bottomsheets();
                      },
                      title: 'Foto',
                    ),
                    BottomBarContainer(
                      icons: Icons.arrow_upward,
                      ontap: () {
                        drawState = 'Arrow';
                        _controller.clear();
                        type.clear();
                        fontsize.clear();
                        offsets.clear();
                        multiwidget.clear();
                        howmuchwidgetis = 0;
                      },
                      title: 'Indicador',
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          switch (componentState) {
                            case 'Square':
                              componentState = 'Circle';
                              component = circle();
                              setState(() {
                                drawState = 'Circle';
                              });
                              break;

                            case 'Circle':
                              componentState = 'Square';
                              component = square();
                              setState(() {
                                drawState = 'Square';
                              });
                              break;
                          }
                        });
                      },
                      child: component,
                    ),
                  ],
                ),
              ));
  }

  Widget brush() {
    return BottomBarContainer(
      colors: widget.bottomBarColor,
      icons: Icons.brush,
      ontap: () {
        // raise the [showDialog] widget
        setState(() {
          drawState = 'Brush';
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Pick a color!'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: changeColor,
                  showLabel: true,
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text('Got it'),
                  onPressed: () {
                    setState(() => currentColor = pickerColor);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      title: 'Pincel',
    );
  }

  Widget square() {
    return BottomBarContainer(
      colors: widget.bottomBarColor,
      icons: Icons.crop_square,
      title: 'Quadrado',
    );
  }

  Widget circle() {
    return BottomBarContainer(
      colors: widget.bottomBarColor,
      icons: Icons.circle,
      title: 'Circulo',
    );
  }

  final picker = ImagePicker();

  void bottomsheets() {
    openbottomsheet = true;
    setState(() {});
    var future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(blurRadius: 10.9, color: Colors.grey[400])
          ]),
          height: 170,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Selecione uma Imagem'),
              ),
              Divider(
                height: 1,
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              IconButton(
                                  icon: Icon(Icons.photo_library),
                                  onPressed: () async {
                                    var image = await picker.getImage(
                                        source: ImageSource.gallery);
                                    var decodedImage =
                                        await decodeImageFromList(
                                            File(image.path).readAsBytesSync());

                                    setState(() {
                                      height = decodedImage.height;
                                      width = decodedImage.width;
                                      _image = File(image.path);
                                    });
                                    setState(() => _controller.clear());
                                    Navigator.pop(context);
                                  }),
                              SizedBox(width: 10),
                              Text('Selecionar Foto')
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 24),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.camera_alt),
                                onPressed: () async {
                                  var image = await picker.getImage(
                                      source: ImageSource.camera);
                                  var decodedImage = await decodeImageFromList(
                                      File(image.path).readAsBytesSync());

                                  setState(() {
                                    height = decodedImage.height;
                                    width = decodedImage.width;
                                    _image = File(image.path);
                                  });
                                  setState(() => _controller.clear());
                                  Navigator.pop(context);
                                }),
                            SizedBox(width: 10),
                            Text('Abrir Camera')
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
    openbottomsheet = false;
    setState(() {});
  }

  void captureImg() {
    screenshotController
        .capture(delay: Duration(milliseconds: 500), pixelRatio: 1.5)
        .then((File image) async {
      //print("Capture Done");

      final paths = await getExternalStorageDirectory();
      await image.copy(paths.path +
          '/' +
          DateTime.now().millisecondsSinceEpoch.toString() +
          '.png');
      Navigator.pop(context, image);
    }).catchError((onError) {
      print(onError);
    });
  }

  Widget drawSelector() {
    switch (drawState) {
      case 'Brush':
        return GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                RenderBox object = context.findRenderObject();
                var _localPosition =
                    object.globalToLocal(details.globalPosition);
                _points = List.from(_points)..add(_localPosition);
              });
            },
            onPanEnd: (DragEndDetails details) {
              _points.add(null);
            },
            child: Signat());
        break;
      case 'Square':
        return GestureDetector(
          onPanDown: (DragDownDetails details) {
            print(details.localPosition);
            setState(() {
              squareA = details.localPosition;
            });
          },
          onPanUpdate: (DragUpdateDetails details) {
            print(details.localPosition);
            setState(() {
              squareB = details.localPosition;
            });
            squareStack = CustomPaint(
              painter: SquarePainter(),
              child: Container(),
            );
          },
          onPanEnd: (details) {
            squares.add(OffsetBla(squareA, squareB));
            setState(() {
              squareStack = CustomPaint(
                painter: SquarePainter(),
                child: Container(),
              );
            });
          },
          child: squareStack,
        );
        break;
      case 'Circle':
        return GestureDetector(
          onPanDown: (DragDownDetails details) {
            print(details.localPosition);
            setState(() {
              radiusCenter = details.localPosition;
            });
          },
          onPanUpdate: (DragUpdateDetails details) {
            print(details.localPosition);
            setState(() {
              squareB = details.localPosition;
              sizeCircle = sqrt(pow((squareB.dy - radiusCenter.dy), 2) +
                      pow((squareB.dx - radiusCenter.dx), 2))
                  .toInt();
            });
          },
          child: CustomPaint(
            painter: CirclePainter(),
            child: Container(),
          ),
        );
        break;
      case 'Arrow':
        return GestureDetector(
          onPanDown: (DragDownDetails details) {
            print(details.localPosition);
            setState(() {
              pointInitial = details.localPosition;
            });
          },
          onPanUpdate: (DragUpdateDetails details) {
            print(details.localPosition);
            setState(() {
              pointFinal = details.localPosition;
            });
          },
          child: CustomPaint(
            painter: ArrowPainter(),
            child: Container(),
          ),
        );
        break;
    }
    return Container();
  }
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(radiusCenter, sizeCircle.toDouble(), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ArrowPainter extends CustomPainter {
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class OffsetBla {
  Offset a;
  Offset b;

  OffsetBla(this.a, this.b);
}

class SquarePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(Rect.fromPoints(squareA, squareB), paint);

    squares.forEach((offset) =>
        canvas.drawRect(Rect.fromPoints(offset.a, offset.b), paint));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Signat extends StatefulWidget {
  @override
  _SignatState createState() => _SignatState();
}

class _SignatState extends State<Signat> {
  @override
  void initState() {
    super.initState();
    _controller.addListener(() => print('Value changed'));
  }

  @override
  Widget build(BuildContext context) {
    return //SIGNATURE CANVAS
        //SIGNATURE CANVAS
        ListView(
      children: <Widget>[
        Signature(
            controller: _controller,
            height: height.toDouble(),
            width: width.toDouble(),
            backgroundColor: Colors.transparent),
      ],
    );
  }
}

class Sliders extends StatefulWidget {
  final int size;
  final sizevalue;

  const Sliders({Key key, this.size, this.sizevalue}) : super(key: key);

  @override
  _SlidersState createState() => _SlidersState();
}

class _SlidersState extends State<Sliders> {
  @override
  void initState() {
    slider = widget.sizevalue;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Tamanho'),
            ),
            Divider(
              height: 1,
            ),
            Slider(
                value: slider,
                min: 0.0,
                max: 100.0,
                onChangeEnd: (v) {
                  setState(() {
                    fontsize[widget.size] = v.toInt();
                  });
                },
                onChanged: (v) {
                  setState(() {
                    slider = v;
                    print(v.toInt());
                    fontsize[widget.size] = v.toInt();
                  });
                }),
          ],
        ));
  }
}

class ColorPiskersSlider extends StatefulWidget {
  @override
  _ColorPiskersSliderState createState() => _ColorPiskersSliderState();
}

class _ColorPiskersSliderState extends State<ColorPiskersSlider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 260,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text('Slider Filter Color'),
          ),
          Divider(
            height: 1,
          ),
          SizedBox(height: 20),
          Text('Slider Color'),
          SizedBox(height: 10),
          BarColorPicker(
              width: 300,
              thumbColor: Colors.white,
              cornerRadius: 10,
              pickMode: PickMode.Color,
              colorListener: (int value) {
                setState(() {
                  //  currentColor = Color(value);
                });
              }),
          SizedBox(height: 20),
          Text('Slider Opicity'),
          SizedBox(height: 10),
          Slider(value: 0.1, min: 0.0, max: 1.0, onChanged: (v) {})
        ],
      ),
    );
  }
}

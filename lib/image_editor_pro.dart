library image_editor_pro;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:arrow_path/arrow_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_editor_pro/constants/picker_state_constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';
import 'package:image_editor_pro/utils/offset_class.dart';

import 'package:image_editor_pro/modules/bottombar_container.dart';
import 'package:image_editor_pro/modules/colors_picker.dart';
import 'package:image_editor_pro/modules/textview.dart';

part 'painters/square_painter.dart';
part 'painters/circle_painter.dart';
part 'painters/indicator_painter.dart';

part 'widgets/signat.dart';
part 'widgets/color_pickers_slider.dart';
part 'widgets/sliders.dart';
part 'widgets/bottom_navigation_bar/text_bottom_bar_container.dart';
part 'widgets/bottom_navigation_bar/circle_bottom_bar_container.dart';
part 'widgets/bottom_navigation_bar/square_bottom_bar_container.dart';

TextEditingController heightcontroler = TextEditingController();
TextEditingController widthcontroler = TextEditingController();
int width = 300;
int height = 300;

Offset globalSquareA;
Offset globalSquareB;
Offset globalCircleCenter;
Offset radiusCenter;
Offset pointInitial;
Offset pointFinal;
int sizeCircle = 0;

var componentState;
var component;
var drawState;

List<OffsetSquare> squares = [];
CustomPaint squareStack = CustomPaint(
  painter: SquarePainter(),
  child: Container(),
);

List<OffsetCircle> circles = [];
CustomPaint circleStack = CustomPaint(
  painter: CirclePainter(),
  child: Container(),
);

List<OffsetIndicator> indicators = [];
CustomPaint indicatorStack = CustomPaint(
  painter: IndicatorPainter(),
  child: Container(),
);

List fontsize = [];
int howmuchwidgetis = 0;
List multiwidget = [];
Color currentcolors = Colors.white;
double opacity = 0.0;
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
    componentState = PickerStateConstant.square;
    component = SquareBottomBarContainer(bottomBarColor: widget.bottomBarColor);
    globalSquareA = Offset(-9000, 0.0);
    globalSquareB = Offset(-9000, 0.0);
    globalCircleCenter = Offset(-9000, 0.0);
    radiusCenter = Offset(-9000, 0.0);
    pointInitial = Offset(-9000, 0.0);
    pointFinal = Offset(-9000, 0.0);
    squares.clear();
    circles.clear();
    indicators.clear();
    drawState = PickerStateConstant.brush;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        key: scaf,
        appBar: AppBar(
          actions: <Widget>[
            // IconButton(
            //     icon: Icon(Icons.clear),
            //     onPressed: () {
            //       _controller.points.clear();
            //       squares = [];
            //       circles = [];
            //       indicators = [];
            //       setState(() {});
            //     }),
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _controller.clear();
                  type.clear();
                  fontsize.clear();
                  offsets.clear();
                  multiwidget.clear();
                  howmuchwidgetis = 0;
                  globalSquareA = Offset(-9000, 0);
                  globalSquareB = Offset(-9000, 0);
                  globalCircleCenter = Offset(-9000, 0);
                  radiusCenter = Offset(-9000, 0);
                  pointInitial = Offset(-9000, 0);
                  pointFinal = Offset(-9000, 0);
                  sizeCircle = 0;
                  squares.clear();
                  circles.clear();
                  indicators.clear();
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
                      Stack(
                        children: [
                          ...multiwidget.asMap().entries.map((f) {
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
                                            offsets[f.key].dx +
                                                details.delta.dx,
                                            offsets[f.key].dy +
                                                details.delta.dy);
                                      });
                                    },
                                    value: f.value.toString(),
                                    fontsize: fontsize[f.key].toDouble(),
                                    align: TextAlign.center,
                                  )
                                : Container();
                          }).toList(),
                          Positioned(
                            left: -9000,
                            child: Text(squares.toString()),
                          ),
                          // Text(circles.toString()),
                          circleStack,
                          squareStack,
                          indicatorStack,
                          Signat(),
                          drawSelector(),
                        ],
                      ),
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
                    TextBottomBarContainer(type: type, offsets: offsets),
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
                        drawState = PickerStateConstant.arrow;
                      },
                      title: 'Indicador',
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          switch (componentState) {
                            case PickerStateConstant.square:
                              componentState = PickerStateConstant.circle;
                              component = CircleBottomBar(
                                  bottomBarColor: widget.bottomBarColor);
                              setState(() {
                                drawState = PickerStateConstant.circle;
                              });
                              break;

                            case PickerStateConstant.circle:
                              componentState = PickerStateConstant.square;
                              component = SquareBottomBarContainer(
                                  bottomBarColor: widget.bottomBarColor);
                              setState(() {
                                drawState = PickerStateConstant.square;
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
          drawState = PickerStateConstant.brush;
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Escolha uma cor!'),
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
                  child: const Text('Entendi'),
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
      case PickerStateConstant.brush:
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
      case PickerStateConstant.square:
        return GestureDetector(
          onPanDown: (DragDownDetails details) {
            print(details.localPosition);
            setState(() {
              globalSquareA = details.localPosition;
            });
          },
          onPanUpdate: (DragUpdateDetails details) {
            print(details.localPosition);
            setState(() {
              globalSquareB = details.localPosition;
            });
            squareStack = CustomPaint(
              painter: SquarePainter(),
              child: Container(),
            );
          },
          onPanEnd: (details) {
            squares.add(OffsetSquare(globalSquareA, globalSquareB));
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
      case PickerStateConstant.circle:
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
              globalCircleCenter = details.localPosition;
              sizeCircle = sqrt(
                      pow((globalCircleCenter.dy - radiusCenter.dy), 2) +
                          pow((globalCircleCenter.dx - radiusCenter.dx), 2))
                  .toInt();
            });
            circleStack = CustomPaint(
              painter: CirclePainter(),
              child: Container(),
            );
          },
          onPanEnd: (details) {
            circles.add(OffsetCircle(
                radiusCenter: radiusCenter, sizeCircle: sizeCircle));
            setState(() {
              circleStack = CustomPaint(
                painter: CirclePainter(),
                child: Container(),
              );
            });
          },
          child: CustomPaint(
            painter: CirclePainter(),
            child: Container(),
          ),
        );
        break;
      case PickerStateConstant.arrow:
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
            indicatorStack = CustomPaint(
              painter: IndicatorPainter(),
              child: Container(),
            );
          },
          onPanEnd: (details) {
            indicators.add(OffsetIndicator(
              pointFinal: pointFinal,
              pointInitial: pointInitial,
            ));
            setState(() {
              indicatorStack = CustomPaint(
                painter: IndicatorPainter(),
                child: Container(),
              );
            });
          },
          child: CustomPaint(
            painter: IndicatorPainter(),
            child: Container(),
          ),
        );
        break;
    }
    return Container();
  }
}

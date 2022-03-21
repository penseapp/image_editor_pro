library image_editor_pro;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:arrow_path/arrow_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_editor_pro/constants/picker_state_constant.dart';
import 'package:image_editor_pro/modules/bottombar_container.dart';
import 'package:image_editor_pro/modules/colors_picker.dart';
import 'package:image_editor_pro/modules/textview.dart';
import 'package:image_editor_pro/theme/colors.dart';
import 'package:image_editor_pro/utils/offset_class.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:signature/signature.dart';

part 'painters/circle_painter.dart';
part 'painters/indicator_painter.dart';
part 'painters/square_painter.dart';
part 'widgets/bottom_navigation_bar/circle_bottom_bar_container.dart';
part 'widgets/bottom_navigation_bar/square_bottom_bar_container.dart';
part 'widgets/bottom_navigation_bar/text_bottom_bar_container.dart';
part 'widgets/color_pickers_slider.dart';
part 'widgets/signat.dart';
part 'widgets/sliders.dart';

TextEditingController heightcontroler = TextEditingController();
TextEditingController widthcontroler = TextEditingController();
double width = 920;
double height = 1080;

Offset globalSquareA;
Offset globalSquareB;
Offset globalCircleCenter;
Offset radiusCenter;
Offset pointInitial;
Offset pointFinal;
int sizeCircle = 0;
String selectedButton;
Color selectedColor = CustomColors.riskExtremely3;
double selectedSize = 5;
bool isLoadingImage = false;
bool showLoadingProgress = true;

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
int howmuchwidgets = 0;
List multiwidget = [];
Color currentcolors = Colors.white;
double opacity = 0.0;
SignatureController _controller =
    SignatureController(penStrokeWidth: 5, penColor: selectedColor);

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
    setState(() => selectedColor = color);
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
    howmuchwidgets = 0;
    componentState = PickerStateConstant.square;
    component = SquareBottomBarContainer(bottomBarColor: widget.bottomBarColor);
    selectedButton = PickerStateConstant.brush;
    _resetSquares();
    _resetIndicators();
    _resetCircles();
    squares.clear();
    circles.clear();
    indicators.clear();
    selectedColor = Colors.black;
    selectedSize = 5;
    drawState = PickerStateConstant.brush;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: isLoadingImage ? null : bottomsheets,
          backgroundColor: isLoadingImage ? Colors.grey : CustomColors.primary,
          child: const Icon(Icons.camera_alt),
        ),
        backgroundColor: Colors.grey,
        key: scaf,
        appBar: AppBar(
          leadingWidth: MediaQuery.of(context).size.width * 0.5,
          leading: !isLoadingImage
              ? TextButton(
                  onPressed: isLoadingImage ? null : _clearAll,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                      Text(
                        'Excluir desenhos',
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                  // icon: Icon(Icons.delete_outline),
                  // label: Text("Excluir desenhos")
                )
              : SizedBox(),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.undo_rounded),
              onPressed: isLoadingImage ? null : _revertLastAction,
            ),
            if (!isLoadingImage)
              FlatButton.icon(
                  color: Colors.transparent,
                  textColor: Colors.white,
                  onPressed: captureImg,
                  icon: Icon(Icons.save),
                  label: Text('Salvar'))
            else
              Row(
                children: [
                  SizedBox(width: 10),
                  SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Salvando...'),
                  SizedBox(width: 10),
                ],
              )
          ],
          backgroundColor: CustomColors.primary,
        ),
        body: IgnorePointer(
          ignoring: isLoadingImage,
          child: Stack(
            children: [
              Stack(
                children: [
                  Screenshot(
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
                                Positioned(
                                    left: -300,
                                    child: Column(
                                      children: [
                                        Text(squares.length.toString()),
                                        Text(circles.length.toString()),
                                        Text(indicators.length.toString()),
                                        Text(_controller.points.length
                                            .toString()),
                                        Text(multiwidget.length.toString()),
                                      ],
                                    )),
                                circleStack,
                                squareStack,
                                indicatorStack,
                                Signat(),
                                drawSelector(),
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
                                                sizevalue:
                                                    fontsize[f.key].toDouble(),
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
                              ],
                            ),
                            Center(
                              child: Visibility(
                                visible: isLoadingImage && showLoadingProgress,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              /*Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, right: 50),
                  child: SizedBox(
                    width: 300,
                    height: 50,
                    child: Slider(
                      value: selectedSize.toDouble(),
                      min: 5,
                      max: 36,
                      divisions: 36,
                      label: '$selectedSize',
                      onChanged: (double newValue) {
                        setState(() {
                          selectedSize = newValue.round().toDouble();
                        });
                      },
                    ),
                  ),
                ),
              ),*/
              Visibility(
                visible: !isLoadingImage &&
                    selectedButton != PickerStateConstant.brush,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: 20,
                      children: [
                        Stack(
                          children: [
                            if (selectedColor == CustomColors.riskExtremely3)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.circle_outlined,
                                  size: 32,
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.circle,
                                color: CustomColors.riskExtremely3,
                                size:
                                    selectedColor == CustomColors.riskExtremely3
                                        ? 20
                                        : 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedColor = CustomColors.riskExtremely3;
                                });
                              },
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            if (selectedColor == CustomColors.riskHigh3)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.circle_outlined,
                                  size: 32,
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.circle,
                                color: CustomColors.riskHigh3,
                                size: selectedColor == CustomColors.riskHigh3
                                    ? 20
                                    : 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedColor = CustomColors.riskHigh3;
                                });
                              },
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            if (selectedColor == CustomColors.riskLow3)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.circle_outlined,
                                  size: 32,
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.circle,
                                color: CustomColors.riskLow3,
                                size: selectedColor == CustomColors.riskLow3
                                    ? 20
                                    : 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedColor = CustomColors.riskLow3;
                                });
                              },
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            if (selectedColor == CustomColors.riskMedium3)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.circle_outlined,
                                  size: 32,
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.circle,
                                color: CustomColors.riskMedium3,
                                size: selectedColor == CustomColors.riskMedium3
                                    ? 20
                                    : 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedColor = CustomColors.riskMedium3;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                      icons: Icons.arrow_upward,
                      isSelected:
                          selectedButton == PickerStateConstant.indicator,
                      ontap: () {
                        selectedButton = PickerStateConstant.indicator;
                        drawState = PickerStateConstant.indicator;
                      },
                      title: 'Indicador',
                    ),
                    BottomBarContainer(
                      icons: Icons.crop_square_rounded,
                      isSelected: selectedButton == PickerStateConstant.square,
                      ontap: () {
                        selectedButton = PickerStateConstant.square;
                        drawState = PickerStateConstant.square;
                      },
                      title: 'Quadrado',
                    ),
                    BottomBarContainer(
                      icons: Icons.circle_outlined,
                      isSelected: selectedButton == PickerStateConstant.circle,
                      ontap: () {
                        selectedButton = PickerStateConstant.circle;
                        drawState = PickerStateConstant.circle;
                      },
                      title: 'Círculo',
                    ),
                    TextBottomBarContainer(type: type, offsets: offsets),
                  ],
                ),
              ));
  }

  void _revertLastAction() {
    switch (selectedButton) {
      case PickerStateConstant.square:
        squares.removeLast();
        _resetSquares();
        break;

      case PickerStateConstant.indicator:
        indicators.removeLast();

        if (indicators.isNotEmpty) {
          final pfinal = indicators.last.pointFinal;
          final pinitial = indicators.last.pointInitial;

          pointInitial = Offset(pinitial.dx, pinitial.dy);
          pointFinal = Offset(pfinal.dx, pfinal.dy);
        } else {
          _resetIndicators();
        }
        break;

      case PickerStateConstant.circle:
        circles.removeLast();
        _resetCircles();
        break;

      case PickerStateConstant.brush:
        for (var i = 0; i < 10; i++) {
          _controller.points.removeLast();
        }
        break;

      case PickerStateConstant.text:
        multiwidget.removeLast();
        howmuchwidgets = multiwidget.length;
        break;

      default:
        setState(() {});
        break;
    }
  }

  void _clearAll() {
    _controller.clear();
    type.clear();
    fontsize.clear();
    offsets.clear();
    multiwidget.clear();
    howmuchwidgets = 0;
    _resetSquares();
    _resetCircles();
    _resetIndicators();
    squares.clear();
    circles.clear();
    indicators.clear();
    setState(() {});
  }

  void _resetIndicators() {
    pointInitial = Offset(-9000, 0);
    pointFinal = Offset(-9000, 0);
  }

  void _resetCircles() {
    globalCircleCenter = Offset(-9000, 0);
    radiusCenter = Offset(-9000, 0);
    sizeCircle = 0;
  }

  void _resetSquares() {
    globalSquareA = Offset(-9000, 0);
    globalSquareB = Offset(-9000, 0);
  }

  Widget brush() {
    return BottomBarContainer(
      colors: !isLoadingImage ? Colors.grey : widget.bottomBarColor,
      icons: Icons.brush,
      isSelected: selectedButton == PickerStateConstant.brush,
      ontap: isLoadingImage
          ? null
          : () {
              setState(() {
                selectedButton = PickerStateConstant.brush;
                drawState = PickerStateConstant.brush;
              });
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
                                    isLoadingImage = true;
                                    Navigator.pop(context);
                                    var image = await picker.getImage(
                                        source: ImageSource.gallery);

                                    var decodedImage =
                                        await decodeImageFromList(
                                            File(image.path).readAsBytesSync());

                                    setState(() {
                                      height = decodedImage.height.toDouble();
                                      width = decodedImage.width.toDouble();
                                      _image = File(image.path);
                                    });
                                    setState(() => _controller.clear());
                                    await Future.delayed(Duration(seconds: 1),
                                        () {
                                      isLoadingImage = false;
                                      setState(() {});
                                    });
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
                                  isLoadingImage = true;
                                  Navigator.pop(context);
                                  var image = await picker.getImage(
                                      source: ImageSource.camera);

                                  var decodedImage = await decodeImageFromList(
                                      File(image.path).readAsBytesSync());

                                  setState(() {
                                    height = decodedImage.height.toDouble();
                                    width = decodedImage.width.toDouble();
                                    _image = File(image.path);
                                  });
                                  setState(() => _controller.clear());
                                  await Future.delayed(Duration(seconds: 1),
                                      () {
                                    isLoadingImage = false;
                                    setState(() {});
                                  });
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
    // isLoadingImage = false;
    setState(() {});
  }

  void captureImg() {
    setState(() {
      isLoadingImage = true;
      showLoadingProgress = false;
    });

    // Future await 10 seconds
    Future.delayed(Duration(seconds: 10), () {
      screenshotController
          .capture(delay: Duration(milliseconds: 500), pixelRatio: 1.5)
          .then((File image) async {
        //print("Capture Done");

        final paths = await getExternalStorageDirectory();
        await image.copy(paths.path +
            '/' +
            DateTime.now().millisecondsSinceEpoch.toString() +
            '.png');

        setState(() {
          isLoadingImage = false;
          showLoadingProgress = true;
        });

        Navigator.pop(context, image);
      }).catchError((onError) {
        print(onError);
        setState(() {
          isLoadingImage = false;
          showLoadingProgress = true;
        });
      }).whenComplete(() {
        setState(() {
          isLoadingImage = false;
          showLoadingProgress = true;
        });
      });
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
            squares.add(OffsetSquare(
                globalSquareA, globalSquareB, selectedColor, selectedSize));
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
                radiusCenter: radiusCenter,
                sizeCircle: sizeCircle,
                color: selectedColor,
                size: selectedSize));
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
      case PickerStateConstant.indicator:
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
                color: selectedColor,
                size: selectedSize));
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

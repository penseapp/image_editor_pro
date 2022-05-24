library image_editor_pro;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:arrow_path/arrow_path.dart';
import 'package:crop_image/crop_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_editor_pro/constants/picker_state_constant.dart';
import 'package:image_editor_pro/modules/bottombar_container.dart';
import 'package:image_editor_pro/modules/colors_picker.dart';
import 'package:image_editor_pro/modules/textview.dart';
import 'package:image_editor_pro/theme/colors.dart';
import 'package:image_editor_pro/utils/offset_class.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
// import 'package:image_picker_web/image_picker_web.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

double imgWidth = 920;
double imgHeight = 1080;
double imgX = 0;
double imgY = 0;
double imgRatio = 1;

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
SignatureController _controller = SignatureController(penStrokeWidth: 5, penColor: selectedColor);

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
    _controller = SignatureController(penStrokeWidth: 5, penColor: color, points: points);
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
  Image _imageWeb;
  Image _croppedImage;
  Uint8List _imageBytes;
  String _imageBase64;
  ScreenshotController screenshotController = ScreenshotController();
  Timer timeprediction;
  bool hasAllPermissions = false;

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

  Future<bool> checkAllPermissions() async {
    // Check if has permission to access mediaLibrary
    // if (await Permission.mediaLibrary.status != PermissionStatus.granted) {
    //   await Permission.mediaLibrary.request();
    // }

    if (await Permission.storage.status != PermissionStatus.granted) {
      await Permission.storage.request();
    }

    return await Permission.storage.status == PermissionStatus.granted;

    // if (await Permission.accessMediaLocation.status !=
    //     PermissionStatus.granted) {
    //   await Permission.accessMediaLocation.request();
    // }

    // if (await Permission.camera.status != PermissionStatus.granted) {
    //   await Permission.camera.request();
    // }
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

    if (kIsWeb) {
      hasAllPermissions = true;
      return;
    } else {
      checkAllPermissions().then((value) {
        setState(() {
          hasAllPermissions = true;
        });
      });
    }
  }

  void setPermission() async {
    if (kIsWeb) {
      hasAllPermissions = true;
      return;
    }

    if (await checkAllPermissions()) {
      setState(() {
        hasAllPermissions = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    if (!hasAllPermissions) {
      return Scaffold(
        appBar: AppBar(
          // back button navigator.pop
          title: const Text('Câmera'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            tooltip: 'Voltar',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Wrap(
            // vertical
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 20,
            spacing: 20,
            children: [
              Icon(
                Icons.close,
                color: Colors.red,
                size: 120,
              ),
              Text(
                'Sem permissão',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),
              Text('Você precisa habilitar as permissões para usar a câmera',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  )),
              ElevatedButton(
                child: Text("Habilitar permissão"),
                onPressed: setPermission,
              )
            ],
          ),
        ),
      );
    }

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
            // IconButton(
            //   icon: Icon(
            //     Icons.settings_overscan_rounded,
            //     color: selectedButton == PickerStateConstant.dragAndDrop ? Colors.amber : Colors.white,
            //   ),
            //   onPressed: isLoadingImage
            //       ? null
            //       : () {
            //           setState(() {
            //             selectedButton = PickerStateConstant.dragAndDrop;
            //             drawState = PickerStateConstant.dragAndDrop;
            //           });
            //         },
            // ),
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
                  Center(
                    child: Screenshot(
                      controller: screenshotController,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          debugPrint('Tapped');
                        },
                        onPanUpdate: (details) {
                          debugPrint('onPanUpdate');
                          setState(() {
                            imgX += details.delta.dx / 2;
                            imgY += details.delta.dy / 2;
                          });
                        },
                        child: Container(
                          color: Colors.white,
                          width: 500,
                          height: 500,
                          // margin: EdgeInsets.only(
                          //   left: MediaQuery.of(context).size.width / 2 - (500 / 2),
                          //   top: MediaQuery.of(context).size.height * 0.1,
                          //   bottom: MediaQuery.of(context).size.height * 0.1,
                          // ),
                          child: RepaintBoundary(
                            key: globalKey,
                            child: Stack(
                              children: <Widget>[
                                // Text('selectedSize: ' + selectedSize.toString()),
                                // Text(_imageBase64 ?? 'No _imageBase64'),
                                // if (_imageBase64 != null) Image.memory(base64.decode(_imageBase64)),
                                if (_croppedImage != null) _croppedImage,
                                if (_imageBytes != null && _croppedImage == null)
                                  Container(
                                    width: 500,
                                    height: 500,
                                    transform: Matrix4.translationValues(imgX, imgY, 0),
                                    child: Image.memory(
                                      _imageBytes,
                                      fit: BoxFit.scaleDown,
                                      alignment: FractionalOffset.topCenter,
                                    ),
                                  ),
                                // if (_image != null && _croppedImage == null)
                                //   Container(
                                //     width: MediaQuery.of(context).size.width,
                                //     height: MediaQuery.of(context).size.height,
                                //     transform: Matrix4.translationValues(imgX, imgY, 0),
                                //     child: Image.file(
                                //       _image,
                                //       fit: BoxFit.scaleDown,
                                //       alignment: FractionalOffset.topCenter,
                                //     ),
                                //   )
                                // else
                                //   Container(
                                //     width: 500,
                                //     height: 500,
                                //   ),
                                Stack(
                                  children: [
                                    Positioned(
                                        left: -300,
                                        child: Column(
                                          children: [
                                            Text(squares.length.toString()),
                                            Text(circles.length.toString()),
                                            Text(indicators.length.toString()),
                                            Text(_controller.points.length.toString()),
                                            Text(multiwidget.length.toString()),
                                          ],
                                        )),
                                    circleStack,
                                    squareStack,
                                    indicatorStack,
                                    if (selectedButton == PickerStateConstant.brush) Signat(),
                                    drawSelector(),
                                    ...multiwidget.asMap().entries.map((f) {
                                      return type[f.key] == 2
                                          ? TextView(
                                              left: offsets[f.key].dx,
                                              top: offsets[f.key].dy,
                                              ontap: () {
                                                scaf.currentState.showBottomSheet((context) {
                                                  return Sliders(
                                                    size: f.key,
                                                    sizevalue: fontsize[f.key].toDouble(),
                                                  );
                                                });
                                              },
                                              onpanupdate: (details) {
                                                setState(() {
                                                  offsets[f.key] = Offset(offsets[f.key].dx + details.delta.dx,
                                                      offsets[f.key].dy + details.delta.dy);
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
                      ),
                    ),
                  )
                ],
              ),
              Visibility(
                visible: !isLoadingImage && selectedButton != PickerStateConstant.brush,
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
                                size: selectedColor == CustomColors.riskExtremely3 ? 20 : 24,
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
                                size: selectedColor == CustomColors.riskHigh3 ? 20 : 24,
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
                                size: selectedColor == CustomColors.riskLow3 ? 20 : 24,
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
                                size: selectedColor == CustomColors.riskMedium3 ? 20 : 24,
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
                decoration: BoxDecoration(color: widget.bottomBarColor, boxShadow: [BoxShadow(blurRadius: 10.9)]),
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    brush(),
                    BottomBarContainer(
                      icons: Icons.arrow_upward,
                      isSelected: selectedButton == PickerStateConstant.indicator,
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

  Future<void> _showMyDialog() async {
    final cropController = CropController(
      aspectRatio: 1,
      defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cortar imagem'),
          content: CropImage(
            minimumImageSize: 500,
            controller: cropController,
            image: Image.memory(_imageBytes),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cortar'),
              onPressed: () async {
                final croppedImage = await cropController.croppedImage();
                setState(() {
                  _croppedImage = croppedImage;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void bottomsheets() {
    openbottomsheet = true;
    setState(() {});
    var future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration:
              BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 10.9, color: Colors.grey[400])]),
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

                                    if (kIsWeb) {
                                      // final fromPicker = await ImagePickerWeb.getImageAsWidget();
                                      final bytes = await ImagePickerWeb.getImageAsBytes();

                                      if (bytes != null) {
                                        setState(() {
                                          isLoadingImage = false;
                                          _imageBytes = bytes;
                                        });
                                      }
                                      await _showMyDialog();
                                    } else {
                                      try {
                                        var image = await picker.getImage(source: ImageSource.gallery);

                                        if (image?.path != null) {
                                          final _bytesImg = File(image.path).readAsBytesSync();
                                          // var decodedImage = await decodeImageFromList(_bytesImg);

                                          setState(() {
                                            // height = decodedImage.height.toDouble();
                                            // width = decodedImage.width.toDouble();
                                            // _image = File(image.path);
                                            _imageBytes = _bytesImg;
                                          });

                                          await _showMyDialog();
                                        }
                                      } catch (e) {
                                        print('error: $e');
                                      }
                                    }

                                    setState(() => _controller.clear());
                                    await Future.delayed(Duration(seconds: 1), () {
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
                                onPressed: kIsWeb
                                    ? null
                                    : () async {
                                        isLoadingImage = true;
                                        Navigator.pop(context);
                                        var image = await picker.getImage(source: ImageSource.camera);

                                        if (image == null) {
                                          isLoadingImage = false;
                                          setState(() {});
                                        } else {
                                          final _imgBytes = File(image.path).readAsBytesSync();
                                          var decodedImage =
                                              await decodeImageFromList(File(image.path).readAsBytesSync());

                                          setState(() {
                                            height = decodedImage.height.toDouble();
                                            width = decodedImage.width.toDouble();
                                            // _image = File(image.path);
                                            _imageBytes = _imgBytes;
                                          });
                                          setState(() => _controller.clear());
                                          await Future.delayed(Duration(seconds: 1), () {
                                            isLoadingImage = false;
                                            setState(() {});
                                          });

                                          await _showMyDialog();
                                        }
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

    if (kIsWeb) {
      try {
        screenshotController.captureAsUiImage().then((image) async {
          // convert Image to base64
          final imagebytes = await image.toByteData(format: ImageByteFormat.png);
          final base64 = base64Encode(imagebytes.buffer.asUint8List());

          setState(() {
            _imageBase64 = base64;
            isLoadingImage = false;
            showLoadingProgress = true;
          });

          Navigator.pop(context, base64);
          return;
        });
      } catch (e) {
        setState(() {
          isLoadingImage = false;
          showLoadingProgress = true;
        });
      }
    }

    screenshotController.capture(delay: Duration(milliseconds: 500), pixelRatio: 1.5).then((File image) async {
      //print("Capture Done");

      final paths = await getExternalStorageDirectory();
      final _path = paths.path + '/' + DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';

      if (image != null && image.path != null) {
        final decodedImage = await decodeImageFromList(image.readAsBytesSync());
        final scale = calcScale(
          srcWidth: decodedImage.width.toDouble(),
          srcHeight: decodedImage.height.toDouble(),
          minWidth: 500,
          minHeight: 892,
        );

        final result = await FlutterImageCompress.compressAndGetFile(
          image.path,
          _path,
          quality: 88,
          format: CompressFormat.jpeg,
          minWidth: decodedImage.width ~/ scale,
          minHeight: decodedImage.height ~/ scale,
        );

        if (await checkAllPermissions()) {
          await GallerySaver.saveImage(result.path);
        }

        await image.copy(result.path);
      }

      // convert File to Image
      final decodedImage = await decodeImageFromList(File(_path).readAsBytesSync());
      // Convert image to String base64
      final imagebytes = await decodedImage.toByteData(format: ImageByteFormat.png);
      // Convert ByteData to base64 string
      final base64 = base64Encode(imagebytes.buffer.asUint8List());

      Navigator.pop(context, base64);
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
  }

  Widget drawSelector() {
    if (drawState == PickerStateConstant.dragAndDrop) return Container();

    switch (drawState) {
      case PickerStateConstant.dragAndDrop:
        return Container();
      case PickerStateConstant.brush:
        return GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                RenderBox object = context.findRenderObject();
                var _localPosition = object.globalToLocal(details.globalPosition);
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
            squares.add(OffsetSquare(globalSquareA, globalSquareB, selectedColor, selectedSize));
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
              sizeCircle = sqrt(pow((globalCircleCenter.dy - radiusCenter.dy), 2) +
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
                radiusCenter: radiusCenter, sizeCircle: sizeCircle, color: selectedColor, size: selectedSize));
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
          onLongPress: () => setState(() {
            drawState = PickerStateConstant.dragAndDrop;
          }),
          onLongPressEnd: (details) => setState(() {
            drawState = PickerStateConstant.dragAndDrop;
          }),
          onLongPressMoveUpdate: (details) => setState(() {
            drawState = PickerStateConstant.dragAndDrop;
          }),
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
                pointFinal: pointFinal, pointInitial: pointInitial, color: selectedColor, size: selectedSize));
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

double calcScale({
  double srcWidth,
  double srcHeight,
  double minWidth,
  double minHeight,
}) {
  var scaleW = srcWidth / minWidth;
  var scaleH = srcHeight / minHeight;

  var scale = max(1.0, min(scaleW, scaleH));

  return scale;
}

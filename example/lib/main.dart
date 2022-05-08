import 'dart:convert';
import 'dart:io';
import 'package:image_editor_pro/image_editor_pro.dart';
import 'package:firexcode/firexcode.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomePage().xMaterialApp();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _base64;
  dynamic tmpImgPath;
  dynamic _tmpImg;

  Future<void> getimageditor() => Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ImageEditorPro(
          appBarColor: Colors.blue,
          bottomBarColor: Colors.blue,
        );
      })).then((geteditimage) {
        debugPrint("geteditimage: $geteditimage");
        if (geteditimage != null) {
          setState(() {
            _base64 = geteditimage;
          });
        }
      }).catchError((er) {
        print(er);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Image Editor Pro'),
        ),
        body: Container(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.16,
            child: Column(
              children: [
                if (_base64 != null) Image.memory(base64.decode(_base64)),
                if (_base64 == null) Text('Image Not Loaded'),
                if (_base64 != null) Image.memory(base64.decode(_base64)),
                ElevatedButton(onPressed: getimageditor, child: Text('Load Image')),
              ],
            ),
          ),
        ));
  }
}

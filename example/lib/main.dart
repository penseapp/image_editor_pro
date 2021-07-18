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
  File _image;

  Future<void> getimageditor() =>
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ImageEditorPro(
          appBarColor: Colors.blue,
          bottomBarColor: Colors.blue,
        );
      })).then((geteditimage) {
        if (geteditimage != null) {
          setState(() {
            _image = geteditimage;
          });
        }
      }).catchError((er) {
        print(er);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: getimageditor,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

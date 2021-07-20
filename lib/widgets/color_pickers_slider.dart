part of image_editor_pro;

class ColorPickersSlider extends StatefulWidget {
  @override
  _ColorPickersSliderState createState() => _ColorPickersSliderState();
}

class _ColorPickersSliderState extends State<ColorPickersSlider> {
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

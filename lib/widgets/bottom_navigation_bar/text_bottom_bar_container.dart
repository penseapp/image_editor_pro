part of image_editor_pro;

class TextBottomBarContainer extends StatelessWidget {
  const TextBottomBarContainer({
    Key key,
    @required this.type,
    @required this.offsets,
  }) : super(key: key);

  final List type;
  final List<Offset> offsets;

  @override
  Widget build(BuildContext context) {
    return BottomBarContainer(
      icons: Icons.text_fields,
      isSelected: selectedButton == PickerStateConstant.text,
      ontap: () async {
        String value;
        selectedButton = PickerStateConstant.text;

        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: TextField(
                  decoration: InputDecoration(labelText: "Adicione um texto"),
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
                      howmuchwidgets++;
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
    );
  }
}

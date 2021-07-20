part of image_editor_pro;

class CircleBottomBar extends StatelessWidget {
  final bottomBarColor;

  const CircleBottomBar({
    Key key,
    @required this.bottomBarColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomBarContainer(
      colors: bottomBarColor,
      icons: Icons.circle,
      title: 'Círculo',
    );
  }
}

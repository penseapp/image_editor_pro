part of image_editor_pro;

class SquareBottomBarContainer extends StatelessWidget {
  final bottomBarColor;

  const SquareBottomBarContainer({
    Key key,
    @required this.bottomBarColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomBarContainer(
      colors: bottomBarColor,
      icons: Icons.crop_square,
      title: 'Quadrado',
    );
  }
}

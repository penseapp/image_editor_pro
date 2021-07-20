import 'package:flutter/material.dart';
import 'package:image_editor_pro/theme/colors.dart';

class BottomBarContainer extends StatelessWidget {
  final Color colors;
  final Function ontap;
  final String title;
  final IconData icons;
  final bool isSelected;

  const BottomBarContainer(
      {Key key,
      this.ontap,
      this.title,
      this.icons,
      this.colors,
      this.isSelected = false})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 5,
      color: colors,
      child: Material(
        color: isSelected ? CustomColors.primary : CustomColors.primary,
        child: InkWell(
          onTap: ontap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                icons,
                color: isSelected ? CustomColors.mostard : Colors.white,
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                title,
                style: TextStyle(
                    color: isSelected ? CustomColors.mostard : Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}

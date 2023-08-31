import 'package:flutter/material.dart';

class LeftRightSwitch extends StatelessWidget {
  final Color iconsColor;
  final double iconsSize;
  final Widget middleWidget;
  final VoidCallback? onLeftClicked;
  final VoidCallback? onRightClicked;

  const LeftRightSwitch({
    Key? key,
    required this.iconsColor,
    required this.iconsSize,
    required this.middleWidget,
    this.onLeftClicked,
    this.onRightClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            shadows: const [
              Shadow(color: Colors.black, offset: Offset(0, 6), blurRadius: 4)
            ],
            color: iconsColor,
          ),
          iconSize: iconsSize,
          onPressed: onLeftClicked ?? ()=>{},
        ),
        middleWidget,
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            shadows: const [
              Shadow(color: Colors.black, offset: Offset(0, 6), blurRadius: 4)
            ],
            color: iconsColor,
          ),
          iconSize: iconsSize,
          onPressed: onRightClicked ?? ()=>{},
        )
      ],
    );
  }
}

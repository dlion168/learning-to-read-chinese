import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/widgets/word_card.dart';

import '../mainPage/left_right_switch.dart';
import 'card_title.dart';

class TeachWordTabBarView extends StatelessWidget {
  final Widget content;
  final String sectionName;
  const TeachWordTabBarView({
    Key? key,
    required this.sectionName,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(
            color: '#28231D'.toColor(),
            border: Border.all(color: '#999999'.toColor(), width: 6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              LeftRightSwitch(
                iconsColor: '#D9D9D9'.toColor(),
                iconsSize: 35,
                middleWidget: TeachWordCardTitle(
                    sectionName: sectionName, iconsColor: '#D9D9D9'.toColor()),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(child: content),
            ],
          ),
        ),
      ),
      const SizedBox(
        height: 45,
      ),
      LeftRightSwitch(
        iconsColor: '#F5F5DC'.toColor(),
        iconsSize: 48,
        middleWidget: const WordCard(
          word: '手',
          sizedBoxWidth: 67,
          sizedBoxHeight: 88,
          fontSize: 23,
        ),
      ),
    ]);
  }
}

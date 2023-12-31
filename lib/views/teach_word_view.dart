// ignore_for_file: unused_local_variable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider, Consumer;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/bpmf_vocab_content.dart';
import 'package:ltrc/widgets/teach_word/card_title.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animator.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:ltrc/widgets/teach_word/word_vocab_content.dart';
import 'package:ltrc/widgets/word_card.dart';
import 'package:provider/provider.dart';

class TeachWordView extends ConsumerStatefulWidget {
  final int unitId;
  final String unitTitle;
  final List<WordStatus> wordsStatus;
  final List<Map> wordsPhrase;
  final int wordIndex;

  const TeachWordView({
    super.key,
    required this.unitId,
    required this.unitTitle,
    required this.wordsStatus,
    required this.wordsPhrase,
    required this.wordIndex,
  });

  @override
  TeachWordViewState createState() => TeachWordViewState();
}

class TeachWordViewState extends ConsumerState<TeachWordView>
    with TickerProviderStateMixin {
  late StrokeOrderAnimationController _strokeOrderAnimationControllers;
  late TabController _tabController;
  FlutterTts ftts = FlutterTts();
  late Map wordsPhrase;
  late Map wordObj;
  int vocabCnt = 0;
  bool img1Exist = false;
  bool img2Exist = false;
  int practiceTimeLeft = 4;
  int nextStepId = 0;
  bool isBpmf = false;
  ValueNotifier<int> currentTabIndex = ValueNotifier(0);
  void nextTab() async {
    currentTabIndex.value++;
    bool wordIsLearned = widget.wordsStatus[widget.wordIndex].learned;
    if(!wordIsLearned) {
      debugPrint(nextStepId.toString());
      if (nextStepId == steps['goToSection2']) {
        setState(() {
          nextStepId += 1;
        }); 
        // todo
      }
      else if (nextStepId == steps['goToSection3']) {
        setState(() {
          nextStepId += 1;
        }); 
        // todo
      }
      else if (nextStepId == steps['goToSection4']) {
        // todo
        var result = await ftts.speak(
          "${wordObj['vocab1']}。${wordObj['sentence1']}");
      }
    }
  }

  Future<String> readJson() async {
    final String response =
        await rootBundle.loadString('lib/assets/svg/${widget.wordsStatus[widget.wordIndex].word}.json');

    return response.replaceAll("\"", "'");
  }

  Future myLoadAsset(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (_) {
      return null;
    }
  }

  void getWord() async {
    setState(() {
      wordObj = widget.wordsPhrase[widget.wordIndex];
    });
    if (wordObj['vocab1'] != "") {
      vocabCnt += 1;
      var imgAsset = await myLoadAsset(
          'lib/assets/img/vocabulary/${wordObj['vocab1']}.webp');
      if (imgAsset == null) {
        img1Exist = false;
      } else {
        img1Exist = true;
      }
    }
    if (wordObj['vocab2'] != "") {
      vocabCnt += 1;
      var imgAsset = await myLoadAsset(
          'lib/assets/img/vocabulary/${wordObj['vocab2']}.webp');
      if (imgAsset == null) {
        img2Exist = false;
      } else {
        img2Exist = true;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    ftts.setLanguage("zh-tw");
    ftts.setSpeechRate(0.5);
    ftts.setVolume(1.0);
    ftts.setCompletionHandler(() async {
      debugPrint(nextStepId.toString());
      bool wordIsLearned = widget.wordsStatus[widget.wordIndex].learned;
      if(!wordIsLearned) {
        if (nextStepId == steps['goToSection2']) {
          setState(() {
            nextStepId += 1;
          }); 
        }
        else if (nextStepId == steps['goToSection4']) {
          debugPrint(vocabCnt.toString());
          if (vocabCnt == 1) {
            WordStatus newStatus = widget.wordsStatus[widget.wordIndex];
            setState(() {
              newStatus.learned = true;
            });
            setState(() {
              nextStepId = 100;
            });
            ref.read(learnedWordCountProvider.notifier).state += 1 ;
            await WordStatusProvider.updateWordStatus(
              status: newStatus
            );
          }
          else {
            setState(() {
              nextStepId += 1;
            }); 
          }
        }
        else if (nextStepId == steps['goToPhrase2']) {
          WordStatus newStatus = widget.wordsStatus[widget.wordIndex];
          setState(() {
            newStatus.learned = true;
          });
          setState(() {
            nextStepId = 100;
          });
          ref.read(learnedWordCountProvider.notifier).state += 1 ;
          await WordStatusProvider.updateWordStatus(
            status: newStatus
          );
        }
      }
      debugPrint("Speech has completed");
    });
    if(widget.wordsStatus[widget.wordIndex].learned) nextStepId = 100;
    isBpmf = (initials.contains(widget.wordsStatus[widget.wordIndex].word) || prenuclear.contains(widget.wordsStatus[widget.wordIndex].word) || finals.contains(widget.wordsStatus[widget.wordIndex].word));
    getWord();
    _tabController = TabController(length: 4, vsync: this, animationDuration: Duration.zero);
    readJson().then((result) {
      setState(() {
        _strokeOrderAnimationControllers = StrokeOrderAnimationController(
          result,
          this,
          onQuizCompleteCallback: (summary) {
            if (nextStepId >= steps['practiceWithBorder1']! && nextStepId <= steps['turnBorderOff']!) {
              setState(() {
                practiceTimeLeft -= 1;
                nextStepId += 1;
              });
              Fluttertoast.showToast(
                msg: [
                  nextStepId == steps['turnBorderOff'] ? "恭喜筆畫正確！讓我們 去掉邊框 再練習 $practiceTimeLeft 遍哦！" : "恭喜筆畫正確！讓我們再練習 $practiceTimeLeft 次哦！"
                ].join(),
                fontSize: 30,
              );
            }
            else {
              if (nextStepId == steps['practiceWithoutBorder1']) {
                setState(() {
                  practiceTimeLeft -= 1;
                  nextStepId += 1;
                });
              }
              Fluttertoast.showToast(
                msg: [
                  "恭喜筆畫正確！"
                ].join(),
                fontSize: 30,
              );
            }
          },
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  int vocabIndex = 0;

  Map<String, int> steps = {
    'goToSection2': 0,
    'goToSection3': 1,
    'seeAnimation': 2,
    'practiceWithBorder1': 3,
    'practiceWithBorder2': 4,
    'practiceWithBorder3': 5,
    'turnBorderOff': 6,
    'practiceWithoutBorder1': 7,
    'goToSection4': 8,
    'goToPhrase2': 9,
  };

  @override
  Widget build(BuildContext context) {
    bool wordIsLearned = widget.wordsStatus[widget.wordIndex].learned;
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    String word = widget.wordsStatus[widget.wordIndex].word;
    int unitId = widget.unitId;
    String unitTitle = widget.unitTitle;
    List<Widget> useTabView = [
      TeachWordTabBarView(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            LeftRightSwitch(
              iconsColor: '#D9D9D9'.toColor(),
              iconsSize: 35,
              rightBorder: nextStepId == steps['goToPhrase2'],
              middleWidget: TeachWordCardTitle(
                sectionName: '用一用', iconsColor: '#D9D9D9'.toColor()),
              isFirst: false,
              isLast: (vocabCnt == 1),
              onLeftClicked: wordIsLearned ? () {
                currentTabIndex.value--;
                return _tabController.animateTo(_tabController.index - 1);
              } : null,
              onRightClicked: (nextStepId == steps['goToPhrase2'] || wordIsLearned) ? () async {
                setState(() {
                  vocabIndex = 1;
                });
                if (nextStepId == steps['goToPhrase2']) {
                  var result = await ftts.speak(
                    "${wordObj['vocab2']}。${wordObj['sentence2']}");
                }
              } : null,
            ),
            isBpmf ? 
              BopomofoVocabContent(
                word: word,
                vocab: wordObj['vocab1'],
                sentence: "${wordObj['sentence1']}",
              )
              :
              WordVocabContent(
                vocab: wordObj['vocab1'],
                meaning: wordObj['meaning1'],
                sentence: "${wordObj['sentence1']}\n",
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Wrap(
                  direction: Axis.vertical, 
                  spacing: 0,
                  children: <Widget>[
                    IconButton(
                      iconSize: 30,
                      color: const Color.fromRGBO(245, 245, 220, 100),
                      onPressed: () async {
                        var result = await ftts.speak(
                          "${wordObj['vocab1']}。${wordObj['sentence1']}");
                      },
                      icon: const Icon(Icons.volume_up)
                    ),
                    const Text('讀音',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        color: Color.fromRGBO(245, 245, 220, 100),
                      )),
                  ],
                ),
                (img1Exist && !isBpmf)
                  ? Image(
                    height: deviceHeight*0.15,
                    image: AssetImage(
                      'lib/assets/img/vocabulary/${wordObj['vocab1']}.webp'),
                  )
                  : Container(
                    height: deviceHeight*0.08
                  ),
                Text("1 / $vocabCnt",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(245, 245, 220, 100),
                )),
              ],
            ),
          ],
      )),
      (vocabCnt == 2)
        ? TeachWordTabBarView(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              LeftRightSwitch(
                iconsColor: '#D9D9D9'.toColor(),
                iconsSize: 35,
                rightBorder: false,
                middleWidget: TeachWordCardTitle(
                  sectionName: '用一用', iconsColor: '#D9D9D9'.toColor()),
                isFirst: false,
                isLast: true,
                onLeftClicked: wordIsLearned ? () {
                  setState(() {
                    vocabIndex = 0;
                  });
                }: null,
              ),
              isBpmf ? 
                BopomofoVocabContent(
                  word: word,
                  vocab: wordObj['vocab2'],
                  sentence: "${wordObj['sentence2']}",
                )
                :
                WordVocabContent(
                  vocab: wordObj['vocab2'],
                  meaning: wordObj['meaning2'],
                  sentence: "${wordObj['sentence2']}\n",
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Wrap(
                  direction: Axis.vertical, 
                  spacing: 0,
                  children: <Widget>[
                    IconButton(
                      iconSize: 30,
                      color: const Color.fromRGBO(245, 245, 220, 100),
                      onPressed: () async {
                        var result = await ftts.speak(
                          "${wordObj['vocab2']}。${wordObj['sentence2']}");
                      },
                    icon: const Icon(Icons.volume_up)),
                  const Text('讀音',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.5,
                      color: Color.fromRGBO(245, 245, 220, 100),
                    )),
                  ],
                ),
                  (img2Exist && !isBpmf)
                    ? Image(
                        height: 150,
                        image: AssetImage(
                        'lib/assets/img/vocabulary/${wordObj['vocab2']}.webp'),
                      )
                    : Container(
                        height: isBpmf ? 0 : 150,
                      ),
                  Text("2 / $vocabCnt",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(245, 245, 220, 100),
                  )),
                ],
              ),
            ],
          ))
        : Container()];
    
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.pop(context),
          ),
          title: (unitId == -1) ? Text(unitTitle) : Text("${unitId.toString().padLeft(2, '0')} | $unitTitle"),
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
              icon: const Icon(Icons.home_filled)),
          ],
          bottom: 
          TabBar(
            tabs: const [
              Tab(icon: Icon(Icons.image)),
              Tab(icon: Icon(Icons.hearing)),
              Tab(icon: Icon(Icons.create)),
              Tab(icon: Icon(Icons.school)),
            ],
            controller: _tabController,
            onTap: (index){
              _tabController.index = currentTabIndex.value;
            },
            labelColor: '#28231D'.toColor(),
            dividerColor: '#999999'.toColor(),
            unselectedLabelColor: '#999999'.toColor(),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: '#999999'.toColor(),
            ),
          ),
        ),
        body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
          children: [
            TeachWordTabBarView(
              content: Column(
                children: [
                  LeftRightSwitch(
                    iconsColor: '#D9D9D9'.toColor(),
                    iconsSize: 35,
                    rightBorder: nextStepId == steps['goToSection2'],
                    middleWidget: TeachWordCardTitle(
                      sectionName: '看一看', iconsColor: '#D9D9D9'.toColor()),
                    isFirst: true,
                    isLast: false,
                    onRightClicked: (nextStepId == steps['goToSection2']! || wordIsLearned) ? () async {
                      nextTab();
                      var result = await ftts.speak(word);
                      return _tabController.animateTo(_tabController.index + 1);
                    } : null,
                  ),
                  const SizedBox(height: 30,),
                  Image(
                    width: 300,
                    image: isBpmf ? 
                      AssetImage('lib/assets/img/bopomo/$word.png') : AssetImage('lib/assets/img/oldWords/$word.webp'),
                  ),
                ],
              )),
            TeachWordTabBarView(
              content: Column(
                children: [
                  LeftRightSwitch(
                    iconsColor: '#D9D9D9'.toColor(),
                    iconsSize: 35,
                    rightBorder: nextStepId == steps['goToSection3'],
                    middleWidget: TeachWordCardTitle(
                      sectionName: '聽一聽', iconsColor: '#D9D9D9'.toColor()),
                    isFirst: false,
                    isLast: false,
                    onLeftClicked: (wordIsLearned) ? () {
                      currentTabIndex.value--;
                      return _tabController.animateTo(_tabController.index - 1);
                    } : null,
                    onRightClicked: (nextStepId == steps['goToSection3'] || wordIsLearned) ? () {
                      nextTab();
                      return _tabController.animateTo(_tabController.index + 1);
                    } : null,
                  ),
                  const SizedBox(height: 20,),
                  Padding(
                    padding: isBpmf ? const EdgeInsets.fromLTRB(0, 0, 0, 0) : const EdgeInsets.fromLTRB(50, 0, 0, 0),
                    child: Container(
                      height: 250,
                      alignment: Alignment.center,
                      child: Text(word,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 150,
                          color: const Color.fromRGBO(245, 245, 220, 100),
                          fontWeight: FontWeight.w100,
                          fontFamily: isBpmf ? "BpmfOnly" : "Serif",
                        )),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 1),
                      child: Column(
                        children: [
                          IconButton(
                            iconSize: 35,
                            color: const Color.fromRGBO(245, 245, 220, 100),
                            onPressed: () async {
                              var result = await ftts.speak(word);
                            },
                            icon: const Icon(Icons.volume_up)),
                          const Text('讀音',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 17.5,
                              color: Color.fromRGBO(245, 245, 220, 100),
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
            TeachWordTabBarView(
              content: ChangeNotifierProvider<
                StrokeOrderAnimationController>.value(
                value: _strokeOrderAnimationControllers,
                child: Consumer<StrokeOrderAnimationController>(
                  builder: (context, controller, child) {
                    return Center(
                      child: SizedBox(
                        width: min(deviceWidth * 0.8, deviceHeight * 0.684 - 184),
                        child: Column(
                          children: <Widget>[
                            LeftRightSwitch(
                              iconsColor: '#D9D9D9'.toColor(),
                              iconsSize: 35,
                              rightBorder: nextStepId == steps['goToSection4'],
                              middleWidget: TeachWordCardTitle(
                                sectionName: '寫一寫', iconsColor: '#D9D9D9'.toColor()),
                              isFirst: false,
                              isLast: false,
                              onLeftClicked: wordIsLearned ? () {
                                currentTabIndex.value--;
                                return _tabController.animateTo(_tabController.index - 1);
                              } : null,
                              onRightClicked: (nextStepId == steps['goToSection4'] || wordIsLearned) ? () {
                                nextTab();
                                return _tabController.animateTo(_tabController.index + 1);
                              } : null,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              decoration: !isBpmf ? const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("lib/assets/img/box.png"),
                                  fit: BoxFit.fitWidth,
                                ),
                              ) : BoxDecoration(color: '#28231D'.toColor()),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    left: 10,
                                    top: 5,
                                    child: Column(
                                      children: [
                                        Icon(
                                          (practiceTimeLeft >= 4 && !wordIsLearned) ? Icons.check_circle_outline_outlined : Icons.check_circle,
                                          color: (practiceTimeLeft >= 4 && !wordIsLearned) ? '#999999'.toColor() : '#F8A339'.toColor(),
                                          size: 25.0,
                                        ),
                                        Icon(
                                          (practiceTimeLeft >= 3 && !wordIsLearned) ? Icons.check_circle_outline_outlined : Icons.check_circle,
                                          color: (practiceTimeLeft >= 3 && !wordIsLearned) ? '#999999'.toColor() : '#F8A339'.toColor(),
                                          size: 25.0,
                                        ),
                                        Icon(
                                          (practiceTimeLeft >= 2 && !wordIsLearned) ? Icons.check_circle_outline_outlined : Icons.check_circle,
                                          color: (practiceTimeLeft >= 2 && !wordIsLearned) ? '#999999'.toColor() : '#F8A339'.toColor(),
                                          size: 25.0,
                                        ),
                                        const SizedBox(height: 15,),
                                        Icon(
                                          (practiceTimeLeft >= 1 && !wordIsLearned) ? Icons.check_circle_outline_outlined : Icons.check_circle,
                                          color: (practiceTimeLeft >= 1 && !wordIsLearned) ? '#999999'.toColor() : '#F8A3A9'.toColor(),
                                          size: 25.0,
                                        ),
                                      ]
                                    ),
                                  ),
                                  FittedBox(
                                    child: StrokeOrderAnimator(
                                      _strokeOrderAnimationControllers,
                                      key: UniqueKey(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Flexible(
                              child: GridView(
                                gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 2.25,
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 6,
                                  ),
                                primary: false,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      border: nextStepId == steps['seeAnimation'] ? Border.all(color: '#FFFF93'.toColor(), width: 1.5) : null,
                                    ),
                                    child: IconButton(
                                      iconSize: 34,
                                      color: const Color.fromRGBO(245, 245, 220, 100),
                                      isSelected: controller.isAnimating,
                                      icon: const Icon(Icons.play_arrow),
                                      selectedIcon: const Icon(Icons.pause),
                                      onPressed: !controller.isQuizzing
                                        ? () async {
                                          if (!controller.isAnimating) {
                                            controller.startAnimation();
                                            var result = await ftts.speak(word);
                                            if (nextStepId == steps['seeAnimation']) {
                                              setState(() {
                                                nextStepId += 1;
                                              }); 
                                            }
                                          } else {
                                            controller.stopAnimation();
                                            debugPrint("stop animation // nextStepId update time");
                                          }
                                        }
                                      : null,
                                  )),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: (!controller.isQuizzing && (nextStepId == steps['practiceWithBorder1'] || nextStepId == steps['practiceWithBorder2'] || nextStepId == steps['practiceWithBorder3'] || nextStepId == steps['practiceWithoutBorder1'])) ? Border.all(color: '#FFFF93'.toColor(), width: 1.5) : null,
                                    ),
                                    child: IconButton(
                                      iconSize: 34,
                                      color: const Color.fromRGBO(245, 245, 220, 100),
                                      isSelected: controller.isQuizzing,
                                      icon: const Icon(Icons.edit),
                                      onPressed: (nextStepId == steps['practiceWithBorder1'] || nextStepId == steps['practiceWithBorder2'] || nextStepId == steps['practiceWithBorder3'] || nextStepId == steps['practiceWithoutBorder1'] || wordIsLearned) ? () async {
                                        controller.startQuiz();
                                        var result = await ftts.speak(word);
                                      } : null,
                                  )),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: (nextStepId == steps['turnBorderOff']) ? Border.all(color: '#FFFF93'.toColor(), width: 1.5) : null,
                                    ),
                                    child:IconButton(
                                      iconSize: 34,
                                      color: const Color.fromRGBO(245, 245, 220, 100),
                                      isSelected: controller.showOutline,
                                      icon: const Icon(
                                        Icons.remove_red_eye_outlined),
                                      selectedIcon:
                                        const Icon(Icons.remove_red_eye),
                                      onPressed: (nextStepId == steps['turnBorderOff'] || wordIsLearned) ? () {
                                        if (nextStepId == steps['turnBorderOff']) {
                                          setState(() {
                                            nextStepId += 1;
                                          }); 
                                        }
                                        controller.setShowOutline(!controller.showOutline);
                                      } : null,
                                  )),
                                const Text('筆順',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Color.fromRGBO(
                                        245, 245, 220, 100),
                                )),
                                const Text('寫字',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Color.fromRGBO(245, 245, 220, 100),
                                )),
                                const Text('邊框',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Color.fromRGBO(245, 245, 220, 100),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            useTabView[vocabIndex]
          ]),
        bottomNavigationBar: BottomAppBar(
          height: 100,
          elevation: 0,
          color: '#28231D'.toColor(),
          child: LeftRightSwitch(
            iconsColor: '#F5F5DC'.toColor(),
            iconsSize: 48,
            rightBorder: false,
            middleWidget: WordCard(
              unitId: unitId,
              unitTitle: unitTitle,
              wordsStatus: widget.wordsStatus,
              wordsPhrase: widget.wordsPhrase,
              wordIndex: widget.wordIndex,
              sizedBoxWidth: 125,
              sizedBoxHeight: 88,
              fontSize: 30,
              isBpmf: isBpmf,
              isVertical: false,
              disable: true
            ),
            isFirst: (widget.wordIndex == 0),
            isLast: (widget.wordIndex == widget.wordsStatus.length - 1),
            onLeftClicked: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TeachWordView(
                  unitId: widget.unitId,
                  unitTitle: widget.unitTitle,
                  wordsStatus: widget.wordsStatus,
                  wordsPhrase: widget.wordsPhrase,
                  wordIndex: widget.wordIndex - 1,
              )));
            },
            onRightClicked: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TeachWordView(
                  unitId: widget.unitId,
                  unitTitle: widget.unitTitle,
                  wordsStatus: widget.wordsStatus,
                  wordsPhrase: widget.wordsPhrase,
                  wordIndex: widget.wordIndex + 1,
              )));
            }
          )
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:do_it_yourself/database/DatabaseManager.dart';
import 'package:do_it_yourself/dto/SequenceData.dart';
import 'package:do_it_yourself/dto/SequenceItem.dart';
import 'package:do_it_yourself/screens/FinalScreen.dart';
import 'package:flutter/material.dart';
import '../globals/Globals.dart';
import 'dart:async';
import 'SequenceScreen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SequenceScreenState extends State<SequenceScreen> {
  SequenceScreenState({required this.itemTitle}) {
    initializeSequenceData(itemTitle);
  }

  late List<SequenceItem> sequenceItemList;
  late List<int> actionsTimesList = [];
  late int myIndex;
  late DateTime sequenceStart;
  late DateTime actionStart;
  final String itemTitle;
  Widget myWidget = const SizedBox.shrink();
  bool isFirstLoad = true;
  bool soundOn = true;
  FlutterTts flutterTts = FlutterTts();
  late SequenceData sequenceData;

  @override
  Widget build(BuildContext context) {
    if (isFirstLoad) {
      Future.delayed(const Duration(seconds: 1), () {
        getSequenceItems().then((value) => setState(() {
              sequenceItemList = value;
              myIndex = sequenceItemList.length - 1;
              isFirstLoad = false;
            }));
      });

      sequenceStart = DateTime.now();
      actionStart = sequenceStart;

      return const SizedBox.shrink();
    }

    int indexItem = 0;
    List<Widget> sequencesWidgetList = <Widget>[];
    List<Widget> mainImageWidgetList = <Widget>[];

    for (int i = sequenceItemList.length - 1; i >= 0; i--) {
      SequenceItem sequenceItem = sequenceItemList[i];
      bool selectedSequenceFrameNeeded;

      myIndex == sequenceItemList.length - i - 1
          ? selectedSequenceFrameNeeded = true
          : selectedSequenceFrameNeeded = false;
      sequencesWidgetList
          .add(buildItem(sequenceItem, false, selectedSequenceFrameNeeded));
      mainImageWidgetList.add(buildItem(sequenceItem, true, true));
      indexItem++;
    }
    myWidget = mainImageWidgetList[myIndex];

    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("Assets/Images/Background_Image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Flex(direction: Axis.vertical, children: [
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    Flexible(
                        flex: 1,
                        child: Stack(children: [
                          buildTitle(),
                          Globals.buildBackButton(
                              context, true, Alignment.topRight),
                          Globals.buildUserNameLoggedInButton(),
                        ])),
                    Flexible(
                        flex: 2,
                        child: Stack(children: [
                          buildSequenceImages(sequencesWidgetList),
                        ])),
                    Flexible(
                        flex: 5,
                        child: Stack(
                          children: [
                            buildPlayAgainButton(),
                            buildNextButton(mainImageWidgetList),
                            buildMainImage(),
                          ],
                        )),
                  ]))
            ])));
  }

  Widget buildItem(SequenceItem sequenceItem, bool isMainImage,
      bool selectedSequenceFrameNeeded) {
    int flexImageSize = isMainImage ? 6 : 10;
    int flexTextSize = isMainImage ? 1 : 3;
    FontWeight fontWeight = isMainImage ? FontWeight.w800 : FontWeight.w600;
    double fontSize = isMainImage ? 18 : 14;

    return Expanded(
        child: Stack(
      children: [
        buildPictureAndTextItem(flexImageSize, flexTextSize, fontWeight,
            fontSize, sequenceItem.imageUrl, sequenceItem.sequenceImageText),
        buildFrameItem(
            "Assets/Images/Sequence_Frame.png", !selectedSequenceFrameNeeded),
        buildFrameItem("Assets/Images/Selected_Sequence_Frame.png",
            selectedSequenceFrameNeeded)
      ],
    ));
  }

  Widget buildPictureAndTextItem(
      int flexImageSize,
      int flexTextSize,
      FontWeight fontWeight,
      double fontSize,
      String imageUrl,
      String sequenceImageText) {
    return Center(
        child: FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 0.8,
            child: Column(children: [
              Flexible(
                  flex: flexImageSize,
                  child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage(imageUrl),
                        ),
                      ))),
              Flexible(
                flex: flexTextSize,
                child: Center(
                    child: AutoSizeText(sequenceImageText,
                        style: TextStyle(
                          fontWeight: fontWeight,
                          fontSize: fontSize,
                        ),
                        textAlign: TextAlign.center)),
              ),
            ])));
  }

  Widget buildFrameItem(String frameUrl, bool selectedSequenceFrameNeeded) {
    if (selectedSequenceFrameNeeded) {
      return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage(frameUrl),
            ),
          ));
    } else {
      return const SizedBox.shrink();
    }
  }

  MaterialColor getColor(int itemIndex) {
    if (itemIndex == myIndex) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  Widget buildTitle() {
    return Container(
        decoration: BoxDecoration(
      image: DecorationImage(
          image: AssetImage(Globals.createTitleImagePathForItem(itemTitle)),
          fit: BoxFit.contain),
    ));
  }

  Widget buildSequenceImages(List<Widget> widgetList) {
    return Center(
        child: FractionallySizedBox(
            widthFactor: 0.8,
            child: Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blue)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widgetList,
                ))));
  }

  Container buildPlayAgainButton() {
    return Container(
        padding: EdgeInsets.only(left: 50, bottom: 100),
        child: Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
                child: Row(children: [
                  Text("נגן שוב"),
                  SizedBox(width: 5),
                  Icon(Icons.volume_up)
                ], mainAxisSize: MainAxisSize.min),
                style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 136, 143, 138)),
                onPressed: () {
                  soundImageText();
                })));
  }

  Container buildNextButton(List<Widget> widgetList) {
    return Container(
        padding: EdgeInsets.only(left: 50, bottom: 50),
        child: Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton(
                child: Row(children: [
                  Text(getText()),
                  SizedBox(width: 5),
                  Icon(getIcon())
                ], mainAxisSize: MainAxisSize.min),
                style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 43, 151, 66)),
                onPressed: () {
                  setState(() {
                    if (myIndex == 0) {
                      soundOn = false;
                      DateTime sequenceEnd = DateTime.now();
                      int actionSeconds =
                          sequenceEnd.difference(actionStart).inSeconds;

                      actionSeconds = checkActionSeconds(actionSeconds);

                      actionsTimesList.add(actionSeconds);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FinalScreen(
                                  sequenceName: itemTitle,
                                  actionsTimesList: actionsTimesList,
                                  sequenceData: sequenceData)));
                    } else {
                      DateTime actionEnd = DateTime.now();
                      int actionSeconds =
                          actionEnd.difference(actionStart).inSeconds;

                      actionSeconds = checkActionSeconds(actionSeconds);

                      myIndex--;
                      myWidget = widgetList[myIndex];
                      actionsTimesList.add(actionSeconds);
                      actionStart = actionEnd;
                    }
                  });
                })));
  }

  int checkActionSeconds(int actionSeconds) {
    actionSeconds == 0 ? actionSeconds = 1 : actionSeconds = actionSeconds;

    return actionSeconds;
  }

  String getText() {
    if (myIndex == 0) {
      return "סיימתי";
    } else {
      return "הבא";
    }
  }

  IconData getIcon() {
    if (myIndex == 0) {
      return Icons.check;
    } else {
      return Icons.arrow_back;
    }
  }

  Widget buildMainImage() {
    soundImageText();
    return Center(
        child: FractionallySizedBox(
      heightFactor: 0.9,
      widthFactor: 0.5,
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
        child: Row(children: [myWidget]),
      ),
    ));
  }

  void soundImageText() {
    if (soundOn) {
      speak(sequenceItemList[sequenceItemList.length - myIndex - 1]
          .sequenceImageText);
    }
  }

  Future<void> speak(String text) async {
    //print(await flutterTts.getLanguages);
    flutterTts.setLanguage("he-IL"); // Set the language to Hebrew (Israel)
    await flutterTts.setSpeechRate(0.4); // Set the speech rate (optional)
    //await flutterTts.setVolume(20.0); // Set the volume (optional)
    await flutterTts.speak(text); // Speak the provided text
  }

  Future<List<SequenceItem>> getSequenceItems() async {
    List<SequenceItem> sequenceItemList = List.empty(growable: true);

    List<String> images = sequenceData.images;

    for (int i = 1; i <= sequenceData.amountOfItems; i++) {
      String sequenceImageText = sequenceData.actionsTextMap["action_$i"]!;

      sequenceItemList.add(SequenceItem.createSequenceItem(
          itemTitle, sequenceImageText, "action_$i"));
    }

    return sequenceItemList;
  }

  Future<void> initializeSequenceData(String itemTitle) async {
    sequenceData = await Globals.createSequenceData(itemTitle) ??
        SequenceData.emptyCon(); // Default value if null
  }
}

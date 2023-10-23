import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:do_it_yourself/database/DatabaseManager.dart';
import 'package:do_it_yourself/database/GenericSequence.dart';
import 'package:do_it_yourself/dto/SequenceData.dart';
import 'package:do_it_yourself/dto/SequenceItem.dart';
import 'package:do_it_yourself/globals/Globals.dart';
import 'package:do_it_yourself/screens/FinalScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:do_it_yourself/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
//import 'package:flutter_text/flutter_text.dart';

class FinalScreenState extends State<FinalScreen> {
  FinalScreenState(
      {required this.sequenceName,
      required this.actionsTimesList,
      required this.sequenceData});

  final String sequenceName;
  final List<int> actionsTimesList;
  final SequenceData sequenceData;
  late List<GenericSequence> genericSequencesList;
  late Table? table = Table();
  int totalSeconds = 0;
  bool isFirstLoad = true;
    final controller = ConfettiController();


  @override
  void initState() {
    controller.play();
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstLoad) {
      isFirstLoad = false;
      calculateTotalSeconds();
      updateTableData();
    }

    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("Assets/Images/Background_Image.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          ConfettiWidget(
            confettiController: controller,
            shouldLoop: true,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 20,
          ),
          Globals.buildUserNameLoggedInButton(),
          const AutoSizeText(
            "!כל הכבוד",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik_Moonrocks', // Use the custom font family
              fontSize: 60.0, // Set the font size
            ),
            maxFontSize: 60.0, // Set the maximum font size
            minFontSize: 12.0, // Set the minimum font size
            maxLines: 1, // Set the maximum number of lines
            overflow: TextOverflow.ellipsis, // Handle overflow
          ),
          const AutoSizeText(
            ":הצלחת לסיים את הרצף",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik_Moonrocks', // Use the custom font family
              fontSize: 60.0, // Set the font size
            ),
            maxFontSize: 60.0, // Set the maximum font size
            minFontSize: 12.0, // Set the minimum font size
            maxLines: 1, // Set the maximum number of lines
            overflow: TextOverflow.ellipsis, // Handle overflow
          ),
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: CircleAvatar(
                  radius: 55.0,
                  backgroundImage: AssetImage(Globals.currentSequenceImageUrl),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              AutoSizeText(
                sequenceName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Rubik_Moonrocks', // Use the custom font family
                  fontSize: 60.0, // Set the font size
                ),
                maxFontSize: 60.0, // Set the maximum font size
                minFontSize: 12.0, // Set the minimum font size
                maxLines: 1, // Set the maximum number of lines
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )),
          AutoSizeText(
            buildSequenceTimeTextToDisplay(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Rubik_Moonrocks', // Use the custom font family
              fontSize: 60.0, // Set the font size
            ),
            maxFontSize: 60.0, // Set the maximum font size
            minFontSize: 12.0, // Set the minimum font size
            maxLines: 1, // Set the maximum number of lines
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(width: 20),
          Container(
              padding: EdgeInsets.only(top: 50),
              child: table ?? getEmptyWidget()),
          buildHomeButton(context)
        ],
      ),
    ));
  }

  Future<void> updateTableData() async {
    await DatabaseManager.runDB(actionsTimesList, totalSeconds, sequenceData);
    genericSequencesList = await DatabaseManager.getSequencesList();
    table = await Globals.buildTable(genericSequencesList, true);
    setState(() {});
  }

  Widget getEmptyWidget() {
    setState(() {});
    return const SizedBox.shrink();
  }

  void calculateTotalSeconds() {
    for (int i = 0; i < actionsTimesList.length; i++) {
      int item = actionsTimesList[i];

      totalSeconds += item;
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  String buildSequenceNameTextToDisplay() {
    String textToDisplay = "הצלחת לסיים את הרצף:";

    textToDisplay = '$textToDisplay $sequenceName';

    return textToDisplay;
  }

  String buildSequenceTimeTextToDisplay() {
    String timeDuration = Globals.getTimeDurationBySecondsOnly(totalSeconds);
    String textToDisplay = "הזמן שלקח לך: ";

    textToDisplay = '$textToDisplay $timeDuration';

    return textToDisplay;
  }

  String getTimeMeasurement() {
    if (Globals.convertSecondsToHours(totalSeconds) > 0) {
      return "שעות";
    } else if (Globals.getMinutesRemainder(totalSeconds) > 0) {
      return "דקות";
    } else {
      return "שניות";
    }
  }

  Widget buildHomeButton(BuildContext context) {
    return Flexible(
        flex: 1,
        child: Container(
            padding: EdgeInsets.only(left: 50, bottom: 50),
            child: Align(
                alignment: Alignment.bottomLeft,
                child: ElevatedButton(
                    child: Row(children: [
                  Text("דף הבית"),
                  SizedBox(width: 5),
                  Icon(Icons.home)
                ], mainAxisSize: MainAxisSize.min),
                style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 175, 76, 129)),
                onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);

                }))));
  }
}

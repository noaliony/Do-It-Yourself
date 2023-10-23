import 'package:do_it_yourself/database/DatabaseManager.dart';
import 'package:do_it_yourself/dto/MenuItem.dart';
import 'package:do_it_yourself/screens/LoginScreen.dart';
import 'package:do_it_yourself/screens/PrograssTrackingScreen.dart';
import 'package:do_it_yourself/screens/SequenceScreen.dart';
import 'package:flutter/material.dart';
import '../globals/Globals.dart';
import 'dart:async';
import 'CategoryScreen.dart';

class CategoryScreenState extends State<CategoryScreen> {
  CategoryScreenState({required this.itemTitle, required this.isHomePage});

  late List<MenuItem> menuItemList;
  final String itemTitle;
  bool isFirstLoad = true;
  bool myChildrenAreSequences = false;
  bool isHomePage;

  @override
  Widget build(BuildContext context) {
    if (isFirstLoad) {
      Future.delayed(const Duration(seconds: 1), () {
        getMenuItems().then((value) => setState(() {
              menuItemList = value;
              isFirstLoad = false;
            }));
      });

      return Globals.getEmptyWidget();
    }

    List<Widget> widgetList = <Widget>[];

    for (MenuItem menuItem in menuItemList) {
      widgetList.add(buildItem(menuItem));
    }

    return Scaffold(
        body: Container(
            decoration: Globals.updateBackground(),
            child: Flex(direction: Axis.vertical, children: [
              Expanded(
                  flex: 1,
                  child: Stack(children: [
                    buildTitle(),
                    buildBackButton(),
                    buildSwitchUserButton(),
                    buildPrograssTrackingButton(),
                    Globals.buildUserNameLoggedInButton()
                  ])),
              buildItemsList(widgetList)
            ])));
  }

  Widget buildItem(MenuItem menuItem) {
    return InkWell(
      child: Column(children: [
        SizedBox(
          child: CircleAvatar(
            radius: 65.0,
            backgroundImage: AssetImage(menuItem.imageUrl),
          ),
        ),
        Center(
          child: Container(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                menuItem.itemTitle,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )),
        ),
      ]),
      onTap: () {
        Navigator.push(context, getScreen(context, menuItem));
      },
    );
  }

  Widget buildTitle() {
    return Container(
        decoration: BoxDecoration(
      image: DecorationImage(
          image: AssetImage(Globals.createTitleImagePathForItem(itemTitle)),
          fit: BoxFit.contain),
    ));
  }

  Widget buildBackButton() {
    if (!isHomePage) {
      return Globals.buildBackButton(context, false, Alignment.centerRight);
    } else {
      return const SizedBox.shrink();
    }
  }

  Expanded buildItemsList(List<Widget> widgetList) {
    int len = widgetList.length;
    List<Widget> part1 = [];
    List<Widget> part2 = [];

    for (int i = 0; i < len ~/ 2; i++) {
      part1.add(widgetList[i]);
      part2.add(widgetList[len - i - 1]);
    }

    if (len.isOdd) {
      part1.add(widgetList[len ~/ 2]);
      part2.add(InkWell(
        child: Container(
            child: Column(children: [
          const SizedBox(
            child: const CircleAvatar(
              radius: 49.0,
              backgroundColor: Colors.transparent,
            ),
          ),
          Center(
            child: Container(
                padding: const EdgeInsets.only(top: 8.0),
                child: const Text(
                  "",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                )),
          ),
        ])),
      ));
    }

    return Expanded(
      flex: 2,
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var item in part1)
                  Expanded(
                    child: item,
                  ),
              ],
            ),
            const SizedBox(
              height: 90,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var item in part2)
                  Expanded(
                    child: item,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<MenuItem>> getMenuItems() async {
    List<MenuItem> menuItemList = List.empty(growable: true);

    try {
      Map<String, dynamic> jsonFileData = await Globals.readJson(itemTitle);
      List<String> items = List<String>.from(jsonFileData["Items"]);

      myChildrenAreSequences = jsonFileData["MyChildrenAreSequences"];

      for (String title in items) {
        menuItemList.add(MenuItem.createMenuItem(title));
      }
    } catch (err) {
      print(err);
    }

    return menuItemList;
  }

  MaterialPageRoute getScreen(BuildContext context, MenuItem menuItem) {
    if (!myChildrenAreSequences) {
      return MaterialPageRoute(
          builder: (context) =>
              CategoryScreen(itemTitle: menuItem.itemTitle, isHomePage: false));
    } else {
      Globals.currentSequenceImageUrl = menuItem.imageUrl;
      return MaterialPageRoute(
          builder: (context) => SequenceScreen(itemTitle: menuItem.itemTitle));
    }
  }

  Widget buildSwitchUserButton() {
    if (isHomePage) {
      return Container(
          padding: EdgeInsets.only(left: 50, bottom: 100, right: 10),
          child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                  child: Row(children: [
                    Text("החלף משתמש"),
                    SizedBox(width: 5),
                    Icon(Icons.group)
                  ], mainAxisSize: MainAxisSize.min),
                  style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 175, 76, 129)),
                  onPressed: () {
                    DatabaseManager.closeDBFile();
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  })));
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildPrograssTrackingButton() {
    if (isHomePage) {
      return Container(
          padding: EdgeInsets.only(left: 50, right: 10),
          child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                  child: Row(children: [
                    Text("מעקב התקדמות"),
                    SizedBox(width: 5),
                    Icon(Icons.trending_up)
                  ], mainAxisSize: MainAxisSize.min),
                  style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 175, 76, 129)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PrograssTrackingScreen()));
                  })));
    } else {
      return const SizedBox.shrink();
    }
  }
}

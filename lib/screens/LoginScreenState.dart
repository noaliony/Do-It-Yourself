import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:do_it_yourself/database/DatabaseManager.dart';
import 'package:do_it_yourself/exceptions/NoNameEnteredException.dart';
import 'package:do_it_yourself/exceptions/UserAlreadyExistsException.dart';
import 'package:do_it_yourself/exceptions/UserIsNotExistsException.dart';
import 'package:do_it_yourself/exceptions/UserNameDoesNotContainFirstAndLastNameException.dart';
import 'package:do_it_yourself/exceptions/UserNameDoesNotContainSpaceInAppropriatePositionException.dart';
import 'package:do_it_yourself/globals/Globals.dart';
import 'package:do_it_yourself/screens/CategoryScreen.dart';
import 'package:do_it_yourself/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as pt;
import 'package:path_provider/path_provider.dart';

class LoginScreenState extends State<LoginScreen> {
  bool showAddUser = false;
  bool showRemoveUser = false;
  bool showErrorMessageTextField = false;
  bool showErrorMessageSelectedUser = false;
  TextEditingController _textEditingAddUserController = TextEditingController();
  TextEditingController _textEditingRemoveUserController =
      TextEditingController();
  List<Widget> UserAvatarsList = [];
  String errorMessageTextField = "";
  String errorMessageSelectedUser = "";
  String selectedAvatarFullName = "";
  Color defaultButtonColor = Color.fromARGB(255, 165, 212, 227);
  Color pressedButtonColor = Color.fromARGB(255, 175, 76, 129);
  Color addButtonColor = Color.fromARGB(255, 165, 212, 227);
  Color removeButtonColor = Color.fromARGB(255, 165, 212,
      227); //Color.fromARGB(255, 165, 212, 227) BLUE; Color.fromARGB(255, 220, 182, 124) ORANGE;

  @override
  Widget build(BuildContext context) {
    _getFilesInDocumentsDirectory();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("Assets/Images/Background_Image.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Flex(direction: Axis.vertical, children: [
              SizedBox(height: 50),
              Expanded(
                flex: 1,
                child: buildTitle(),
              ),
              Expanded(
                flex: 1,
                child: buildLoginInstructions(),
              ),
              Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                      child: Column(
                    children: [
                      appUsersUpdate(),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                padding: EdgeInsets.only(top: 20, bottom: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: UserAvatarsList,
                                )),
                          ]),
                      buildSelectedAvatarTextField(),
                      buildDoneButton(),
                      buildErrorMessageSelectedUserText()
                    ],
                  ))),
            ])));
  }

  Widget buildTitle() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("Data/welcome_title.png"),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget buildLoginInstructions() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("Data/login_instructions.png"),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget appUsersUpdate() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        buildAddButton(),
        SizedBox(width: 16),
        buildRemoveButton()
      ]),
      SizedBox(height: 16),
      buildAddUserTextField(),
      buildRemoveUserTextField(),
      buildErrorMessageTextFieldText(),
      buildInsertUserButton(),
      buildRemoveUserButton()
    ]);
  }

  Widget buildAddButton() {
    return Container(
        child: ElevatedButton(
            child: Row(children: const [
              Text("הוסף משתמש"),
              SizedBox(width: 5),
              Icon(Icons.person_add)
            ], mainAxisSize: MainAxisSize.min),
            style: ElevatedButton.styleFrom(primary: addButtonColor),
            onPressed: () {
              setState(() {
                showAddUser = true; // Show Add text field
                showRemoveUser = false; // Show Add text field
                resetTextFieldsAddAndRemove();
                addButtonColor = pressedButtonColor;
                removeButtonColor = defaultButtonColor;
              });
            }));
  }

  Widget buildRemoveButton() {
    return Container(
        child: ElevatedButton(
            child: Row(children: const [
              Text("הסר משתמש"),
              SizedBox(width: 5),
              Icon(Icons.person_remove)
            ], mainAxisSize: MainAxisSize.min),
            style: ElevatedButton.styleFrom(primary: removeButtonColor),
            onPressed: () {
              setState(() {
                showRemoveUser = true;
                showAddUser = false; // Show Remove text field
                resetTextFieldsAddAndRemove();
                removeButtonColor = pressedButtonColor;
                addButtonColor = defaultButtonColor;
              });
            }));
  }

  Widget buildAddUserTextField() {
    return Visibility(
        visible: showAddUser,
        child: SizedBox(
          width: 250,
          child: TextField(
            controller: _textEditingAddUserController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'הכנס שם פרטי ומשפחה',
              prefixIcon: const Icon(Icons.person_add),
            ),
          ),
        ));
  }

  Widget buildRemoveUserTextField() {
    return Visibility(
        visible: showRemoveUser,
        child: SizedBox(
          width: 250,
          child: TextField(
            controller: _textEditingRemoveUserController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'הכנס שם פרטי ומשפחה',
              prefixIcon: const Icon(Icons.person_remove),
            ),
          ),
        ));
  }

  Widget buildInsertUserButton() {
    return Visibility(
        visible: showAddUser,
        child: Container(
            padding: EdgeInsets.only(
                top: 20, right: 0), // Adjusted padding for the "Add" button
            child: ElevatedButton(
                onPressed: () async {
                  String newUserName = _textEditingAddUserController.text;

                  _textEditingAddUserController.clear();
                  print(newUserName);
                  try {
                    await createFileInFolder(newUserName);
                    showErrorMessageTextField = false;
                    setState(() {});
                  } catch (exception) {
                    setState(() {
                      if (exception is UserAlreadyExistsException ||
                          exception is NoNameEnteredException ||
                          exception
                              is UserNameDoesNotContainFirstAndLastNameException) {
                        errorMessageTextField = exception.toString();
                      } else {
                        errorMessageTextField =
                            "An unexpected error occurred: $exception";
                      }
                      showErrorMessageTextField = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: defaultButtonColor,
                ),
                child: Text("הוסף"))));
  }

  Widget buildRemoveUserButton() {
    return Visibility(
        visible: showRemoveUser,
        child: Container(
            padding: EdgeInsets.only(
                top: 20, right: 0), // Adjusted padding for the "Add" button
            child: ElevatedButton(
                onPressed: () async {
                  String userToRemove = _textEditingRemoveUserController.text;

                  _textEditingRemoveUserController.clear();
                  print(userToRemove);

                  if (userToRemove == selectedAvatarFullName) {
                    selectedAvatarFullName = "";
                  }

                  try {
                    await removeUserFromSystem(userToRemove);
                    showErrorMessageTextField = false;
                    setState(() {});
                  } catch (exception) {
                    setState(() {
                      if (exception is UserAlreadyExistsException ||
                          exception is NoNameEnteredException ||
                          exception is UserIsNotExistsException ||
                          exception
                              is UserNameDoesNotContainFirstAndLastNameException) {
                        errorMessageTextField = exception.toString();
                      } else {
                        errorMessageTextField =
                            "An unexpected error occurred: $exception";
                      }
                      showErrorMessageTextField = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: defaultButtonColor,
                ),
                child: Text("הסר"))));
  }

  Future<void> removeUserFromSystem(String userNameToRemove) async {
    String validUserNameToRemove =
        validityChecksToUserNameToAddOrRemove(userNameToRemove);
    String correctUserNameToAdd = validUserNameToRemove.replaceAll(" ", "_");

    Directory userDataDirectory = Directory(Globals.tmpPath);
    List<FileSystemEntity> files = userDataDirectory.listSync();
    String targetFileName =
        '${Globals.tmpPath}/$correctUserNameToAdd${Globals.extensionDBFiles}';

    if (!(await File(targetFileName).exists())) {
      throw UserIsNotExistsException(userName: validUserNameToRemove);
    }

    UserAvatarsList.clear();
    try {
      for (FileSystemEntity file in files) {
        if (file is File &&
            file.path
                .endsWith("$correctUserNameToAdd${Globals.extensionDBFiles}")) {
          await file.delete();
          print('File "$targetFileName" deleted.');
        }
      }
    } catch (exception) {
      print("Error: $exception");
    }
  }

  Future<void> createFileInFolder(String userNameToAdd) async {
    String validUserNameToAdd =
        validityChecksToUserNameToAddOrRemove(userNameToAdd);
    String correctUserNameToAdd = validUserNameToAdd.replaceAll(" ", "_");
    String filePath =
        '${Globals.tmpPath}/$correctUserNameToAdd' + Globals.extensionDBFiles;

    if (!(await File(filePath).exists())) {
      await File(filePath).create(recursive: true);
    } else {
      throw UserAlreadyExistsException(userName: validUserNameToAdd);
    }
  }

  String validityChecksToUserNameToAddOrRemove(String userNameToAddOrRemove) {
    if (userNameToAddOrRemove.isEmpty) {
      throw NoNameEnteredException();
    } else {
      String validName = "";

      while (countCharacterOccurrences(userNameToAddOrRemove, ' ') != 1) {
        int nameLenght = userNameToAddOrRemove.length;

        if (userNameToAddOrRemove.startsWith(" ")) {
          userNameToAddOrRemove =
              userNameToAddOrRemove.substring(1, nameLenght);
        } else if (userNameToAddOrRemove.endsWith(" ")) {
          userNameToAddOrRemove =
              userNameToAddOrRemove.substring(0, nameLenght - 1);
        } else {
          bool isFirstSpaceSeen = false;

          for (int i = 0; i < nameLenght; i++) {
            if (userNameToAddOrRemove[i] != " ") {
              validName += userNameToAddOrRemove[i];
            } else if (isFirstSpaceSeen == false) {
              validName += userNameToAddOrRemove[i];
              isFirstSpaceSeen = true;
            } else if (userNameToAddOrRemove[i - 1] != " ") {
              break;
            }
          }
          break;
        }
      }

      if (validName == "") {
        validName = userNameToAddOrRemove;
      } else if (countCharacterOccurrences(validName, ' ') == 0) {
        throw UserNameDoesNotContainFirstAndLastNameException(
            userName: validName);
      }

      return validName;
    }
  }

  int countCharacterOccurrences(String inputString, String targetCharacter) {
    int count = 0;

    for (int i = 0; i < inputString.length; i++) {
      if (inputString[i] == targetCharacter) {
        count++;
      }
    }

    return count;
  }

  @override
  void dispose() {
    _textEditingAddUserController.dispose();
    super.dispose();
  }

  Future<void> _getFilesInDocumentsDirectory() async {
    try {
      Directory userDataDirectory = Directory(Globals.tmpPath);
      List<FileSystemEntity> entities = userDataDirectory.listSync();

      UserAvatarsList.clear();

      for (var entity in entities) {
        if (entity is File) {
          String fileExtension = pt.extension(entity.path);
          String fileName =
              pt.basename(entity.path).replaceAll(fileExtension, "");

          if (fileExtension == Globals.extensionDBFiles) {
            setState(() {
              UserAvatarsList.add(buildAvatar(fileName.replaceAll("_", " ")));
            });
          }
        }
      }
    } catch (exception) {
      print("Error: $exception");
    }
  }

  Widget buildAvatar(String name) {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(children: [
          GestureDetector(
            onTap: () {
              setState(() {
                selectedAvatarFullName = name;
                errorMessageSelectedUser = "";
              });
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Color.fromARGB(255, 220, 182, 124),
                  child: FittedBox(
                      child: Text(
                    name.split(" ")[0],
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  )),
                ),
                SizedBox(height: 16),
                Text(
                  "${name.split(" ")[0]} ${name.split(" ")[1]}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ]));
  }

  Widget buildSelectedAvatarTextField() {
    return SizedBox(
        width: 250,
        child: Align(
            alignment: Alignment.topCenter,
            child: TextField(
              controller: TextEditingController(text: selectedAvatarFullName),
              readOnly: true,
              decoration: InputDecoration(
                labelText: "השם המלא של המשתמש הנבחר",
                labelStyle: TextStyle(fontSize: 12),
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            )));
  }

  Widget buildDoneButton() {
    return Container(
        padding: EdgeInsets.only(top: 20),
        child: Align(
            alignment: Alignment.topCenter,
            child: ElevatedButton(
                child: Row(children: [
                  Text("היכנס"),
                  SizedBox(width: 5),
                  Icon(Icons.done_outline)
                ], mainAxisSize: MainAxisSize.min),
                style: ElevatedButton.styleFrom(primary: defaultButtonColor),
                onPressed: () async {
                  if (validityCheckToSelectedEmptyUserName()) {
                    DatabaseManager.username =
                        selectedAvatarFullName.replaceAll(" ", "_");

                    await DatabaseManager.connectUserDatabaseFile();
                    // Navigate to the SecondPage and set it as the first page
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            CategoryScreen(itemTitle: "", isHomePage: true)));
                  } else {
                    showErrorMessageSelectedUser = true;
                    errorMessageSelectedUser = "אנא בחר משתמש תחילה";
                    setState(() {});
                  }
                })));
  }

  bool validityCheckToSelectedEmptyUserName() {
    return selectedAvatarFullName.isEmpty ? false : true;
  }

  Widget buildErrorMessageTextFieldText() {
    return Visibility(
      visible: showErrorMessageTextField,
      child: SizedBox(
        width: 250,
        child: AutoSizeText(
          errorMessageTextField,
          textAlign: TextAlign.center, // Center-align the text
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget buildErrorMessageSelectedUserText() {
    return Visibility(
        visible: showErrorMessageSelectedUser,
        child: Container(
            padding: EdgeInsets.only(top: 10),
            child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                    width: 250,
                    child: Center(
                      child: AutoSizeText(errorMessageSelectedUser,
                          style: TextStyle(color: Colors.red)),
                    )))));
  }

  void resetTextFieldsAddAndRemove() {
    _textEditingAddUserController.clear();
    _textEditingRemoveUserController.clear();
  }
}

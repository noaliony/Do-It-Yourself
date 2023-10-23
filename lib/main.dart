import 'package:do_it_yourself/globals/Globals.dart';
import 'package:do_it_yourself/screens/CategoryScreen.dart';
import 'package:do_it_yourself/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Create a folder named 'my_folder' inside the Documents directory
  await createUserDataFolderInDocuments();
  await initializeHebrewEnglishTableName();
  // Create a file named 'my_file.txt' inside the 'my_folder'
  // File file = await createFileInFolder('my_folder', 'my_file.txt');

  // Write data to the file
  // await file.writeAsString('Hello, world!');
  runApp(const MyApp());
}

Future<void> createUserDataFolderInDocuments() async {
  String folderName = "DoItYourself/UserData";
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String folderPath = '${documentsDirectory.path}/$folderName';
  Globals.tmpPath = folderPath;

  if (!(await Directory(folderPath).exists())) {
    await Directory(folderPath).create(recursive: true);
  }
}

Future<void> initializeHebrewEnglishTableName() async {
  String jsonPath = Globals.basePath + Globals.sequencesMapjsonFileSuffix;
  String response = await rootBundle.loadString(jsonPath);
  final jsonMap = jsonDecode(response);

    if (jsonMap is Map<String, dynamic>) {
      Globals.hebrewEnglishTableName = Map<String, String>.from(jsonMap);
    }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Do It Yourself',
      theme: ThemeData(
        scaffoldBackgroundColor: Color.fromARGB(255, 189, 222, 233),
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        // body: Center(child: CategoryScreen(itemTitle: "", isHomePage: true)));
        body: Center(child: LoginScreen()));
  }
}

class SequenceData {
  late String name;
  late String englishName;
  late bool myChildrenAreSequences;
  late String DBCommand;
  late int amountOfItems;
  late List<String> images;
  late Map<String, String> actionsTextMap;

  SequenceData(
      {required this.name,
      required this.englishName,
      required this.myChildrenAreSequences,
      required this.DBCommand,
      required this.amountOfItems,
      required this.images,
      required this.actionsTextMap});

  SequenceData.emptyCon();

// name = "";
//    englishName = "";
//     myChildrenAreSequences = false;
//     DBCommand = "";
//     amountOfItems = 0;
//     images = [];
}

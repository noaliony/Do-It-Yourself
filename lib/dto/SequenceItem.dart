import "../globals/Globals.dart";

class SequenceItem {
  const SequenceItem(
      {required this.itemTitle,
      required this.sequenceImageText,
      required this.actionNumber,
      required this.imageUrl});

  final String itemTitle;
  final String sequenceImageText;
  final String imageUrl;
  final String actionNumber;

  static SequenceItem createSequenceItem(
      String itemTitle, String sequenceImageText, String actionNumber) {
    String imageUrl =
        Globals.createImagePathForSequenceItem(itemTitle, actionNumber);

    return SequenceItem(
        itemTitle: itemTitle,
        sequenceImageText: sequenceImageText,
        imageUrl: imageUrl,
        actionNumber: actionNumber);
  }
}

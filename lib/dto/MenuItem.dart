import "../globals/Globals.dart";

class MenuItem {
  const MenuItem(
      {required this.itemTitle,
      required this.imageUrl,
      required this.titleImageUrl});

  final String itemTitle;
  final String imageUrl;
  final String titleImageUrl;

  static MenuItem createMenuItem(String itemTitle) {
    String imageUrl = Globals.createImagePathForItem(itemTitle);
    String titleImageUrl = Globals.createImagePathForItem(itemTitle);

    return MenuItem(
        itemTitle: itemTitle, imageUrl: imageUrl, titleImageUrl: titleImageUrl);
  }
}

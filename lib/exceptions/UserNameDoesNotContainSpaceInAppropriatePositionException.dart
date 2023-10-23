class UserNameDoesNotContainSpaceInAppropriatePositionException
    implements Exception {
  final String userName;

  UserNameDoesNotContainSpaceInAppropriatePositionException(
      {required this.userName});

  @override
  String toString() =>
      "השם $userName " +
      "מכיל רווח במקום לא מתאים (בתחילת או בסוף השם שהוקלד) " +
      "בבקשה תבחר שם תקין להוסיף";
}

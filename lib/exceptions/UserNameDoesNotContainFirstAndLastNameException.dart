class UserNameDoesNotContainFirstAndLastNameException implements Exception {
  final String userName;

  UserNameDoesNotContainFirstAndLastNameException({required this.userName});

  @override
  String toString() =>
      "המשתמש $userName " +
      "לא מכיל שם פרטי ושם משפחה. " +
      "בבקשה תבחר שם חדש להוסיף";
}

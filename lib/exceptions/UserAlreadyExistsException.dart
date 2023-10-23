class UserAlreadyExistsException implements Exception {
  final String userName;

  UserAlreadyExistsException({required this.userName});

  @override
  String toString() =>
      "המשתמש $userName " + "כבר קיים במערכת. " + "בבקשה תבחר שם חדש להוסיף";
}

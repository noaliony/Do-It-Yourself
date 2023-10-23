class UserIsNotExistsException implements Exception {
  final String userName;

  UserIsNotExistsException({required this.userName});

  @override
  String toString() =>
      "המשתמש $userName " + "לא קיים במערכת. " + "בבקשה תבחר שם חדש להסיר";
}

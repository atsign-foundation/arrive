class GroupData {
  String groupname = 'GroupName';
  int number = 10;
  String event = 'Event';
  String sharingUntil = '12:40';
  List<User> group = [
    User('Username', '10:45', true),
    User('Username', '10:45', false),
    User('Username', '10:45', true),
    User('Username', '10:45', false),
    User('Username', '10:45', true),
    User('Username', '10:45', false),
    User('Username', '10:45', true),
    User('Username', '10:45', true),
    User('Username', '10:45', false),
    User('Username', '10:45', true),
  ];
}

class User {
  String username;
  String sharingUntil;
  bool canSeeLocation;
  User(this.username, this.sharingUntil, this.canSeeLocation);
}

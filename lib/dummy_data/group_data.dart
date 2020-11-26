import 'package:atsign_location_app/utils/constants/images.dart';

class GroupData {
  String groupname = 'GroupName';
  int number = 10;
  String event = 'Event';
  String sharingUntil = '12:40';
  List<User> group = [
    User('Username', '10:45', true, AllImages().PERSON1),
    User('Username', '10:45', false, AllImages().PERSON2),
    User('Username', '10:45', true, AllImages().PERSON1),
    User('Username', '10:45', false, AllImages().PERSON2),
    User('Username', '10:45', true, AllImages().PERSON1),
    User('Username', '10:45', false, AllImages().PERSON2),
    User('Username', '10:45', true, AllImages().PERSON1),
    User('Username', '10:45', true, AllImages().PERSON2),
    User('Username', '10:45', false, AllImages().PERSON1),
    User('Username', '10:45', true, AllImages().PERSON2),
  ];
}

class User {
  String username;
  String sharingUntil;
  bool canSeeLocation;
  String image;
  User(this.username, this.sharingUntil, this.canSeeLocation, this.image);
}

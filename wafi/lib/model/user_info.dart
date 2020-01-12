import 'package:firebase_database/firebase_database.dart';

class UserInfo {
  final String chatToken;
  final String username;

  UserInfo({this.chatToken, this.username});

  UserInfo.fromSnapshot(DataSnapshot snapshot)
      : chatToken = snapshot.value['chatToken'],
        username = snapshot.value['username'];

  UserInfo.fromMap(dynamic obj)
      : chatToken = obj['chatToken'],
        username = obj['username'];
}
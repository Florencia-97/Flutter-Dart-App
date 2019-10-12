
import 'package:firebase_database/firebase_database.dart';

class Classroom {
  final String id;
  final int floor;
  final String code;

  Classroom({this.id, this.floor, this.code});

  Classroom.fromSnapshot(DataSnapshot snapshot)
      : id = snapshot.key,
        floor = snapshot.value['floor'],
        code = snapshot.value['code'];

  Classroom.fromMap(dynamic obj)
      : id = obj['code'].toString(),
        floor = obj['floor'],
        code = obj['code'].toString();
}

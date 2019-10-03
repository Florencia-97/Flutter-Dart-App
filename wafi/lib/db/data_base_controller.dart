import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

abstract class DataBaseController {
  Future<void> addOrder(String userId, String title, String type, String description, int classroom);

  DatabaseReference getReferenceById(String userId);

  /* TODO: Add getOrders, getOrderById, etc */

  Future<List<Classroom>> getClassrooms();
}

class FirebaseController implements DataBaseController {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  Future<void> addOrder(String userId, String title, String type, String description, int classroom) {
    var order = {
      "titulo": title,
      "type": type,
      "aula": classroom,
      "descripcion": description,
      "tomado": false
    };

    return _databaseReference.child("pedidos").child(userId).push().set(order);
  }

  DatabaseReference getReferenceById(String userId) {
    return _databaseReference.child("pedidos").child(userId);
  }

  Future<List<Classroom>> getClassrooms() async {
    DataSnapshot snapshot = await _databaseReference.child("classrooms").once();

    Map<String, dynamic> classroomsDynamic = Map<String, dynamic>.from(snapshot.value);

    List<Classroom> classrooms = [];

    for (var classroomDynamic in classroomsDynamic.values) {
      var classroomMap = Map<String, dynamic>.from(classroomDynamic);
      classrooms.add(Classroom.fromMap(classroomMap));
    }

    return classrooms;
  }
}

class Classroom {
  final String classroomId;
  final int floor;
  final String code;

  Classroom({this.classroomId, this.floor, this.code});

  Classroom.fromSnapshot(DataSnapshot snapshot)
      : classroomId = snapshot.key,
        floor = snapshot.value['floor'],
        code = snapshot.value['code'];

  Classroom.fromMap(dynamic obj)
      : classroomId = obj['code'].toString(),
        floor = obj['floor'],
        code = obj['code'].toString();
}
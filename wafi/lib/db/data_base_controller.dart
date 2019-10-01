import 'package:firebase_database/firebase_database.dart';
import 'dart:async';


abstract class DataBaseController {
  Future<void> addOrder(String userId, String title, String type, String description, int classroom);

  DatabaseReference getReferenceById(String userId);

  /* TODO: Add getOrders, getOrderById, etc */
  Future<List<Classroom>> getClassrooms();
}

class FirebaseController implements DataBaseController {
  final DatabaseReference _databaseReference  = FirebaseDatabase.instance.reference();

  Future<void> addOrder(String userId, String title, String type, String description, int classroom) {
    var order = {
      "titulo": title,
      "type": type,
      "aula": classroom,
      "descripcion": description,
      "tomado": false
    };

    var x = _databaseReference.child('pedidos');
    var y = x.child(userId);
    var z = y.push();
    print("$x $y $z");
    var w = z.set(order);
    return w;
  }

  DatabaseReference getReferenceById(String userId) {
    return _databaseReference.child('pedidos').child(userId);
  }

  Future<List<Classroom>> getClassrooms() {
    Future<DataSnapshot> x =_databaseReference.once();
    return x.then((DataSnapshot snapshot) {
      print('\n\nData : ${snapshot.value}\n\n');
      //"classrooms".)
      return [];
    });
  }
}

class Classroom {
  final int classroomId;
  final int floor;
  final String code;

  Classroom({this.classroomId, this.floor, this.code});
}
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:wafi/extras/order_item.dart';

abstract class DataBaseController {
  Future<void> addOrder(String userId, String title, String type, String description, int classroom);

  DatabaseReference getReferenceById(String userId);

  /* TODO: Add getOrders, getOrderById, etc */

  Future<List<Classroom>> getClassroomsSnapshot();

  Stream<List<OrderItem>> getClassroomsStream();
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

  Future<List<Classroom>> getClassroomsSnapshot() async {
    DataSnapshot snapshot = await _databaseReference.child("classrooms").once();

    Map<String, dynamic> classroomsDynamic = Map<String, dynamic>.from(snapshot.value);

    List<Classroom> classrooms = [];

    for (var classroomDynamic in classroomsDynamic.values) {
      var classroomMap = Map<String, dynamic>.from(classroomDynamic);
      classrooms.add(Classroom.fromMap(classroomMap));
    }

    return classrooms;
  }

   Stream<List<OrderItem>> getClassroomsStream() {
    return _databaseReference.child("pedidos").onValue.map((event) {
      Map<String, dynamic> ordersDynamic = Map<String, dynamic>.from(event.snapshot.value);
      print("map ${ordersDynamic}");

      List<OrderItem> orders = [];

      for (var ordersOfSingleUser in ordersDynamic.values) {
        Map<String, dynamic> ordersOfSingleUserDynamic = Map<String, dynamic>.from(ordersOfSingleUser);


        for (var orderDynamic in ordersOfSingleUserDynamic.values) {
          var classroomMap = Map<String, dynamic>.from(orderDynamic);
          orders.add(OrderItem.fromMap(classroomMap));
        }
      }

      return orders;
    });
  }
}

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
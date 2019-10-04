import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:wafi/extras/order_item.dart';

abstract class DataBaseController {
  Future<void> addRequestedOrder(String userId, String title, String source, String floor, String description, int classroom);

  DatabaseReference getReferenceById(String userId);

  /* TODO: getOrderById, etc */

  Future<List<Classroom>> getClassroomsSnapshot();

  Stream<List<RequestedOrder>> getRequestedOrdersStream();
}

class FirebaseController implements DataBaseController {

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  static const ORDER_COLLECTION = "order";
  static const CLASSROOM_COLLECTION = "classroom";


  Future<void> addRequestedOrder(String userId, String title, String source, String floor, String description, int classroom) {

    // this is because of a bug (Rodri)
    var finalTitle = title;
    if (finalTitle == null || finalTitle == "") {
      finalTitle = "default-${Random().nextInt(2000)}";
    }

    var order = {
      "title": finalTitle,
      "source": source,
      "floor": floor,
      "classroom": classroom,
      "description": description,
      "status": OrderStatus.Requested
    };

    return _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatus.Requested).push().set(order);
  }

  DatabaseReference getReferenceById(String userId) {
    return _databaseReference.child(ORDER_COLLECTION).child(userId);
  }

  Future<List<Classroom>> getClassroomsSnapshot() async {
    DataSnapshot snapshot = await _databaseReference.child(CLASSROOM_COLLECTION).once();

    Map<String, dynamic> classroomsDynamic = Map<String, dynamic>.from(snapshot.value);

    List<Classroom> classrooms = [];

    for (var classroomDynamic in classroomsDynamic.values) {
      var classroomMap = Map<String, dynamic>.from(classroomDynamic);
      classrooms.add(Classroom.fromMap(classroomMap));
    }

    return classrooms;
  }

   Stream<List<RequestedOrder>> getRequestedOrdersStream() {
    return _databaseReference.child(ORDER_COLLECTION).onValue.map((event) {
      Map<String, dynamic> ordersDynamic = Map<String, dynamic>.from(event.snapshot.value);
      print("map: $ordersDynamic");
      List<RequestedOrder> orders = [];

      for (var ordersOfSingleUser in ordersDynamic.values) {
        Map<String, dynamic> ordersOfSingleUserDynamic = Map<String, dynamic>.from(ordersOfSingleUser[OrderStatus.Requested]);


        for (var orderDynamic in ordersOfSingleUserDynamic.values) {
          var classroomMap = Map<String, dynamic>.from(orderDynamic);
          orders.add(RequestedOrder.fromMap(classroomMap));
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

class OrderStatus {
  static const Requested = "requested";
  static const Taken = "taken";
  static const Cancelled = "cancelled";
  static const Resolved = "resolved";

  static get values => [Requested, Taken, Cancelled, Resolved];
}
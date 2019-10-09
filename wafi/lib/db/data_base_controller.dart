import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:wafi/extras/order_item.dart';

abstract class DataBaseController {

  Future<void> addRequestedOrder(String userId, String title, String source, String floor, String description, int classroom);

  Future<void> addTakenOrder(String userId, RequestedOrder requestedOrder);

  DatabaseReference getReferenceById(String userId);

  Stream<List<RequestedOrder>> getRequestedOrdersById(String userId);

  Future<void> cancelRequestedOrder(String requestedOrderId, String userId);

    /* TODO: getOrderById, etc */

  Future<List<Classroom>> getClassroomsSnapshot();

  Stream<List<RequestedOrder>> getRequestedOrdersStream();

  Stream<List<RequestedOrder>> getTakenOrdersById(String userId);

  Future<void> setToken(String userId, String token);
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
      "status": OrderStatuses.Requested
    };

    return _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatuses.Requested).push().set(order);
  }

  Future<void> addTakenOrder(String userId, RequestedOrder requestedOrder) {

    var order = {
      "requestedOrderId": requestedOrder.id,
      "requestedUserId": requestedOrder.requesterUserId,
      "status": OrderStatuses.Taken
    };

    // !!!! transactional
    _databaseReference.child(ORDER_COLLECTION).child(requestedOrder.requesterUserId)
        .child(OrderStatuses.Requested).child(requestedOrder.id)
        .update({"status": OrderStatuses.Taken});
    return _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatuses.Taken).push().set(order);
  }

  DatabaseReference getReferenceById(String userId) {
    return _databaseReference.child(ORDER_COLLECTION).child(userId);
  }

  Stream<List<RequestedOrder>> getRequestedOrdersById(String userId) {
    Stream<Event> eventS = _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatuses.Requested).onValue;

    return eventS.map((event) {
      Map<String, dynamic> ordersDynamic = Map<String, dynamic>.from(event.snapshot.value);
      //print("getRequestedOrdersById: $ordersDynamic");

      List<RequestedOrder> orders = [];

      for (var orderId in ordersDynamic.keys) {
        var orderDynamic = ordersDynamic[orderId];
        var orderMap = Map<String, dynamic>.from(orderDynamic);
        //print("getRequestedOrdersById ${orderMap}");
        orders.add(RequestedOrder.fromMap(orderId, userId, orderMap));
      }

      return orders;
    });
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
      //print("map: $ordersDynamic");

      List<RequestedOrder> orders = [];

      for (var userId in ordersDynamic.keys) {
        var ordersOfSingleUser = ordersDynamic[userId];
        Map<String, dynamic> ordersOfSingleUserDynamic = Map<String, dynamic>.from(ordersOfSingleUser[OrderStatuses.Requested]);


        for (var orderId in ordersOfSingleUserDynamic.keys) {
          var orderDynamic = ordersOfSingleUserDynamic[orderId];
          var orderMap = Map<String, dynamic>.from(orderDynamic);
          orders.add(RequestedOrder.fromMap(orderId, userId, orderMap));
        }
      }

      return orders;
    });
  }

  Map<String, dynamic> _getorderMapById(String orderTakenId){
    Stream<Event> eventS = _databaseReference.child(ORDER_COLLECTION).onValue;
    Map<String, dynamic> orderSearch;

    eventS.map((event) {
      Map<String, dynamic> ordersDynamic = Map<String, dynamic>.from(event.snapshot.value);
      for (var userId in ordersDynamic.keys) {
        print(userId);
        var ordersOfSingleUser = ordersDynamic[userId];
        Map<String, dynamic> ordersOfSingleUserDynamic = Map<String, dynamic>.from(ordersOfSingleUser[OrderStatuses.Requested]);

        for (var orderId in ordersOfSingleUserDynamic.keys) {
          var orderDynamic = ordersDynamic[orderId];
          if(orderId != orderTakenId) continue;
          orderSearch = Map<String, dynamic>.from(orderDynamic);
        }
      }
    }
    );
    return orderSearch;
  }

  Stream<List<RequestedOrder>> getTakenOrdersById(String userId) {
    Stream<Event> eventS = _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatuses.Taken).onValue;

    return eventS.map((event) {
      Map<String, dynamic> ordersDynamic = Map<String, dynamic>.from(event.snapshot.value);
      List<RequestedOrder> orders = [];

      for (var orderTakenId in ordersDynamic.keys) {
        var orderDynamic = ordersDynamic[orderTakenId];
        var orderTakenMap = Map<String, dynamic>.from(orderDynamic);
        String orderId =  orderTakenMap['requestedOrderId'];
        Map<String, dynamic> orderMap = _getorderMapById(orderId);
        orders.add(RequestedOrder.fromMap(orderId, userId, orderMap));
      }
      return orders;
    });
  }

  // Stream<List<RequestedOrder>> getTakenOrders() {
  //   return _databaseReference.child(ORDER_COLLECTION).onValue.map((event) {
  //     Map<String, dynamic> ordersDynamic = Map<String, dynamic>.from(event.snapshot.value);

  //     List<RequestedOrder> orders = [];
  //     for (var userId in ordersDynamic.keys) {
  //       print(' User: $userId');
  //       var ordersOfSingleUser = ordersDynamic[userId];
  //       Map<String, dynamic> orderstakenOfSingleUserDynamic = Map<String, dynamic>.from(ordersOfSingleUser[OrderStatuses.Taken]);
  //       Map<String, dynamic> ordersOfSingleUserDynamic = Map<String, dynamic>.from(ordersOfSingleUser[OrderStatuses.Requested]);
  //       print(' Take: $orderstakenOfSingleUserDynamic');
  //       print(' Comun: $ordersOfSingleUserDynamic');
  //       for (var orderTakenId in orderstakenOfSingleUserDynamic.keys) {
  //         var orderTakenDynamic = orderstakenOfSingleUserDynamic[orderTakenId];
  //         var orderTakenMap = Map<String, dynamic>.from(orderTakenDynamic);
  //         print(orderTakenMap);
  //         String orderId = orderTakenMap['requestedOrderId'];
  //         print(orderId);
  //         if(ordersOfSingleUserDynamic.containsKey(orderId) == false) continue;
  //         var orderDynamic = ordersOfSingleUserDynamic[orderId];
  //         var orderMap = Map<String, dynamic>.from(orderDynamic);
  //         orders.add(RequestedOrder.fromMap(orderId, userId, orderMap, orderTakenMap['requestedUserId']));
  //       }
  //     }
  //     print(orders);
  //     return orders;
  //   });
  // }

  Future<void> cancelRequestedOrder(String requestedOrderId, String userId) {
    return _databaseReference.child(ORDER_COLLECTION).child(userId)
        .child(OrderStatuses.Requested).child(requestedOrderId)
        .update({"status": OrderStatuses.Cancelled});
  }

  Future<void> setToken(String userId, String token) {
    return _databaseReference.child('users/${userId}/notificationToken/${token}').set({"token": token});
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

class OrderStatuses {
  static const String Requested = "requested";
  static const String Taken = "taken";
  static const String Cancelled = "cancelled";
  static const String Resolved = "resolved";

  static get values => [Requested, Taken, Cancelled, Resolved];
}

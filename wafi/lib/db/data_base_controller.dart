import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:wafi/model/chat.dart';
import 'package:wafi/model/classroom.dart';
import 'package:wafi/model/order_status.dart';
import 'dart:async';

import 'package:wafi/model/requested_order.dart';


abstract class DataBaseController {

  Future<void> addRequestedOrder(String userId, String title, String source, String floor, String description, int classroom);

  Future<void> addTakenOrder(String userId, RequestedOrder requestedOrder);

  DatabaseReference getReferenceById(String userId);

  Stream<List<RequestedOrder>> getRequestedOrdersById(String userId);

  Future<void> cancelRequestedOrder(String requestedOrderId, String userId);

    /* TODO: getOrderById, etc */

  Future<List<Classroom>> getClassroomsSnapshot();

  Stream<List<RequestedOrder>> getRequestedOrdersStream();

  Future<Stream<List<RequestedOrder>>> getTakenOrdersStream(String userId);

  Future<List<String>> getTakenOrdersById(String userId);

  Future<void> setToken(String userId, String token);

  Future<void> removeToken(String userId, String token);

  Stream<Chat> getChat(String requestedOrderId);

  Future<void> sendMessage(String requestedOrderId, String fromUserId, String text, String dateTime);
}

class FirebaseController implements DataBaseController {

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  static const ORDER_COLLECTION = "order";
  static const CLASSROOM_COLLECTION = "classroom";
  static const CHAT_COLLECTION = "chat";


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
    _databaseReference.child(CHAT_COLLECTION).child(requestedOrder.id)
        .push().set({"userId": "", "text": "", "dateTime": DateTime.now().toIso8601String().toString()});
    /*_databaseReference.child(ORDER_COLLECTION).child(requestedOrder.requesterUserId)
        .child(OrderStatuses.Requested).child(requestedOrder.id)
        .update({"status": OrderStatuses.Taken});*/
    _databaseReference.child(ORDER_COLLECTION).child(requestedOrder.requesterUserId)
        .child(OrderStatuses.Requested).child(requestedOrder.id)
        .update({"status": OrderStatuses.Taken, "takenBy": userId});
    return _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatuses.Taken).child(requestedOrder.id).set(order);
  }

  DatabaseReference getReferenceById(String userId) {
    return _databaseReference.child(ORDER_COLLECTION).child(userId);
  }

  Stream<List<RequestedOrder>> getRequestedOrdersById(String userId) {
    Stream<Event> eventS = _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatuses.Requested).onValue;

    return eventS.map((event) {
      Map<String, dynamic> ordersDynamic = Map<String, dynamic>.from(event.snapshot.value);

      List<RequestedOrder> orders = [];

      for (var orderId in ordersDynamic.keys) {
        var orderDynamic = ordersDynamic[orderId];
        var orderMap = Map<String, dynamic>.from(orderDynamic);
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

  Future<Stream<List<RequestedOrder>>> getTakenOrdersStream(String userId) async{
      List<String> ordersTakenByUser = await getTakenOrdersById(userId);

      return _databaseReference.child(ORDER_COLLECTION).onValue.map((event) {
        Map<String, dynamic> ordersDynamic = Map<String, dynamic>.from(event.snapshot.value);

        List<RequestedOrder> orders = [];

        for (var userId in ordersDynamic.keys) {
          var ordersOfSingleUser = ordersDynamic[userId];
          Map<String, dynamic> ordersOfSingleUserDynamic = Map<String, dynamic>.from(ordersOfSingleUser[OrderStatuses.Requested]);

          for (var orderId in ordersOfSingleUserDynamic.keys) {
            if(ordersTakenByUser.contains(orderId) == false) continue;
            var orderDynamic = ordersOfSingleUserDynamic[orderId];
            var orderMap = Map<String, dynamic>.from(orderDynamic);
            orders.add(RequestedOrder.fromMap(orderId, userId, orderMap));
          }
        }
      return orders;
    });
  }

  Future<List<String>> getTakenOrdersById(String userId) async{
    DataSnapshot snapshot = await _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatuses.Taken).once();
    Map<String, dynamic> ordersTaken = Map<String, dynamic>.from(snapshot.value);

    List<String> listOrdersId = [];

    for (var ordersDynamic in ordersTaken.values){
      var order = Map<String, dynamic>.from(ordersDynamic);
      listOrdersId.add(order['requestedOrderId']);
    }
    return listOrdersId;
  }

  Future<void> cancelRequestedOrder(String requestedOrderId, String userId) {
    return _databaseReference.child(ORDER_COLLECTION).child(userId)
        .child(OrderStatuses.Requested).child(requestedOrderId)
        .update({"status": OrderStatuses.Cancelled});
  }

  Future<void> finishRequestedOrder(String requestedOrderId, String userId) {
    return _databaseReference.child(ORDER_COLLECTION).child(userId)
        .child(OrderStatuses.Requested).child(requestedOrderId)
        .update({"status": OrderStatuses.Resolved});
  }

  Future<void> setToken(String userId, String token) {
    return _databaseReference.child('users/${userId}/notificationToken/${token}').set({"token": token});
  }

  Future<void> removeToken(String userId, String token) {
    return _databaseReference.child('users/${userId}/notificationToken/${token}').remove();
  }

  Stream<Chat> getChat(String requestedOrderId) {
    return _databaseReference.child(CHAT_COLLECTION).child(requestedOrderId).onValue.map((event) {
      Map<String, dynamic> chatDynamic = Map<String, dynamic>.from(event.snapshot.value);

      List<ChatMessage> chatMessages = [];

      for (var rawMessage in chatDynamic.values) {
        chatMessages.add(ChatMessage.fromMap(rawMessage));
      }

      // !!!! order by dates
      var finalChatMessages = chatMessages.where((cm) => cm.text.length > 0)
          .toList();
      finalChatMessages.sort((cm1, cm2) => cm1.dateTime.compareTo(cm2.dateTime));

      return Chat(finalChatMessages.reversed.toList());
    });
  }

  Future<void> sendMessage(String requestedOrderId, String fromUserId, String text, String dateTime) {

    var message = {
      "userId": fromUserId,
      "text": text,
      "dateTime": dateTime
    };

    return _databaseReference.child(CHAT_COLLECTION).child(requestedOrderId)
        .push().set(message);
  }
}

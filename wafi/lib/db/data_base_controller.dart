import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:wafi/model/chat.dart';
import 'package:wafi/model/classroom.dart';
import 'package:wafi/model/order_status.dart';
import 'dart:async';

import 'package:wafi/model/requested_order.dart';


abstract class DataBaseController {

  Future<void> addRequestedOrder(String userId, String title, String source, String floor, String description, String classroom);

  Future<void> addTakenOrder(String userId, RequestedOrder requestedOrder);

  DatabaseReference getReferenceById(String userId);

  Stream<List<RequestedOrder>> getRequestedOrdersById(String userId);

  Future<void> cancelRequestedOrder(String requestedOrderId, String userId);

    /* TODO: getOrderById, etc */

  Future<List<String>> getFloorsSnapshot();

  Stream<List<RequestedOrder>> getRequestedOrdersStream();

  Stream<List<RequestedOrder>> getTakenOrdersStream(String userId);

  Future<int> getAmountTakenOrderById(String userId);

  Stream<List<String>> getTakenOrdersById(String userId);

  Future<void> setToken(String userId, String token);

  Future<void> removeToken(String userId, String token);

  Stream<Chat> getChat(String requestedOrderId);

  Future<void> sendMessage(String requestedOrderId, String fromUserId, String text, String dateTime);

  Future<String> getUserInfo(String userId);

  Future<void> updateUserName(String userId, String username);
}

class FirebaseController implements DataBaseController {

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  static const ORDER_COLLECTION = "order";
  static const FLOR_COLLECTION = "floor";
  static const CHAT_COLLECTION = "chat";
  static const USER_COLLECTION = "users";


  Future<void> addRequestedOrder(String userId, String title, String source, String floor, String description, String classroom) {

    // this is because of a bug (Rodri)
    var finalTitle = title;
    if (finalTitle == null || finalTitle == "") {
      finalTitle = "d-${Random().nextInt(999)}";
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

    var chatMessagesInit = {"init": {
      "userId": "",
      "text": "",
      "dateTime": DateTime.now().toIso8601String().toString()
    }};

    var chatInit = {
      "requesterUserId": requestedOrder.requesterUserId,
      "takerUserId": userId,
      "messages": chatMessagesInit
    };

    // !!!! transactional
    _databaseReference.child(CHAT_COLLECTION).child(requestedOrder.id)
        .update(chatInit);
    _databaseReference.child(ORDER_COLLECTION).child(requestedOrder.requesterUserId)
        .child(OrderStatuses.Requested).child(requestedOrder.id)
        .update({"status": OrderStatuses.Taken, "takerUserId": userId});
    return _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatuses.Taken).child(requestedOrder.id).set(order);
    // !!!!! return _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatuses.Taken).push().set(order);
  }

  DatabaseReference getReferenceById(String userId) {
    return _databaseReference.child(ORDER_COLLECTION).child(userId);
  }

  Stream<List<RequestedOrder>> getRequestedOrdersById(String userId) {
    Stream<Event> eventS = _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatuses.Requested).onValue;

    return eventS.map((event) {
      if (event.snapshot.value == null) {
        return [];
      }
      Map<String, dynamic> ordersDynamic = Map<String, dynamic>.from(event.snapshot.value);

      List<RequestedOrder> orders = [];

      for (var orderId in ordersDynamic.keys) {
        var orderDynamic = ordersDynamic[orderId];
        var orderMap = Map<String, dynamic>.from(orderDynamic);
        try {
          orders.add(RequestedOrder.fromMap(orderId, userId, orderMap));
        } catch (e) {
          print("ERROR: getRequestedOrdersById. Error parsing RequestedOrder: ${orderMap} | ${e}");
        }
      }

      return orders;
    });
  }

  Future<List<String>> getFloorsSnapshot() async {
    DataSnapshot snapshot = await _databaseReference.child(FLOR_COLLECTION).once();

    List<String> floors = List<String>.from(snapshot.value);

    return floors;
  }

   Stream<List<RequestedOrder>> getRequestedOrdersStream() {

    return _databaseReference.child(ORDER_COLLECTION).onValue.map((event) {

      try {
        if (event.snapshot.value == null) {
          return [];
        }

        Map<String, dynamic> ordersDynamic = Map<String, dynamic>.from(
            event.snapshot.value);

        List<RequestedOrder> orders = [];

        for (var userId in ordersDynamic.keys) {
          var ordersOfSingleUser = ordersDynamic[userId];
          if (ordersOfSingleUser[OrderStatuses.Requested] == null) {
            continue;
          }

          Map<String, dynamic> ordersOfSingleUserDynamic = Map<String,
              dynamic>.from(ordersOfSingleUser[OrderStatuses.Requested]);

          for (var orderId in ordersOfSingleUserDynamic.keys) {
            var orderDynamic = ordersOfSingleUserDynamic[orderId];

            var orderMap = Map<String, dynamic>.from(orderDynamic);

            try {
              orders.add(RequestedOrder.fromMap(orderId, userId, orderMap));
            } catch (e) {
              print("ERROR: getRequestedOrdersStream. Error parsing RequestedOrder: ${orderMap} | ${e}");
            }
          }
        }

        return orders;
      } catch(e) {
        print("ERROR: getRequestedOrdersStream. Error bringing data: $e");
        return [];
      }
    });
  }

  Stream<List<RequestedOrder>> getTakenOrdersStream(String myUserId) {
    Stream<List<String>> ordersTakenByUserS = getTakenOrdersById(myUserId);

    return ordersTakenByUserS.asyncExpand((ordersTakenByUser) {
      return _databaseReference.child(ORDER_COLLECTION).onValue.map((event) {

        if (event.snapshot.value == null) {
          debugPrint("ERROR: No child $ORDER_COLLECTION found for User: $myUserId.");
          return [];
        }

        Map<String, dynamic> ordersDynamic = Map<String, dynamic>.from(event.snapshot.value);

        List<RequestedOrder> orders = [];

        for (var otherUserId in ordersDynamic.keys) {
          var ordersOfSingleUser = ordersDynamic[otherUserId];

          if (ordersOfSingleUser[OrderStatuses.Requested] == null) {
            continue;
          }

          Map<String, dynamic> ordersOfSingleUserDynamic = Map<String, dynamic>.from(ordersOfSingleUser[OrderStatuses.Requested]);

          for (var orderId in ordersOfSingleUserDynamic.keys) {
            if(ordersTakenByUser.contains(orderId) == false) continue;
            var orderDynamic = ordersOfSingleUserDynamic[orderId];
            var orderMap = Map<String, dynamic>.from(orderDynamic);
            try {
              orders.add(RequestedOrder.fromMap(orderId, otherUserId, orderMap));
            } catch (e) {
              print("ERROR: getTakenOrdersStream. Error parsing RequestedOrder: ${orderMap} | ${e}");
            }
          }
        }
        return orders;
      });
    });
  }

  Future<int> getAmountTakenOrderById(String userId) async{
    dynamic takenOrders = await getTakenOrdersStream(userId);
    dynamic orders = takenOrders.map((requestedOrders) => requestedOrders
        .where((ro) => ro.status == OrderStatuses.Resolved)
        .toList());
    //print(orders.key);
    return orders.length;
  }

  Stream<List<String>> getTakenOrdersById(String userId) {
    DatabaseReference dbReference = _databaseReference.child(ORDER_COLLECTION).child(userId).child(OrderStatuses.Taken);

    return dbReference.onValue.map((event) {
      var snapshot = event.snapshot;

      if (snapshot.value == null) {
        debugPrint("ERROR: Not found taken orders by User: $userId");
        return [];
      }

      Map<String, dynamic> ordersTaken = Map<String, dynamic>.from(snapshot.value);

      List<String> listOrdersId = [];

      for (var ordersDynamic in ordersTaken.values){
        try {
          var order = Map<String, dynamic>.from(ordersDynamic);
          listOrdersId.add(order['requestedOrderId']);
        } catch (e) {
          print("ERROR: getTakenOrdersById. Error parsing map: ${ordersDynamic} | ${e}");
        }
      }
      return listOrdersId;
    });
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

      for (var rawMessage in chatDynamic["messages"].values) {
        chatMessages.add(ChatMessage.fromMap(rawMessage));
      }

      // !!!! order by dates
      var finalChatMessages = chatMessages.where((cm) => cm.text.length > 0)
          .toList();
      finalChatMessages.sort((cm1, cm2) => cm1.dateTime.compareTo(cm2.dateTime));

      return Chat(chatDynamic["requesterUserId"], chatDynamic["takerUserId"],
          finalChatMessages.reversed.toList());
    });
  }

  Future<void> setUserName(String userId, String username){
    return _databaseReference.child('users/${userId}/info').set({"username": username});
  }

  Future<void> updateUserName(String userId, String username){
    return _databaseReference.child('users/${userId}/info').update({"username": username});
  }

  Future<String> getUserInfo(String userId) async{
    DataSnapshot snapshot = await _databaseReference.child(USER_COLLECTION).child(userId).child("info").once();
    if (snapshot.value == null) {
      setUserName(userId, 'Tortuga'); //Default Name
      return 'Tortuga';
    }
    return snapshot.value['username'].toString();
  }

  Future<void> sendMessage(String requestedOrderId, String fromUserId, String text, String dateTime) {

    var message = {
      "userId": fromUserId,
      "text": text,
      "dateTime": dateTime
    };

    return _databaseReference.child(CHAT_COLLECTION).child(requestedOrderId).child("messages")
        .push().set(message);
  }
}

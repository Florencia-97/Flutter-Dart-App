import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

abstract class DataBaseController {
  Future<void> addOrder(String userId, String title, String type, String description, int classroom);

  DatabaseReference getReferenceById(String userId);

  /* TODO: Add getOrders, getOrderById, etc */
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

    return _databaseReference.child('pedidos').child(userId).push().set(order);
  }

  DatabaseReference getReferenceById(String userId) {
    return _databaseReference.child('pedidos').child(userId);
  }
}

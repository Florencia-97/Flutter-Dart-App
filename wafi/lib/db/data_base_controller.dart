import 'package:firebase_database/firebase_database.dart';
import 'dart:async';


abstract class DataBaseController {
  Future<void> addOrder(String userId, String title, String type, String description, int classroom);

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
}

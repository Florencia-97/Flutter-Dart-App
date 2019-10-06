import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RequestedOrder {

    final String id;
    final String requesterUserId;
    final String title;
    final String source;
    final String floor;
    final int classroom;
    final String description;
    final String status;

    /*
    RequestedOrder(this.id, this.requestUserId, this.title, this.source, this.floor, this.classroom,
        this.description, this.status);
     */

    /*
    RequestedOrder.fromSnapshot(String id, String requestUserId, DataSnapshot snapshot)
        : title = snapshot.value['title'],
            source = snapshot.value['source'],
            floor = snapshot.value['floor'].toString(),
            classroom = snapshot.value['classroom'],
            description = snapshot.value['description'];
*/

    RequestedOrder.fromMap(String id, String requestUserId, dynamic obj):
        this.id = id,
        this.requesterUserId = requestUserId,
        title = obj['title'],
        source = obj['source'],
        floor = obj['floor'],
        classroom = obj['classroom'],
        description = obj['description'],
        status = obj['status'];


    @override
    String toString({ DiagnosticLevel minLevel = DiagnosticLevel.debug }) {
        return "OrderItem(title: $title)";
    }
}


class OrderSources {

    static const String Photocopier = "photocopier";
    static const String Kiosk = "kiosk";
    static const String Buffet = "buffet";

    static const List<String> validSources = [Photocopier, Kiosk, Buffet];

    static get values => validSources;
}
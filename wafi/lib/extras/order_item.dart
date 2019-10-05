import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RequestedOrder extends StatelessWidget {

    final String id;
    final String requestUserId;
    final String title;
    final String source;
    final String floor;
    final int classroom;
    final String description;

    RequestedOrder(this.id, this.requestUserId, this.title, this.source, this.floor, this.classroom,
        this.description);

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
        this.requestUserId = requestUserId,
        title = obj['title'],
        source = obj['source'],
        floor = obj['floor'],
        classroom = obj['classroom'],
        description = obj['description'];


    @override
    String toString({ DiagnosticLevel minLevel = DiagnosticLevel.debug }) {
        return "OrderItem(title: $title)";
    }

    @override
    Widget build(BuildContext context) {
        return ListTile(
            title: new Text(title),
            subtitle: new Text(source),
            leading: source == 'Fotocopiadora' ? Icon(Icons.print) : Icon(
                Icons.fastfood),
            onTap: () {}
        );
    }
}
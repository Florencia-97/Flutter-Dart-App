import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OrderItem extends StatelessWidget {
    final String title;
    final String type;
    final String description;
    final int classroom;

    OrderItem(this.title, this.type, this.description, this.classroom);

    OrderItem.fromSnapshot(DataSnapshot snapshot)
      : title = snapshot.value['titulo'],
        type = snapshot.value['type'],
        description = snapshot.value['descripcion'],
        classroom = snapshot.value['aula'];

    OrderItem.fromMap(dynamic obj)
        : title = obj['titulo'],
            type = obj['type'],
            description = obj['descripcion'],
            classroom = obj['aula'];

    @override
    String toString({ DiagnosticLevel minLevel = DiagnosticLevel.debug }) {
        return "OrderItem(title: $title)";
    }

    @override
    Widget build(BuildContext context) {
      return ListTile(
        title: new Text(title),
        subtitle: new Text(type),
        leading: type == 'Fotocopiadora' ? Icon(Icons.print) : Icon(Icons.fastfood),
        onTap: (){}
      );
    }
}
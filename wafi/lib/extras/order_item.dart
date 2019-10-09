import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RequestedOrder {

    final String id;
    final String requesterUserId;
    final String requestedUserId;
    final String title;
    final OrderSource source;
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

    RequestedOrder.fromMap(String id, String requestUserId, dynamic obj,[String requestedUserId]):
        this.id = id,
        this.requesterUserId = requestUserId,
        this.requestedUserId = requestedUserId,
        title = obj['title'],
        source = OrderSource.fromName(obj['source']),
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

    static const OrderSource Photocopier = OrderSource("photocopier", "Fotocopiadora", Icons.print);
    static const OrderSource Kiosk = OrderSource("kiosk", "Kiosko", Icons.fastfood);
    static const OrderSource Buffet = OrderSource("buffet", "Comedor", Icons.fastfood);

    static const List<OrderSource> validSources = [Photocopier, Kiosk, Buffet];

    static get values => validSources;
}

class OrderSource {

    final String name;
    final String viewName;
    final IconData icon;

    const OrderSource(this.name, this.viewName, this.icon);


    static OrderSource fromName(String name) {
        var orderSourceAsList = OrderSources.validSources
            .where((validOrderSource) => validOrderSource.name == name)
            .toList();

        if (orderSourceAsList.isEmpty) {
            // This is here because of change of names.
            return OrderSource("deprecated", "$name (!!!!)", Icons.android);
        } else {
            return orderSourceAsList[0];
        }




        switch (name) {
            case "photocopier":
                return OrderSources.Photocopier;
            case "kiosk":
                return OrderSources.Kiosk;
            case "buffet":
                return OrderSources.Buffet;
            default:
                // This is here because of change of names.
                return OrderSource("deprecated", "$name (!!!!)", Icons.android);
        }
    }
}
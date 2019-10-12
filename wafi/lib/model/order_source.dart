import 'package:flutter/material.dart';

class OrderSources {

  static const OrderSource Photocopier = OrderSource("photocopier", "Fotocopiadora", Icons.print, 'assets/copy.png');
  static const OrderSource Kiosk = OrderSource("kiosk", "Kiosko", Icons.fastfood, 'assets/coffe.png');
  static const OrderSource Buffet = OrderSource("buffet", "Comedor", Icons.fastfood, 'assets/burger.png');

  static const List<OrderSource> validSources = [Photocopier, Kiosk, Buffet];

  static get values => validSources;
}

class OrderSource {

  final String name;
  final String viewName;
  final IconData icon;
  final String image;

  const OrderSource(this.name, this.viewName, this.icon, this.image);


  static OrderSource fromName(String name) {
    var orderSourceAsList = OrderSources.validSources
        .where((validOrderSource) => validOrderSource.name == name)
        .toList();

    if (orderSourceAsList.isEmpty) {
      // This is here because of change of names.
      return OrderSource("deprecated", "$name (!!!!)", Icons.android, 'none');
    } else {
      return orderSourceAsList[0];
    }
  }
}
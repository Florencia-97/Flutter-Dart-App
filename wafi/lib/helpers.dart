
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'extras/order_item.dart';

Icon getOrderSourceIcon(RequestedOrder requestedOrder) {
  return Icon(requestedOrder.source.icon); requestedOrder.source == OrderSources.Photocopier ? Icon(Icons.print) : Icon(Icons.fastfood);
}
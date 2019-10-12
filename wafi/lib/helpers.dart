
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model/order_source.dart';
import 'model/requested_order.dart';

Icon getOrderSourceIcon(RequestedOrder requestedOrder) {
  return Icon(requestedOrder.source.icon); requestedOrder.source == OrderSources.Photocopier ? Icon(Icons.print) : Icon(Icons.fastfood);
}
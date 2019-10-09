import 'package:flutter/material.dart';
import 'package:wafi/extras/taken_list.dart';

class MyTakenOrders extends StatefulWidget {
  final String userId;

  MyTakenOrders(this.userId);

  @override
  State createState() => _MyTakenOrders();
}


class _MyTakenOrders extends State<MyTakenOrders> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pedidos Tomados'),
        ),
        body: 
            TakenList(widget.userId),
    );
  }
}
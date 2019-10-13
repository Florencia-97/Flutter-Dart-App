import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/order_list.dart';
import 'package:wafi/model/order_status.dart';

class MyOrders extends StatefulWidget {
  MyOrders(this.userId);

  final String userId;

  @override
  State createState() => _MyOrders();
}


class _MyOrders extends State<MyOrders> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "En espera"),
              Tab(text: "En cursos")
            ],
          ),
          title: Text('Mis Pedidos'),
        ),
        body: TabBarView(
          children: [
            OrderList(widget.userId, (ro) => ro.status == OrderStatuses.Requested, false),
            OrderList(widget.userId, (ro) => ro.status == OrderStatuses.Taken, true),
          ],
        ),
      ),
    );
  }
}
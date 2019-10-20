import 'package:flutter/material.dart';
import 'package:wafi/extras/order_list.dart';
import 'package:wafi/model/order_status.dart';

class MyOrders extends StatefulWidget {
  MyOrders(this.userId, {this.selectedTab = 0});

  final String userId;
  final selectedTab;

  @override
  State createState() => _MyOrders();
}


class _MyOrders extends State<MyOrders> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.selectedTab,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "En espera"),
              Tab(text: "En curso")
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
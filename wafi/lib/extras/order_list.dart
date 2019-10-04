import 'package:flutter/material.dart';
import 'package:wafi/extras/order_item.dart';

class OrderList extends StatefulWidget {
  OrderList(this._orders);

  final List<RequestedOrder> _orders;

  @override
  State createState() => _OrderList();
}


class _OrderList extends State<OrderList> {

  Widget _buildOrders() {
    return ListView.separated(
      itemCount: widget._orders.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        return  widget._orders[i];
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Pedidos'),
      ),
      body: _buildOrders(),
    );
  }
}
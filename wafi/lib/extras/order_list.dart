import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/order_item.dart';

class OrderList extends StatefulWidget {
  OrderList(this.userId);

  // final Stream<List<RequestedOrder>> _requestedOrdersS;
  final String userId;

  @override
  State createState() => _OrderList();
}


class _OrderList extends State<OrderList> {

  @override
  void initState() {
    // widget._requestedOrdersS.listen((data) => print("\n\n\n\n\n !!!! \n\n\n ${data}\n\n\n\n\n"));
  }

  Widget _buildOrders(List<RequestedOrder> orders) {
    return ListView.separated(
      itemCount: orders.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        return  orders[i];
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
      body: StreamBuilder(
          stream: FirebaseController().getRequestedOrdersById(widget.userId).map((requestedOrders) => requestedOrders.where((ro) => ro.status != OrderStatus.Cancelled).toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("No data yet !!!!");
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Text("Done !!!!");
            } else if (snapshot.hasError) {
              return Text("Error !!!!");
            } else {
              var requestedOrders = snapshot.data;
              return _buildOrders(requestedOrders);
            }
        }
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/order_item.dart';
import 'package:wafi/login/authentification.dart';

class TakenList extends StatefulWidget {
  TakenList(this.userId);

  final String userId;
  final Auth auth = Auth();
  final FirebaseController db = FirebaseController();

  @override
  State createState() => _TakenList();
}

class _TakenList extends State<TakenList> {

  Widget _ordersTakenToWidget(RequestedOrder requestedOrder) {
    return TakenOrderFromOrderList(requestedOrder);
  }

  Widget _buildOrdersTaken(List<RequestedOrder> orders) {
    return ListView.separated(
      itemCount: orders.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        return  _ordersTakenToWidget(orders[i]);
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      );
  }

  FutureBuilder _myOrders(){
    return FutureBuilder(
      future: widget.db.getTakenOrdersStream(widget.userId),
      builder: (contex, snapshotFuture) {
        if (snapshotFuture.hasData) {
            Stream<List<RequestedOrder>> requestedOdersS = snapshotFuture.data;
            return StreamBuilder(
              stream: requestedOdersS,
              builder: (context, snapshotStream) {
              if (snapshotStream.hasData) {
                List<RequestedOrder> requestedOrders = snapshotStream.data;
                return _buildOrdersTaken(requestedOrders);
              } 
                  return Text('No elements');
              }
            );
        } else { // Modifie
            return ListTile(
              leading: Text(
                0.toString()),
                title: Text('Nada'),
                onTap: null,
                );
          }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _myOrders()
    );
  }
}

class TakenOrderFromOrderList extends StatelessWidget {

  final RequestedOrder takenOrder;

  TakenOrderFromOrderList(this.takenOrder);

  Icon _getOrderSourceIcon(RequestedOrder requestedOrder) {
    return Icon(requestedOrder.source.icon);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
              child: ListTile(
                  title: new Text(takenOrder.title),
                  subtitle: new Text(takenOrder.source.viewName),
                  leading: _getOrderSourceIcon(takenOrder),
                  onTap: () {} //Nothing here yes!
              )
          ),
        ]
    );
  }
}

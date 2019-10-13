import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/order_list.dart';
import 'package:wafi/extras/thanks_screen.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/model/order_status.dart';
import 'package:wafi/model/requested_order.dart';
import 'package:wafi/pages/chat_page.dart';

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
    return TakenOrderFromOrderList(widget.userId, requestedOrder, widget.db);
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

  Future<Stream<List<RequestedOrder>>> _getOrdersTaken() async {
    var takenOrders =  await widget.db.getTakenOrdersStream(widget.userId);
    return takenOrders.map((requestedOrders) => requestedOrders
      .where((ro) => ro.status != OrderStatuses.Cancelled)
      .where((ro) => ro.status != OrderStatuses.Resolved)
      .toList());
  }

  FutureBuilder _myOrders(){
    return FutureBuilder(
      future: _getOrdersTaken(),
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

// !!!!! add the orderlisttile
class TakenOrderFromOrderList extends StatelessWidget {

  final String userId;
  final RequestedOrder takenOrder;
  final FirebaseController db;


  TakenOrderFromOrderList(this.userId, this.takenOrder,
      this.db);


  Icon _getOrderSourceIcon(RequestedOrder requestedOrder) {
    return Icon(requestedOrder.source.icon);
  }

  void _showOrderAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Finalizar Pedido"),
          content: new Text("Estás afuera? avisale por acá para finalizar el pedido"),
          actions: <Widget>[
            Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text('CANCELAR',
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.black38)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('AFUERA',
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.black)),
                      onPressed: () async {
                        db.finishRequestedOrder(takenOrder.id, takenOrder.requesterUserId);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ThanksScreen()));
                      },
                    ),
                  ],
                )
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrderListTile(takenOrder, () => null,
        true, () => _showOrderAlertDialog(context),
        true, () => () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(takenOrder.id, userId))),
            () => null); // !!!!! add cancel button functionality
  }
}

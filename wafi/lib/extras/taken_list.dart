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
    Future<void> Function(String requestedOrderId, String userId) onCancelled = widget.db.cancelRequestedOrder;
    return TakenOrderFromOrderList(widget.userId, requestedOrder, widget.db, onCancelled);
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

   Widget _noOrdersTaken(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.account_balance,
            size: 100.0,),
          Padding(padding: EdgeInsets.only(top: 40.0)),
          Text('No has tomado ningún pedido',
            style: TextStyle(
              fontSize: 18),
          ),
        ],)
    );
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
                  return requestedOrders.length > 0 ? _buildOrdersTaken(requestedOrders) : _noOrdersTaken() ;
                } 
              }
            );
        }
        return _noOrdersTaken();
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
  final Future<void> Function(String requestedOrderId, String userId) onCancelled;


  TakenOrderFromOrderList(this.userId, this.takenOrder,
      this.db, this.onCancelled);


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

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seguro?"),
          content: new Text("De aceptar se cancelará el pedido !!!!."), // !!!! este es del otro lado, otro texto?
          actions: <Widget>[
            Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text('NO',
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.black38)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                        child: Text('SÍ',
                            style: TextStyle(
                                fontSize: 16.0, color: Colors.black)),
                        onPressed: () async {
                          await onCancelled(takenOrder.id, takenOrder.requesterUserId);
                          Navigator.pop(context);
                        }
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
        true, () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(userId, takenOrder))),
            () => _showCancelDialog(context));
  }
}

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/model/order_source.dart';
import 'package:wafi/model/order_status.dart';
import 'package:wafi/model/requested_order.dart';
import 'package:wafi/pages/chat_page.dart';

class OrderList extends StatefulWidget {

  // !!!! remove this o try it again later
  // final Stream<List<RequestedOrder>> _requestedOrdersS;
  final String userId;
  final filterCondition;
  final bool enableChats;

  OrderList(this.userId, this.filterCondition, this.enableChats);

  final Auth auth = Auth();
  final FirebaseController db = FirebaseController();

  @override
  State createState() => _OrderList();
}


class _OrderList extends State<OrderList> {

  Widget _requestedOrderToWidget(RequestedOrder requestedOrder) {

    Future<void> Function(String requestedOrderId, String userId) onCancelled = widget.db.cancelRequestedOrder;

    return RequestedOrderFromOrderList(widget.userId, requestedOrder,
        widget.enableChats, onCancelled);
  }

  Widget _buildOrders(List<RequestedOrder> orders) {
    return ListView.separated(
      itemCount: orders.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, i) {
        return  _requestedOrderToWidget(orders[i]);
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseController()
          .getRequestedOrdersById(widget.userId)
          .map((requestedOrders) => requestedOrders
          .where((ro) => ro.status != OrderStatuses.Cancelled)
          .where((ro) => widget.filterCondition(ro)).toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SpinKitDoubleBounce (
                  color: Colors.red[200],
                  size: 50.0,
                );
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

class RequestedOrderFromOrderList extends StatelessWidget {

  final String userId;
  final RequestedOrder requestedOrder;
  final bool enableChat;
  final Future<void> Function(String requestedOrderId, String userId) onCancelled;

  RequestedOrderFromOrderList(this.userId, this.requestedOrder,
      this.enableChat, this.onCancelled);


  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seguro?"),
          content: new Text("De aceptar se cancelará el pedido."),
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
                        await onCancelled(requestedOrder.id, requestedOrder.requesterUserId);
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

  void _onTap(BuildContext context, RequestedOrder requestedOrder) {
    switch (requestedOrder.status) {
      case OrderStatuses.Taken:
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(userId, requestedOrder)));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrderListTile(requestedOrder, () => _onTap(context, requestedOrder),
        false, () => null,
        enableChat, () => _onTap(context, requestedOrder),
        () => _showCancelDialog(context));
  }
}


class OrderListTile extends StatelessWidget {

  final RequestedOrder requestedOrder;

  final VoidCallback onTilePressed;
  final bool enableAlert;
  final VoidCallback onAlertButtonPressed;
  final bool enableChat;
  final VoidCallback onChatButtonPressed;
  final VoidCallback onCancelledButtonPressed;

  OrderListTile(this.requestedOrder, this.onTilePressed, this.enableAlert,
      this.onAlertButtonPressed, this.enableChat, this.onChatButtonPressed,
      this.onCancelledButtonPressed);


  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
              child: ListTile(
                  title: new Text(requestedOrder.title),
                  subtitle: new Text("${requestedOrder.source.viewName}\n${requestedOrder.classroom}"),
                  leading: Icon(requestedOrder.source.icon),
                  onTap: onTilePressed
              )
          ),
          Visibility(
            visible: enableAlert,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: Container(
              child: IconButton(
                icon: Icon(Icons.add_alert,
                  color: Colors.blueGrey,
                ),
                onPressed: onAlertButtonPressed, // !!!!
              ),
            ),
          ),
          Visibility(
            visible: enableChat,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: Container(
              child: IconButton(
                icon: Icon(Icons.chat,
                  color: Colors.blueGrey,
                ),
                onPressed: onChatButtonPressed, // !!!!
              ),
            ),
          ),
          Visibility(
            visible: true,
            maintainState: true,
            maintainAnimation: true,
            maintainSize: true,
            child: Container(
              child: IconButton(
                icon: Icon(Icons.cancel,
                  color: Colors.blueGrey,
                ),
                onPressed: onCancelledButtonPressed, // !!!!
              ),
            ),
          ),

        ]
    );
  }
}

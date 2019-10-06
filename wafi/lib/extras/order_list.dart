import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/order_item.dart';
import 'package:wafi/login/authentification.dart';

class OrderList extends StatefulWidget {
  OrderList(this.userId);

  // !!!! remove this
  // final Stream<List<RequestedOrder>> _requestedOrdersS;
  final String userId;
  final Auth auth = Auth();
  final FirebaseController db = FirebaseController();

  @override
  State createState() => _OrderList();
}


class _OrderList extends State<OrderList> {

  Widget _requestedOrderToWidget(RequestedOrder requestedOrder) {

    Future<void> Function(String requestedOrderId, String userId) onCancelled = widget.db.cancelRequestedOrder;

    return RequestedOrderFromOrderList(requestedOrder, onCancelled);
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
      appBar: AppBar(
        title: Text('Mis Pedidos'),
      ),
      body: StreamBuilder(
          stream: FirebaseController().getRequestedOrdersById(widget.userId).map((requestedOrders) => requestedOrders.where((ro) => ro.status != OrderStatuses.Cancelled).toList()),
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

class RequestedOrderFromOrderList extends StatelessWidget {

  final RequestedOrder requestedOrder;
  final Future<void> Function(String requestedOrderId, String userId) onCancelled;


  RequestedOrderFromOrderList(this.requestedOrder, this.onCancelled);

  void _showDialog(BuildContext context) {
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

  Icon _getOrderSourceIcon(RequestedOrder requestedOrder) {
    return requestedOrder.source == OrderSources.Photocopier ? Icon(Icons.print) : Icon(Icons.fastfood);
  }

  String _sourceToView(String orderSource){
    switch (orderSource){
      case OrderSources.Photocopier:
        return "Fotocopiadora";
      case OrderSources.Buffet:
        return "Comedor";
      case OrderSources.Kiosk:
        return "Kiosko";
      default:
        return "$orderSource (!!!!)";
    }
  }


  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
              child: ListTile(
                  title: new Text(requestedOrder.title),
                  subtitle: new Text(_sourceToView(requestedOrder.source)),
                  leading: _getOrderSourceIcon(requestedOrder),
                  onTap: () {}
              )
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.cancel,
                color: Colors.blueGrey,
              ),
              onPressed: () => _showDialog(context), // !!!!
            ),
          ),
        ]
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/order_item.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
    return RequestedOrderFromOrderList(requestedOrder);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseController()
          .getRequestedOrdersStream()
          .map((requestedOrders) => requestedOrders
          .where((ro) => ro.status == OrderStatuses.Taken)
          .where((ro) => ro.requesterUserId == widget.userId)
          .toList()),
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
              return _buildOrdersTaken(requestedOrders);
            }
        }
      ),
    );
  }
}

class RequestedOrderFromOrderList extends StatelessWidget {

  final RequestedOrder requestedOrder;

  RequestedOrderFromOrderList(this.requestedOrder);

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
                  title: new Text(requestedOrder.title),
                  subtitle: new Text(requestedOrder.source.viewName),
                  leading: _getOrderSourceIcon(requestedOrder),
                  onTap: () {}
              )
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.cancel,
                color: Colors.blueGrey,
              ),
              onPressed: () => null,
            ),
          ),
        ]
    );
  }
}

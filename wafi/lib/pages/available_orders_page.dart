import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/wafi_drawer.dart';
import 'package:wafi/login/authentification.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wafi/helpers.dart';
import 'package:wafi/model/order_status.dart';
import 'package:wafi/model/requested_order.dart';

class AvailableOrdersPage extends StatefulWidget {
  AvailableOrdersPage({this.auth, this.onLoggedOut});

  final Auth auth;
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();

  @override
  State<StatefulWidget> createState() =>  _AvailableOrdersPageState();
}

class _AvailableOrdersPageState extends State<AvailableOrdersPage> {

  Text _createText(String text){
    return Text(text,
      style: TextStyle(
        fontSize: 18, 
      ),
    );
  }

  void _acceptOrder(RequestedOrder order){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pedido de ${order.source.viewName}',
                    style: TextStyle(fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
                _createText('Compra: ${order.title}'),
                _createText('Aula: ${order.classroom}'),
                _createText('Descripción: ${order.description}'),
            ],
          ),
          actions: <Widget>[
            Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text('IGNORAR',
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.black38)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('TOMAR',
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.black)),
                      onPressed: () async {
                        var user = await widget.auth.getCurrentUser();
                        widget.db.addTakenOrder(user.uid, order);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                )
            )
          ],
        );
      }
    );
  }

  Widget _buildAvailableOrder(RequestedOrder order) {
    return ButtonOrder (order, () { _acceptOrder(order);});
  }

  Widget _noOrdersAvailable(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.query_builder,
            size: 100.0,),
          Padding(padding: EdgeInsets.only(top: 40.0)),
          Text('Sin pedidos para tomar',
            style: TextStyle(
              fontSize: 18),
          ),
        ],)
    );
  }

  List<Widget> _buildAvailableOrders(List<RequestedOrder> orders) {

    return orders.where((order) => order.status == OrderStatuses.Requested)
        .map(_buildAvailableOrder).toList();
  }

  Widget _doBuildDisplay(String userId, List<RequestedOrder> orders) {

    var requestedOrders = orders
        .where((order) => order.status == OrderStatuses.Requested)
        .where((order) => order.requesterUserId != userId)
        .toList();

    var title = Container(
        margin: EdgeInsets.all(20),
        child: Text(
          "Elige qué pedido tomar:",
          style: TextStyle(
              fontSize: 20
          ),
        )
    );

    var availableOrders = _buildAvailableOrders(requestedOrders);

    List<Widget> finalList = [title];
    finalList.addAll(availableOrders);

    // The title was above the first request.
    finalList = availableOrders;

    if (finalList.length == 0) return _noOrdersAvailable();

    return Center(
        child: ListView.separated(
          itemCount: requestedOrders.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, i) {
            return finalList[i];
          },
          separatorBuilder: (BuildContext context, int index) => const SizedBox.shrink(),
        )
    );
  }

  Widget _buildDisplay(List<RequestedOrder> orders) {

    Future<String> userIdF = widget.auth.getCurrentUser().then((user) => user.uid);

    return FutureBuilder(
        future: userIdF,
        builder: (context, snapshot) {
          return _doBuildDisplay(snapshot.data, orders);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Tomar pedido'),
        ),
        body: StreamBuilder(
          stream: widget.db.getRequestedOrdersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SpinKitDoubleBounce (
                  color: Colors.red[200],
                  size: 50.0,
                );
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Text("Done !!!!");
            } else if (snapshot.hasError) {
              return Text("Error !!!!: ${snapshot.error}");
            } else {
              var orders = snapshot.data;
              return _buildDisplay(orders);
            }
          },
        ),
      endDrawer: DrawerWafi(onLoggedOut: widget.onLoggedOut),
    );
  }
}

class ButtonOrder extends StatelessWidget {
  final RequestedOrder order;
  final Function onPressedButton;

  ButtonOrder(this.order, this.onPressedButton);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 250.0,
      child: RaisedButton(
        color: Colors.white,
        onPressed: onPressedButton,
        child: ListTile(
            title: Text(order.title),
            subtitle: Text("${order.source.viewName} -> ${order.classroom}"),
            leading: getOrderSourceIcon(order),
            )
      ),
    );
  }
}
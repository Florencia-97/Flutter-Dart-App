import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/order_item.dart';
import 'package:wafi/extras/wafi_drawer.dart';
import 'package:wafi/login/authentification.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wafi/helpers.dart';

class AvailableOrdersPage extends StatefulWidget {
  AvailableOrdersPage({this.auth, this.onLoggedOut});

  final Auth auth;
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();

  @override
  State<StatefulWidget> createState() =>  _AvailableOrdersPageState();
}

class _AvailableOrdersPageState extends State<AvailableOrdersPage> {

  Widget _buildAvailableOrder(RequestedOrder order) {
    return ButtonOrder (order, () async {
      var user = await widget.auth.getCurrentUser();
      widget.db.addTakenOrder(user.uid, order);
    });
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

    print("\n\n\n ${finalList.length}");


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
              return Text("Error !!!!");
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
                  title: new Text(order.title),
                  subtitle: new Text(order.source.viewName),
                  leading: getOrderSourceIcon(order),
              )
      ),
    );
  }
}

class OrderItemsFetcher {

}
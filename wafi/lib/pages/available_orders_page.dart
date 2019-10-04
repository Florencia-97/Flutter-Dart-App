import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/bar_app.dart';
import 'package:wafi/extras/order_item.dart';
import 'package:wafi/extras/wafi_drawer.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/pages/main_menu.dart';

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

    final text = "${order.source} => ${order.classroom}";
    return ButtonOrder(text, () => null);
  }

  List<Widget> _buildAvailableOrders(List<RequestedOrder> orders) {

    return orders.map(_buildAvailableOrder).toList();
  }

  Widget _buildDisplay(List<RequestedOrder> orders) {
    var title = Container(
        margin: EdgeInsets.all(20),
        child: Text(
          "Elige qué pedido tomar:",
          style: TextStyle(
              fontSize: 20
          ),
        )
    );
    var availableOrders = _buildAvailableOrders(orders);

    List<Widget> finalList = [title];
    finalList.addAll(availableOrders);

    return Center(
        child: ListView.separated(
          itemCount: orders.length,
          padding: const EdgeInsets.all(16.0),
          itemBuilder: (context, i) {
            return finalList[i];
          },
          separatorBuilder: (BuildContext context,
              int index) => const SizedBox.shrink(),
        )
    );

    return Center(
        child: Column(
          children: finalList,
        )
    );
  }

  Stream<List<RequestedOrder>> _ordersFromAllUsers() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BarWafi(),
        body: StreamBuilder(
          stream: widget.db.getRequestedOrdersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("No data yet");
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Text("Done");
            } else if (snapshot.hasError) {
              return Text("Error");
            } else {
              var x = snapshot.data;
              print(x);
              return _buildDisplay(x);
              // return Text("snaphot: ${x.title} + ${x.classroom} + ${x.type}");
            }
          },
        ),
        /*Center(
          child: Column(s
              children: _buildDisplay(),
          )
        ),*/
      endDrawer: DrawerWafi(onLoggedOut: widget.onLoggedOut),
    );
  }
}

class ButtonOrder extends StatelessWidget {
  final String text;
  final Function onPressedButton;

  ButtonOrder(this.text, this.onPressedButton);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 250.0,
      child: RaisedButton(
        color: Colors.white,
        onPressed: onPressedButton,
        child: Text(text),
      ),
    );
  }
}

class OrderItemsFetcher {

}
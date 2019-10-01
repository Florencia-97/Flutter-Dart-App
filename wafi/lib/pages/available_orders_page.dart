import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/bar_app.dart';
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

  List<Widget> _buildAvailableOrders() {
    var x = new List<int>.generate(8, (i) => i + 1);

    var y = x.map((value) {
      return ButtonOrder(value.toString(), () => null);
    }).toList();

    return y;
  }

  List<Widget> _buildDisplay() {
    var title = Container(
      margin: EdgeInsets.all(20),
      child: Text(
        "Elige qué pedido tomar:",
        style: TextStyle(
          fontSize: 20
        ),
      )
    );
    var availableOrders = _buildAvailableOrders();

    List<Widget> finalList = [title];
    finalList.addAll(availableOrders);

    return finalList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BarWafi(),
        body: Center(
          child: Column(
              children: _buildDisplay(),
          )
        ),
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
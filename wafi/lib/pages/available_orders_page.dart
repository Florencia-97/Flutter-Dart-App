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

  int _n;

  @override
  void initState() {
    super.initState();
    setState(() {
      _n = new Random().nextInt(100);
    });
  }

  List<Widget> _buildAvailableOrders() {
    var x = new List<int>.generate(10, (i) => i + 1);

    var y = x.map((value) {
      return ButtonMenu(value.toString(), () => null);
    }).toList();

    return y;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BarWafi(),
        body: Center(
          child: Column(
              children: _buildAvailableOrders(),
          )
        ),
      endDrawer: DrawerWafi(onLoggedOut: widget.onLoggedOut),
    );
  }
}
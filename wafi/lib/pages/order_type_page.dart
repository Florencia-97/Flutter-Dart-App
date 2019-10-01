
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/bar_app.dart';
import 'package:wafi/extras/wafi_drawer.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/pages/order_form_page.dart';

class OrderTypePage extends StatefulWidget {
  OrderTypePage({this.onLoggedOut});

  final Auth auth = Auth();
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();

  @override
  State<StatefulWidget> createState() =>  _OrderTypePageState();
}

class _OrderTypePageState extends State<OrderTypePage> {
  final _typeOptions = ['Comedor', 'Fotocopiadora', 'Kiosco'];

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        // !!!!
      });
    });
  }

  List<Widget> _showTypeButtons() {

    return _typeOptions.map((type) => _showTypeButton(type)).toList();
  }

  Widget _showTypeButton(String type) {
    return Container(
        // color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20), //EdgeInsets.fromLTRB(20.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 60.0,
          child: RaisedButton(
            elevation: 5.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            color: Colors.white,
            child: Text(type,
                style: TextStyle(fontSize: 20.0, color: Colors.blueGrey)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage(
              type: type,
              onLoggedOut: widget.onLoggedOut))),
          ),
        ));
  }

  Widget _showBody(){
    return Container(
        padding: EdgeInsets.fromLTRB(16, 80, 16, 0),
        child: Form(
          child: ListView(
            shrinkWrap: true,
            children: _showTypeButtons(),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarWafi(),
      body: Stack(
        children: <Widget>[
          _showBody(),
        ],
      ),
      endDrawer: DrawerWafi(
          onLoggedOut: widget.onLoggedOut
      ),
    );
  }
}
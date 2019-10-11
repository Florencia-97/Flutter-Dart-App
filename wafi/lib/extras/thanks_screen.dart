import 'package:flutter/material.dart';
import 'package:wafi/login/authentification.dart';

import 'package:wafi/pages/my_taken_orders_page.dart';

class ThanksScreen extends StatefulWidget {

  final Auth auth = Auth();

  @override
  _ThanksScreenState createState() => _ThanksScreenState();
}

class _ThanksScreenState extends State<ThanksScreen>{

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: Color(0xFFF4B12B),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 35.0, bottom: 20.0),
                child: Text(
                  'Se notificó que estas afuera,\nGracias por traer este pedido!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: Colors.white),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  widget.auth.getCurrentUser().then((user) {
                    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyTakenOrders(user.uid)));
                  });
                }, // !!!!Navigator.push(context, MaterialPageRoute(builder: (context) => MainMenuPage())),
                child: Container(
                  padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 10.0, bottom: 10.0),
                  child: Text('Pedidos tomados',
                    style: TextStyle(fontSize: 22, color: Colors.teal),
                  ),
                ),
                color: Colors.white,
              )
            ],
          ),
        ),
      );
    }
}
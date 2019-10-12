// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wafi/extras/bar_app.dart';
import 'package:wafi/extras/wafi_drawer.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/pages/available_orders_page.dart';

import 'order_source_page.dart';

class ButtonMenu extends StatelessWidget {
    final String text;
    final Function onPressedButton;

    ButtonMenu(this.text, this.onPressedButton);

    @override
    Widget build(BuildContext context) {
        return RaisedButton(
            onPressed: () {onPressedButton();},
            child: Padding(
              padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 10.0, bottom: 10.0),
              child: Text(text,
              style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
            color: Colors.teal,
        );
    }
}

class MainMenuPage extends StatefulWidget {
  MainMenuPage({this.auth, this.onLoggedOut});

  final Auth auth;
  final VoidCallback onLoggedOut;


  @override
  State createState() => new _MainMenuPage();
}


class _MainMenuPage extends State<MainMenuPage> {

  // This must not reach prod.
  FloatingActionButton _showFastFoodSignInButton() {
    return new FloatingActionButton(
        onPressed: _fastFoodLoggedOut,
        tooltip: 'Fast Food LogOut',
        child: Icon(Icons.fastfood)
    );
  }

  // This must not reach prod.
  void _fastFoodLoggedOut() {
    print('PRESSED FAKE LOGOUT !!!!');
    widget.onLoggedOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: BarWafi(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 30),
              ButtonMenu("Pedir algo", () {Navigator.push(context, MaterialPageRoute(builder: (context) => OrderSourcePage(
                  onLoggedOut: widget.onLoggedOut
              )));}),
              const SizedBox(height: 30),
              ButtonMenu("Ser Capo", () {Navigator.push(context, MaterialPageRoute(builder: (context) => AvailableOrdersPage(
                auth: widget.auth,
                onLoggedOut: widget.onLoggedOut,
              )));}),
            ],
          ),
        ),
        endDrawer: DrawerWafi(
            onLoggedOut: widget.onLoggedOut
        ),
        floatingActionButton: _showFastFoodSignInButton()
    );
  }
}
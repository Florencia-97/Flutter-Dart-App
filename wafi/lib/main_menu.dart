import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wafi/extras/bar_app.dart';
import 'package:wafi/login/authentification.dart';

class ButtonMenu extends StatelessWidget {
    final String text;

    ButtonMenu(this.text);

    @override
    Widget build(BuildContext context) {
        return RaisedButton(
            onPressed: () {},
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

  String _userEmail = '';
  int _wafiCredits = 0;


  Text _buildDrawerHeader() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userEmail = user.email;
      });
    });
    return Text('$_userEmail : \t\$ ${_wafiCredits.toString()}');
  }

  // This must not reach prod.
  FloatingActionButton _showFastFoodSignedButton() {
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
              ButtonMenu("Pedir algo"),
              const SizedBox(height: 30),
              ButtonMenu("Ser Capo"),
            ],
          ),
        ),
        endDrawer: Drawer(
          child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: _buildDrawerHeader(),
                  decoration: BoxDecoration(
                      color: Colors.teal
                  ),
                ),
                ListTile(
                  title: Text('Gana 1 millón de wafi créditos'),
                  onTap: () {
                    setState(() {
                      _wafiCredits += 1000000;
                    });
                  },
                ),
                ListTile(
                  title: Text('Cerrar sesión'),
                  onTap: () {
                    widget.onLoggedOut();
                    Navigator.pop(context);
                  },
                )
              ]
          ),
        ),
        floatingActionButton: _showFastFoodSignedButton()
    );
  }
}
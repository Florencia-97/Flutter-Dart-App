import 'package:flutter/material.dart';
import 'package:wafi/login/authentification.dart';

class DrawerWafi extends StatefulWidget {
  DrawerWafi({this.auth, this.onLoggedOut});

  final Auth auth;
  final VoidCallback onLoggedOut;


  @override
  State createState() => _DrawerWafi();
}


class _DrawerWafi extends State<DrawerWafi> {

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

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                  /* TODO: Save in db */
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
    );
  }
}
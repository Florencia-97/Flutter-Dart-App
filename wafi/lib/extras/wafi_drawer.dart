import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wafi/extras/order_item.dart';
import 'package:wafi/extras/order_list.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/db/data_base_controller.dart';

class DrawerWafi extends StatefulWidget {
  DrawerWafi({this.auth, this.onLoggedOut});

  final Auth auth;
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();


  @override
  State createState() => _DrawerWafi();
}


class _DrawerWafi extends State<DrawerWafi> {

  String _userEmail = '';
  List<OrderItem> _orders = new List();
  DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userEmail = user.email;
        _userRef = widget.db.getReferenceById(user.uid);
        _userRef.onChildAdded.listen(_onOrderAdded);
      });
    });
  }

  _onOrderAdded(Event event) {
    setState(() {
      _orders.add(OrderItem.fromSnapshot(event.snapshot));
    });
  }

  Text _buildDrawerHeader() {
    return Text(_userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.78,
        child: Drawer(
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
                  title: Text('Mis Pedidos'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => OrderList(_orders)));
                  },
                ),
                ListTile(
                  title: Text('Cerrar sesión'),
                  onTap: () {
                    widget.onLoggedOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ]
          ),
        )
    );
  }
}
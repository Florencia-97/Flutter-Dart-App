import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wafi/extras/order_item.dart';
import 'package:wafi/extras/order_list.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/db/data_base_controller.dart';

class DrawerWafi extends StatefulWidget {
  DrawerWafi({this.onLoggedOut});

  final Auth auth = Auth();
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();


  @override
  State createState() => _DrawerWafi();
}


class _DrawerWafi extends State<DrawerWafi> {

  String _userEmail = '';
  List<RequestedOrder> _orders = new List();
  DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userEmail = user.email;
        // _userRef = widget.db.getReferenceById(user.uid);
        // _userRef.onChildAdded.listen(_onOrderAdded);

        widget.db.getRequestedOrdersById(user.uid).listen((List<RequestedOrder> data) {
          setState(() {
            _orders = data;
          });
        });
      });
    });
  }

  _onOrderAdded(Event event) {
    setState(() {
      // _orders.add(RequestedOrder.fromSnapshot(event.snapshot));
    });
  }

  Column _buildDrawerHeader() {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 50.0,
          backgroundColor: Colors.red[200],
          child: Text(_userEmail.substring(0,1).toUpperCase(),
            style: TextStyle(fontSize: 40.0, color: Colors.white)
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: Text(_userEmail,
            style: TextStyle(fontSize: 16.0, color: Colors.white)
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int amountOrders = _orders.length;
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
                  leading: Text(amountOrders.toString()),
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
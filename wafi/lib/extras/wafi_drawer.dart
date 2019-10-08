import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wafi/extras/order_item.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/pages/my_orders_page.dart';

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
  String _userId = "";
  List<RequestedOrder> _orders = new List();
  DatabaseReference _userRef;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userEmail = user.email;
        _userId = user.uid;
        // _userRef = widget.db.getReferenceById(user.uid);
        // _userRef.onChildAdded.listen(_onOrderAdded);

        // unused
        Stream<List<RequestedOrder>> notCancelledRequestedOrders = widget.db.getRequestedOrdersById(user.uid).map((requestedOrders) => requestedOrders.where((ro) => ro.status != OrderStatuses.Cancelled).toList());

        /*
        notCancelledRequestedOrders.listen((List<RequestedOrder> data) {
          setState(() {
            _orders = data;
          });
        });
         */
      });
    });
  }

  _onOrderAdded(Event event) {
    setState(() {
      // _orders.add(RequestedOrder.fromSnapshot(event.snapshot));
    });
  }

  Future<Stream<List<RequestedOrder>>> _getRequestedOrders() {
    return widget.auth.getCurrentUser().then((user) {
      return widget.db.getRequestedOrdersById(user.uid)
          .map((requestedOrders) => requestedOrders.where((ro) => ro.status != OrderStatuses.Cancelled).toList());
    });
  }

  Column _buildDrawerHeader() {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 50.0,
          backgroundColor: Colors.red[200],
          // This fails sometimes, what is it doing? !!!! Value not in range: 1
          child: Text(_userEmail != "" ? _userEmail.substring(0,1).toUpperCase() : "",
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

  ListTile _listDrawerTile(String leading, String title){
    return ListTile(
      leading: Text(leading),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => MyOrders(_userId)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.78,
        child: Drawer(
          child: Column(children: <Widget>[
            Expanded(
              child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: _buildDrawerHeader(),
                  decoration: BoxDecoration(
                      color: Colors.teal
                  ),
                ),
                FutureBuilder(
                  future: _getRequestedOrders(),
                  builder: (context, snapshotFuture) {

                    if (snapshotFuture.hasData) {
                      Stream<List<RequestedOrder>> requestedOdersS = snapshotFuture.data;

                      return StreamBuilder(
                          stream: requestedOdersS,
                          builder: (context, snapshotStream) {
                            if (snapshotStream.hasData) {
                              List<RequestedOrder> requestedOrders = snapshotStream.data;
                              return _listDrawerTile(requestedOrders.length.toString(), 'Mis Pedidos');
                            } 
                            return _listDrawerTile('-', 'Mis Pedidos');
                          }
                      );
                    } else {
                      return ListTile(
                        leading: Text(
                            0.toString()),
                        title: Text('Mis Pedidos'),
                        onTap: null,
                      );
                    }
                  },
                ),
                ]
              ),
            ),
            Container(
              color: Colors.grey[100],
              child: ListTile(
                  leading: Icon(Icons.power_settings_new),
                  title: Text('Cerrar sesión'),
                  onTap: () {
                    widget.onLoggedOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              )
          ],
        )
      )
    );
  }
}
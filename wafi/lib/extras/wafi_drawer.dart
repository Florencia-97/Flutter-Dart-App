import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wafi/extras/order_item.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/pages/my_orders_page.dart';
import 'package:wafi/pages/my_taken_orders_page.dart';

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

  Future<Stream<List<RequestedOrder>>> _getOrdersTaken() {
    return widget.auth.getCurrentUser().then((user) {
      return widget.db.getTakenOrdersById(user.uid)
          .map((requestedOrders) => requestedOrders
          //.where((ro) => ro.status == OrderStatuses.Taken)
          .toList());
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

  // Refactor, use only one function!
  ListTile _listDrawerTileOrders(String leading, String title){
    return ListTile(
      leading: Text(leading),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => MyOrders(_userId)));
      },
    );
  }

  ListTile _listDrawerTileTaken(String leading, String title){
    return ListTile(
      leading: Text(leading),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => MyTakenOrders(_userId)));
      },
    );
  }

  //Refactor join functions!!! 
  FutureBuilder _myOrdersTaken(){
    return FutureBuilder(
      future: _getOrdersTaken(),
      builder: (contex, snapshotFuture) {
        if (snapshotFuture.hasData) {
            Stream<List<RequestedOrder>> requestedOdersS = snapshotFuture.data;
            return StreamBuilder(
              stream: requestedOdersS,
              builder: (context, snapshotStream) {
              if (snapshotStream.hasData) {
                List<RequestedOrder> requestedOrders = snapshotStream.data;
                  return _listDrawerTileTaken(requestedOrders.length.toString(), 'Pedidos Tomados');
              } 
                  return _listDrawerTileTaken('-', 'Pedidos Tomados');
              }
            );
        } else {
            return ListTile(
              leading: Text(
                0.toString()),
                title: Text('Pedidos Tomados'),
                onTap: null,
                );
          }
      },
    );
  }

  FutureBuilder _myOrders(){
    return FutureBuilder(
      future: _getRequestedOrders(),
      builder: (contex, snapshotFuture) {
        if (snapshotFuture.hasData) {
            Stream<List<RequestedOrder>> requestedOdersS = snapshotFuture.data;
            return StreamBuilder(
              stream: requestedOdersS,
              builder: (context, snapshotStream) {
              if (snapshotStream.hasData) {
                List<RequestedOrder> requestedOrders = snapshotStream.data;
                  return _listDrawerTileOrders(requestedOrders.length.toString(), 'Mis Pedidos');
              } 
                  return _listDrawerTileOrders('-', 'Mis Pedidos');
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
                _myOrders(),
                _myOrdersTaken(),
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
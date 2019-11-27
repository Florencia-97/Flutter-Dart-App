import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/model/order_status.dart';
import 'package:wafi/model/requested_order.dart';
import 'package:wafi/pages/my_orders_page.dart';
import 'package:wafi/pages/my_taken_orders_page.dart';
import 'package:wafi/pages/profile_page.dart';
import 'package:wafi/pages/root_page.dart';

class DrawerWafi extends StatefulWidget {
  DrawerWafi({this.onLoggedOut});

  final Auth auth = Auth();
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();


  @override
  State createState() => _DrawerWafi();
}


class _DrawerWafi extends State<DrawerWafi> {

  String _username = '';
  String _userId = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      widget.db.getUserInfo(user.uid).then((username) {
        setState(() {
          _username = username;
        });
      });
      setState(() {
        _userId = user.uid;
      });
    });
  }

  Future<Stream<List<RequestedOrder>>> _getRequestedOrders() {
    return widget.auth.getCurrentUser().then((user) {
      return widget.db.getRequestedOrdersById(user.uid)
          .map((requestedOrders) => requestedOrders.where((ro) => ro.status != OrderStatuses.Cancelled).toList());
    });
  }

  Stream<List<RequestedOrder>> _getOrdersTaken() {
    var userId = UserStatus.getUserId();
    print("\n\n\n\n userid: $userId");

    // |||| ask for it on creation
    var takenOrders =  widget.db.getTakenOrdersStream(userId);
    return takenOrders.map((requestedOrders) => requestedOrders
      .where((ro) => ro.status != OrderStatuses.Cancelled)
      .where((ro) => ro.status != OrderStatuses.Resolved)
      .toList());
  }

  //Not ideal de repetition, future refactor
  BoxDecoration _decorationBox(){
    return BoxDecoration(
      color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xd1159957),
            Color(0xf1155799),
          ],
      ),
    );
  }

  Column _buildDrawerHeader() {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 50.0,
          backgroundColor: Color(0xFF596275),
          // This fails sometimes, what is it doing? !!!! Value not in range: 1
          child: Text(_username != "" ? _username.substring(0,1).toUpperCase() : "",
            style: TextStyle(fontSize: 40.0, color: Colors.white)
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
          child: Text(_username,
            style: TextStyle(fontSize: 16.0, color: Colors.white)
          ),
        ),
      ],
    );
  }

  // Refactor, use only one function!
  ListTile _listDrawerTileOrders(String leading, String title, bool enabled) {
    return ListTile(
      enabled: enabled,
      leading: Text(leading),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => MyOrders(_userId)));
      },
    );
  }

  ListTile _listDrawerTileOrdersDisabled() {
    return _listDrawerTileOrders('-', 'Mis Pedidos', false);
  }

  ListTile _listDrawerTileTaken(String leading, String title, bool enabled) {
    return ListTile(
      enabled: enabled,
      leading: Text(leading),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => MyTakenOrders(_userId)));
      },
    );
  }

  ListTile _listDrawerTileTakenDisabled() {
    return _listDrawerTileTaken('-', 'Pedidos Tomados', false);
  }

  // |||| check if this works
  Widget _myOrdersTaken() {
    return StreamBuilder(
        stream: _getOrdersTaken(),
        builder: (context, snapshotStream) {
          if (snapshotStream.hasError) {
            var errorMsg = "Drawer Error: ${snapshotStream.error}";
            print(errorMsg);
            return Text(errorMsg);
          }
          if (!snapshotStream.hasData) {
            return _listDrawerTileTakenDisabled();
          }

          List<RequestedOrder> requestedOrders = snapshotStream.data;
          return _listDrawerTileTaken(
              requestedOrders.length.toString(), 'Pedidos Tomados', true);
        }
    );
  }

  FutureBuilder _myOrders(){
    return FutureBuilder(
      future: _getRequestedOrders(),
      builder: (contex, snapshotFuture) {
        if (!snapshotFuture.hasData) {
          return _listDrawerTileOrdersDisabled();
        }
        Stream<List<RequestedOrder>> requestedOdersS = snapshotFuture.data;
        return StreamBuilder(
            stream: requestedOdersS,
            builder: (context, snapshotStream) {
              if (snapshotStream.hasError) {
                return Text("MyOrders: Error ${snapshotStream.error}");
              }
              if (!snapshotStream.hasData) {
                return _listDrawerTileOrdersDisabled();
              }
              List<RequestedOrder> requestedOrders = snapshotStream.data;
              return _listDrawerTileOrders(requestedOrders.length.toString(), 'Mis Pedidos', true);
            }
        );
      },
    );
  }

  ListTile _profile(){
    return ListTile(
      leading: Icon(Icons.settings),
      title: Text('Mi Perfil'),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => MyProfile(_userId)));
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
                  decoration: _decorationBox()
                ),
                _myOrders(),
                _myOrdersTaken(),
                _profile(),
                ]
              ),
            ),
            Container(
              color: Colors.white60,
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
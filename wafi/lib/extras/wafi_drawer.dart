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

// |||| change to stateless
class DrawerWafi extends StatelessWidget {
  DrawerWafi({this.onLoggedOut});

  final String userId = UserStatus.getUserId();
  final String username = UserStatus.getUserName();
  final Auth auth = Auth();
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();


  Stream<List<RequestedOrder>> _getRequestedOrders() {
    return db.getRequestedOrdersById(userId)
        .map((requestedOrders) =>
        requestedOrders.where((ro) => ro.status != OrderStatuses.Cancelled)
            .toList());
  }

  Stream<List<RequestedOrder>> _getOrdersTaken() {
    var userId = UserStatus.getUserId();

    var takenOrders =  db.getTakenOrdersStream(userId);
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Hola', style: TextStyle(fontSize: 16.0, color: Colors.white)),
        Container(
          padding: const EdgeInsets.only(top: 8),
          child: Text(username,
            style: TextStyle(fontSize: 28.0, color: Colors.white)
          ),
        ),
      ],
    );
  }

  String _initialLetterOfUserName() {
    try {
      return username.substring(0,1).toUpperCase();
    } catch (e) {
      debugPrint("ERROR: Cannot make substring of: '$username' in wafi_drawer");
      return "";
    }
  }

  // Refactor, use only one function!
  ListTile _listDrawerTileOrders(BuildContext context, String leading, String title, bool enabled) {
    return ListTile(
      enabled: enabled,
      leading: Text(leading),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => MyOrders(username)));
      },
    );
  }

  ListTile _listDrawerTileOrdersDisabled(BuildContext context) {
    return _listDrawerTileOrders(context, '-', 'Mis Pedidos', false);
  }

  ListTile _listDrawerTileTaken(BuildContext context, String leading, String title, bool enabled) {
    return ListTile(
      enabled: enabled,
      leading: Text(leading),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => MyTakenOrders(userId)));
      },
    );
  }

  ListTile _listDrawerTileTakenDisabled(BuildContext context) {
    return _listDrawerTileTaken(context, '-', 'Pedidos Tomados', false);
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
            return _listDrawerTileTakenDisabled(context);
          }

          List<RequestedOrder> requestedOrders = snapshotStream.data;
          return _listDrawerTileTaken(
              context, requestedOrders.length.toString(), 'Pedidos Tomados', true);
        }
    );
  }

  StreamBuilder _myOrders(){
    return StreamBuilder(
        stream: _getRequestedOrders(),
        builder: (context, snapshotStream) {
          if (snapshotStream.hasError) {
            return Text("MyOrders: Error ${snapshotStream.error}");
          }
          if (!snapshotStream.hasData) {
            return _listDrawerTileOrdersDisabled(context);
          }
          List<RequestedOrder> requestedOrders = snapshotStream.data;
          return _listDrawerTileOrders(context, requestedOrders.length.toString(), 'Mis Pedidos', true);
        }
    );
  }

  ListTile _profile(BuildContext context){
    return ListTile(
      leading: Icon(Icons.settings),
      title: Text('Mi Perfil'),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => MyProfile(userId)));
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
                _profile(context),
                ]
              ),
            ),
            Container(
              color: Colors.white60,
              child: ListTile(
                  leading: Icon(Icons.power_settings_new),
                  title: Text('Cerrar sesión'),
                  onTap: () {
                    onLoggedOut();
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
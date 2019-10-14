import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/bar_app.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/model/order_status.dart';
import 'package:wafi/model/requested_order.dart';

class MyProfile extends StatefulWidget {
  MyProfile(this._userId);

  final String _userId;
  final Auth auth = Auth();
  final FirebaseController db = FirebaseController();

  @override
  State createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {

  Widget _headerBuilder(){
    return Container(
      height: 250,
      decoration: _decorationBox(),
      //color: Color(0xFFCA4F4C),
      child: SizedBox.expand(
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: AssetImage('assets/turing_profile_ej.jpg'),
              radius: 70.0,
              //backgroundColor: Colors.red[200],
            ),
          ],
        ),
      )
    );
  }

  Container _field(String title, String text){
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('$title: ',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(text,
                style: TextStyle(fontSize: 18),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                icon: Icon(Icons.edit,
                  color: Colors.blueGrey,
                ),
                onPressed: () => null, 
            ),
          ),
            ],
          ),
        ],
      )
    );
  }

  Widget _infoBuilder(){
    return Column(
      children: <Widget>[
        _field('Alias', 'Alan Turing'),
        _field('Mail', 'alan_turing_1@speedy.com'),
      ],
    );
  }

  BoxDecoration _decorationBox(){
    return BoxDecoration(
      color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xd1ff4e50),
            Color(0xddf9d423),
          ],
      ),
    );
  }

  Widget _boxStatsContainer(String text, String n){
    return Container(
      decoration: _decorationBox(),
      alignment: Alignment.center,
      height: 100,
      width: 100,
      child: SizedBox.expand(
        child: Column(
          children: <Widget>[
            Text('$n',
              style: TextStyle(fontSize: 50, color: Colors.white),  
            ),
            Text(text.toUpperCase(),
              style: TextStyle(fontSize: 14 ,color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder _boxStats(String text, Function ordersStreamFunction){
    return FutureBuilder(
      future: ordersStreamFunction(),
      builder: (contex, snapshotFuture) {
        if (snapshotFuture.hasData) {
            Stream<List<RequestedOrder>> requestedOdersS = snapshotFuture.data;
            return StreamBuilder(
              stream: requestedOdersS,
              builder: (context, snapshotStream) {
              if (snapshotStream.hasData) {
                List<RequestedOrder> requestedOrders = snapshotStream.data;
                return _boxStatsContainer(text ,requestedOrders.length.toString());
              } 
                return _boxStatsContainer(text, '-');
              }
            );
        } else {
          return _boxStatsContainer(text, '-');
        }
      },
    );
  }

  Future<Stream<List<RequestedOrder>>> _getResolvedOrders(){
    return widget.auth.getCurrentUser().then((user) {
      return widget.db.getRequestedOrdersById(user.uid) //userId shoud be the same, change
          .map((requestedOrders) => requestedOrders.where((ro) => ro.status == OrderStatuses.Resolved).toList());
    });
  }

  //Refactor add this to db and use it everywhere more generic
  Future<Stream<List<RequestedOrder>>> _getOrdersTaken() async {
    var takenOrders =  await widget.db.getTakenOrdersStream(widget._userId);
    return takenOrders.map((requestedOrders) => requestedOrders
      .where((ro) => ro.status == OrderStatuses.Resolved)
      .toList());
  }


  Widget _statsBuilder(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20),
          child: Text('Stats:',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ),
        Container(
          //height: 160,// remove hard code
          alignment: Alignment.center,
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _boxStats('Pedidos', _getResolvedOrders), //Change name!
            _boxStats('Tomados', _getOrdersTaken), //Change name!
            ],
          ),
        )
      ],
    );
  }

  Widget _body(){
    return Column(
      children: <Widget>[
        _headerBuilder(),
        _infoBuilder(),
        _statsBuilder(),
      ],
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: BarWafi('Perfil'),
        body: _body(), // Make it expanded?
    );
  }
}
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
  String _userEmail = '';
  String _userId = "";
  dynamic _username = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userEmail = user.email;
        _userId = user.uid;
      });
    });
    widget.db.getUserInfo(widget._userId).then((username) {
      setState(() {
        _username = username;
      });
    });
  }

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

  Container _field(String title, String text, bool editable){
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
              if (editable) Container(
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

  // void _editAlias(){
  //   final formKey = GlobalKey<FormState>();
  //   String usernameInput;
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Alias',
  //                   style: TextStyle(fontSize: 20),
  //         ),
  //         content: Form(
  //           key: _formKey,
  //           child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: <Widget>[
  //               Container(
  //                   padding: const EdgeInsets.fromLTRB(25.0, 100.0, 25.0, 0.0),
  //                   child: TextFormField(
  //                     autofocus: false,
  //                     decoration: InputDecoration(
  //                       hintText: 'Descripción',
  //                     ),
  //                     onSaved: (value) => usernameInput = value.trim(),
  //                   ),
  //                 ),
  //               Align(
  //                 alignment: Alignment.bottomLeft,
  //                 child: Row(
  //                   children: <Widget>[
  //                     FlatButton(
  //                       child: Text('CANCELAR',
  //                           style: TextStyle(
  //                               fontSize: 16.0, color: Colors.black38)),
  //                       onPressed: () => Navigator.pop(context),
  //                     ),
  //                     FlatButton(
  //                       child: Text('CREAR',
  //                           style: TextStyle(
  //                               fontSize: 16.0, color: Colors.black)),
  //                       onPressed: _updateUsername(formKey),
  //                     ),
  //                   ],
  //                 )
  //             )
  //           ],
  //         )
  //       ),
  //     );}
  //   );
  // }

  Widget _infoBuilder(){
    return Column(
      children: <Widget>[
        _field('Alias', _username, true),
        _field('Mail', _userEmail, false),
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
    var takenOrders =  await widget.db.getTakenOrdersStream(_userId);
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
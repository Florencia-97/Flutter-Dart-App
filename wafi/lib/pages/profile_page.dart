import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/bar_app.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/model/order_status.dart';
import 'package:wafi/model/requested_order.dart';
import 'package:wafi/pages/root_page.dart';

class MyProfile extends StatefulWidget {
  MyProfile(this._userId);

  final String _userId;
  final Auth auth = Auth();
  final DataBaseController db = FirebaseController();

  @override
  State createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String _userEmail = '';
  String _userId = "";
  dynamic _username = " ";

  //This is for username Form, can i put it in othre place? (Flor)
  final _formKey = GlobalKey<FormState>();
  String _usernameInput;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userEmail = user.email;
        _userId = user.uid;
      });
    });
    setState(() {
      _username = UserStatus.getUserName();
    });
  }

  Widget _headerBuilder(){
    return Container(
      height: 300,
      child: SizedBox.expand(
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              //backgroundImage: AssetImage('assets/turing_profile_ej.jpg'),
              radius: 70.0,
              backgroundColor: Color(0xFF596275),
              child: Text(_initialLetterOfUserName(),
                style: TextStyle(fontSize: 40.0, color: Colors.white)
              ),
            ),
          ],
        ),
      )
    );
  }

  String _initialLetterOfUserName() {
    try {
      return _username.substring(0,1).toUpperCase();
    } catch (e) {
      debugPrint("ERROR: Cannot make substring of: '$_username' in profile_page");
      return "";
    }
  }

  Container _field(String title, String text, bool editable){
    return Container(
      color: Colors.white24,
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[ 
              Text('$title:',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              Text(text,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          if (editable) Container(
            alignment: Alignment.topCenter,
            height: 30,
            child: IconButton(
              alignment: Alignment.topCenter,
              icon: Icon(Icons.edit,
                color: Colors.blueGrey,
              ),
              iconSize: 20,
              onPressed: () => _editAlias(), 
            ),
          ),
        ],
      )
    );
  }

  void _editAlias(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alias',
            style: TextStyle(fontSize: 20),
          ),
          content: _formUsername(),
      );}
    );
  }

  Widget _formUsername(){
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _usernameInputArea(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                child: Text('CANCELAR',
                    style: TextStyle(
                        fontSize: 16.0, color: Colors.black38)),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text('MODIFICAR',
                    style: TextStyle(
                      fontSize: 16.0, color: Colors.black)),
                onPressed: _updateUsername,
              ),
              ],
          )
        ],
      )
    );
  }

  Container _usernameInputArea(){
    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.fromLTRB(5.0, 10.0, 25.0, 0.0),
      child: TextFormField(
        controller: TextEditingController(text: _username),
        autofocus: false,
        onSaved: (value) => _usernameInput = value.trim(),
      ),
    );
  }

  void _updateUsername() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      // !!!! °°°° If the name is too long, there is a debug overflow.
      UserStatus.updateUserName(_usernameInput).then((username) {
        setState(() {
          _username = username;
        });
      });
      Navigator.pop(context);
    }
  }

  Widget _infoBuilder(){
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: <Widget>[
          _field('Alias', _username, true),
          _field('Mail', _userEmail, false),
        ],
      ),
    );
  }

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

  Widget _boxStatsContainer(String text, String n){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(text, style: TextStyle(color: Colors.white, fontSize: 20),),
        Text(n, style: TextStyle(color: Colors.white, fontSize: 20),)
      ],
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
    return Expanded(child: Container(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _boxStats('Pedidos realizados', _getResolvedOrders), 
          SizedBox(height: 20),
          _boxStats('Pedidos tomados', _getOrdersTaken), //Change name!
        ],
      ),
    ));
  }

  Widget _body(){
    return Container(
      decoration: _decorationBox(),
      child: Column(
      children: <Widget>[
        _headerBuilder(),
        Container(child: _infoBuilder(), padding: EdgeInsets.only(right: 10, left: 10)),
        _statsBuilder(),
      ],
    ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        resizeToAvoidBottomPadding: false, //fixes overflowing issues
        appBar: BarWafi('Perfil'),
        body: _body(),
    );
  }
}
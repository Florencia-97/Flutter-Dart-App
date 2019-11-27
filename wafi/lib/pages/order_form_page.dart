import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/extras/wafi_drawer.dart';
import 'package:wafi/extras/ok_screen.dart';
import 'package:wafi/extras/bar_app.dart';
import 'package:wafi/model/classroom.dart';
import 'package:wafi/model/order_source.dart';
import 'package:wafi/model/requested_order.dart';

class OrderPage extends StatefulWidget {
  OrderPage({this.orderSource, this.onLoggedOut});

  final Auth auth = Auth();
  final OrderSource orderSource;
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();

  @override
  State<StatefulWidget> createState() =>  _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();

  List<String> _floors = [];

  String _userId;
  String _title;
  String _description;
  String _floor;
  String _classroom;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid;
        _loadClassrooms();
      });
    });
  }

  void _validateAndSubmit() async {
    final form = _formKey.currentState;
    if (!form.validate())  Navigator.pop(context);
    _onOrderSubmit();
  }

  void _onOrderSubmit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      // !!!!! due to bug
      _title = _title == null ? "default|${Random().nextInt(2000)}" : _title;
      _classroom = _classroom == null ? "d-${Random().nextInt(99)}" : _classroom;

      widget.db.addRequestedOrder(_userId, _title, widget.orderSource.name, _floor, _description, _classroom);

      Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
      Navigator.push(context, MaterialPageRoute(builder: (context) => OkScreen()));
    }
  }

  Widget _showOrderTitle() {
    String _titleName = widget.orderSource.viewName.toUpperCase();
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 30),
      color:  Color(0xFF596275),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container( 
            child:Icon(widget.orderSource.icon, color: Colors.teal,),
            margin: EdgeInsets.only(right: 30),
          ),
          Text(_titleName,
              style: TextStyle( fontSize: 18, color: Colors.white,)
          ),
        ],
      ),
    );
  }

  /* TODO: Refactor, use same function for all inputs. Add validators */
  Widget _showInputTitle(double pad) {
    return Container(
      padding: EdgeInsets.only(bottom: pad),
      child: TextFormField(
        maxLines: 1,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Titulo',
        ),
        onSaved: (value) =>  setState ( () => _title = value.trim() ),
        validator: (value) => value.isEmpty ? 'Titulo no puede estar vacio' : null,
      ),
    );
  }

  Widget _showInputDescription(double pad) {
    return Container(
      padding: EdgeInsets.only(bottom: pad),
      child: TextFormField(
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Descripción',
        ),
        onSaved: (value) => _description = value.trim(),
      ),
    );
  }

  void _loadClassrooms() async {
    ;
    List<String> classrooms = await widget.db.getFloorsSnapshot();

    setState(() {
      _floors = classrooms;
    });
  }

  List<String> _getFloors() {
    return _floors;
  }

  void _showDialog() {

    // This here because of bug
    if (_title == null || _title == "") {
      _title = "default ${Random().nextInt(2000)}";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seguro?"),
          content: new Text("De aceptar se creará un pedido a tu nombre"),
          actions: <Widget>[
            Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text('CANCELAR',
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.black38)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    FlatButton(
                      child: Text('CREAR',
                          style: TextStyle(
                              fontSize: 16.0, color: Colors.black)),
                      onPressed: _validateAndSubmit,
                    ),
                  ],
                )
            )
          ],
        );
      },
    );
  }

  Widget _showInputFloor(double pad) {
    return Container(
      padding: EdgeInsets.only(bottom: pad),
      child: DropdownButtonFormField<String>(
        value: _floor,
        items: _getFloors().map<DropdownMenuItem<String>>((String floor) {
          return DropdownMenuItem<String>(
            value: floor,
            child: Text(floor),
          );
        }).toList(),
        decoration: InputDecoration(
          hintText: 'Piso',
        ),
        onSaved: (value) => _floor = value.trim(),
        onChanged: (String newValue) {
          setState(() {
            _floor = newValue;
            _classroom = null;
          });
        },
        validator: (value) =>
        value.isEmpty
            ? 'Piso no puede estar vacio'
            : null,
      ),
    );
  }

  Widget _showInputClassrooms(double pad) {
    return Container(
      padding: EdgeInsets.only(bottom: pad),
      child: TextFormField(
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Aula',
        ),
        onSaved: (value) => _classroom = value.trim(),
        validator: (x) => null,
      ),
    );
  }

  Widget _showPrimaryButton(double pad) {
    return Container(
      padding: EdgeInsets.only(bottom: pad),
      child: SizedBox(
        height: 40.0,
        child: RaisedButton(
          elevation: 5.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0)),
          color: Colors.teal,
          child: Text('Añadir pedido',
              style: TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: _showDialog,
        ),
      )
    );
  }

  Widget _showBody() {
    double n = 60;
    return Container(
      padding: EdgeInsets.only(left: 28, right: 28),
      alignment: Alignment.center,
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            _showOrderTitle(),
            _showInputTitle(n),
            _showInputFloor(n),
            _showInputClassrooms(n),
            _showInputDescription(n),
            _showPrimaryButton(n),
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarWafi('Orden'),
      body: Stack(
        children: <Widget>[
          _showBody(),
        ],
      ),
      endDrawer: DrawerWafi(
          onLoggedOut: widget.onLoggedOut
      ),
    );
  }
}
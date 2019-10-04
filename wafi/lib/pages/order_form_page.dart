import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/extras/wafi_drawer.dart';
import 'package:wafi/extras/ok_screen.dart';
import 'package:wafi/extras/bar_app.dart';

class OrderPage extends StatefulWidget {
  OrderPage({this.orderSource, this.onLoggedOut});

  final Auth auth = Auth();
  final String orderSource;
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();

  @override
  State<StatefulWidget> createState() =>  _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();

  List<Classroom> _classroomsOptions = [];

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

  void _onOrderSubmit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      // due to bug
      if (_title == null) {
        final fakeTitle = "default ${Random().nextInt(2000)}";
        widget.db.addRequestedOrder(_userId, fakeTitle, widget.orderSource, _floor, _description, int.parse(_classroom));
      } else {
        widget.db.addRequestedOrder(_userId, _title, widget.orderSource, _floor, _description, int.parse(_classroom));
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) => OkScreen()));
    }
  }

  Widget _showOrderTitle() {
    return Container(
        margin: EdgeInsets.all(20),
        child: Text(widget.orderSource,
          style: TextStyle(
              fontSize: 20
          ),
        )
    );
  }

  /* TODO: Refactor, use same function for all inputs. Add validators */
  Widget _showInputTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Titulo',
        ),
        onSaved: (value) =>  setState ( () => _title = value.trim() ),
        // validator: (value) => value.isEmpty ? 'Titulo no puede estar vacio' : null,
        validator: (x) => null,
      ),
    );
  }

  Widget _showInputDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
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
    List<Classroom> classrooms = await widget.db.getClassroomsSnapshot();

    setState(() {
      _classroomsOptions = classrooms;
    });
  }

  List<String> _getFloors() {
    return _classroomsOptions.map((c) => c.floor.toString()).toSet().toList();
  }

  void _showDialog() {


    // Only enters here because of a bug
    if (_title == null || _classroom == null || _floor == null) {
      if (false) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Bug"),
                content: new Text(
                    "No me toma (soy todri) el title y queda en null\n$_title $_classroom $_floor $_description"),
                actions: <Widget>[
                  FlatButton(
                    child: Text('CANCELAR',
                        style: TextStyle(
                            fontSize: 16.0, color: Colors.black38)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
            }
        );
        return;
      }
    }

    if (_title == null) {
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
                      onPressed: _onOrderSubmit,
                    ),
                  ],
                )
            )
          ],
        );
      },
    );
  }

  Widget _showInputFloor() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
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

  List<Classroom> _getClassrooms() {
    if (_floor == null) return [];
    return _classroomsOptions.where((c) => c.floor == int.parse(_floor))
        .toList();
  }

  Widget _showInputClassrooms() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: DropdownButtonFormField<String>(
        value: _classroom,
        items: this._getClassrooms().map<DropdownMenuItem<String>>((
            Classroom classroom) {
          return DropdownMenuItem<String>(
            value: classroom.code,
            child: Text(classroom.code),
          );
        }).toList(),
        decoration: InputDecoration(
          hintText: 'Aula',
        ),
        onSaved: (value) => _classroom = value.trim(),
        onChanged: (String newValue) {
          setState(() {
            _classroom = newValue;
          });
        },
        validator: (value) =>
        value.isEmpty ? 'Aula no puede estar vacia' : null,
      ),
    );
  }

  /*
  Widget _showInputType() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: DropdownButtonFormField<String>(
        value: _type,
        items: this._typeOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
            hintText: 'Tipo de pedido',
            ),
        onSaved: (value) => _type = value.trim(),
        onChanged: (String newValue){ setState(() {_type = newValue;});},
        validator: (value) => value.isEmpty ? 'Tipo no puede estar vacio' : null,
      ),
    );
  }
   */

  Widget _showInputClassroom() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.number,
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Aula',
        ),
        onSaved: (value) => _classroom = value.trim(),
        validator: (value) =>
        value.isEmpty ? 'Aula no puede estar vacia' : null,
      ),
    );
  }

  Widget _showPrimaryButton() {
    return Container(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
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
        ));
  }

  Widget _showBody() {
    return Container(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _showOrderTitle(),
              _showInputTitle(),
              //_showInputType(),
              _showInputFloor(),
              _showInputClassrooms(),
              // _showInputClassroom(),
              _showInputDescription(),
              _showPrimaryButton(),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarWafi(),
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
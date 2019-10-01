import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/extras/wafi_drawer.dart';
import 'package:wafi/extras/bar_app.dart';

class OrderPage extends StatefulWidget {
  OrderPage({this.type, this.onLoggedOut});

  final Auth auth = Auth();
  final String type;
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();

  @override
  State<StatefulWidget> createState() =>  _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _typeOptions = ['Comedor', 'Fotocopiadora', 'Kiosco'];

  String _userId;
  String _title;
  String _description;
  String _classroom;

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user.uid;
      });
    });
  }

  void _onOrderSubmit() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      widget.db.addOrder(
          _userId, _title, widget.type, _description, int.parse(_classroom));
      Navigator.pop(context); /* TODO: Add message of success */
    }
  }

  Widget _showOrderTitle() {
    return Container(
        margin: EdgeInsets.all(20),
        child: Text(widget.type,
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
        onSaved: (value) => _title = value.trim(),
        validator: (value) =>
        value.isEmpty
            ? 'Titulo no puede estar vacio'
            : null,
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
        value.isEmpty
            ? 'Aula no puede estar vacio'
            : null,
      ),
    );
  }

  Widget _showPrimaryButton() {
    return Padding(
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
            onPressed: _onOrderSubmit,
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
              _showInputClassroom(),
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
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/extras/wafi_drawer.dart';
import 'package:wafi/extras/ok_screen.dart';
import 'package:wafi/extras/bar_app.dart';
import 'package:wafi/model/order_source.dart';

class OrderPage extends StatefulWidget {
  OrderPage({this.onLoggedOut});

  final Auth auth = Auth();
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();

  @override
  State<StatefulWidget> createState() =>  _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {

  final _formKey = GlobalKey<FormState>();
  final PageController cntrl = PageController(viewportFraction: 0.5);
  int currentPage = 0;

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

    cntrl.addListener(() { 
      int next = cntrl.page.round();
      if (currentPage != next) { 
        setState(() {
          currentPage = next;
        });
      } 
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
    String orderSourceName = OrderSources.validSources[currentPage].name;
    widget.db.addRequestedOrder(_userId, _title, orderSourceName, _floor, _description, _classroom);
    Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
    Navigator.push(context, MaterialPageRoute(builder: (context) => OkScreen()));
    }
  }

  /* TODO: Refactor, use same function for all inputs. Add validators */
  Widget _showInputTitle() {
    Widget child = TextFormField(
        maxLines: 1,
        autofocus: false,
        decoration: InputDecoration(
          hintText: '¿Qué querés comprar?',
        ),
        onSaved: (value) =>  setState ( () => _title = value.trim() ),
        validator: (value) => value.isEmpty ? 'Titulo no puede estar vacio' : null,
    );
    return _wrapField(child);
  }

  Widget _getImage(String sector) {
    var assetImage = AssetImage(sector);
    return Image(
      image: assetImage, 
      width: 65.0,
    );
  }

  Widget _buildStoryPage(OrderSource orderSource, bool active) {
    final double blur = active ? 20 : 0;
    final double offset = active ? 20 : 0;
    final double top = active ? 5 : 10;
    final Color textColor = active? Colors.teal : Colors.white;


    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(top: top, bottom: 35, right: 10),
      decoration: BoxDecoration(
        color: Colors.lightBlue[900],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: blur, offset: Offset(offset, offset))
        ]
      ),
      child: RaisedButton(
        child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getImage(orderSource.image),
                Text(orderSource.viewName, style: TextStyle(fontSize: 15, color: textColor)),
              ],)
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )
      )
    );
  }

  Widget _showPlaceBody(BuildContext context) {
    List<OrderSource> slideList = OrderSources.validSources;

    PageView pageView = PageView.builder(
        controller: cntrl,
        itemCount: slideList.length,
        itemBuilder: (context, int currentIdx){
          if (slideList.length > currentIdx) {
                bool active = currentIdx == currentPage;
                return _buildStoryPage(slideList[currentIdx ], active);
          }
        },
    );

    return Expanded(
      flex: 1,
      child: pageView,
    );
  }

  Widget _showOrderPlace(BuildContext context){
    Widget info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
          child: Text('Seleccioná el lugar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20
            ),
          ),
        ),
        _showPlaceBody(context),
      ],
    );
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.teal,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)
        )
      ),
      child: info,
    );
  }

  Widget _showInputDescription() {
    Widget child = TextFormField(
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Descripción',
        ),
        onSaved: (value) => _description = value.trim(),
    );
    return _wrapField(child);
  }

  void _loadClassrooms() async {
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

  Widget _showInputFloor() {
    Widget child = DropdownButtonFormField<String>(
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
    );
    return Flexible(child: child, flex: 4,);
  }

  Widget _showInputClassrooms() {
    Widget child = TextFormField(
        autofocus: false,
        decoration: InputDecoration(
          hintText: 'Aula',
        ),
        onSaved: (value) => _classroom = value.trim(),
        validator: (x) => null,
    );
    return Flexible(child: child, flex: 6,);
  }

  Widget _showPrimaryButton() {
    Widget child = SizedBox(
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
    );
    return _wrapField(child);
  }

  Widget _showFloorClass(){
    Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _showInputFloor(),
        _showInputClassrooms(),
      ],
    );
    return _wrapField(child);
  }

  Widget _wrapField(Widget child){
    return Container(
      padding: EdgeInsets.only(bottom: 25, right: 30, left: 30, top: 25),
      child: child
    );
  }
  
  Widget _showBody(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children:[
          _showOrderPlace(context),
          _showFloorClass(),
          _showInputTitle(),
          _showInputDescription(),
          _showPrimaryButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarWafi('Nueva Orden'),
      body: Container(
        child: _showBody(context),
      ),
      endDrawer: DrawerWafi(
          onLoggedOut: widget.onLoggedOut
      ),
    );
  }
}
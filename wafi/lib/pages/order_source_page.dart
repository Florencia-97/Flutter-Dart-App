import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/bar_app.dart';
import 'package:wafi/extras/wafi_drawer.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/model/order_source.dart';
import 'package:wafi/pages/order_form_page.dart';

class OrderSourcePage extends StatefulWidget {
  OrderSourcePage({this.onLoggedOut});

  final Auth auth = Auth();
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();

  @override
  State<StatefulWidget> createState() =>  _OrderSourcePageState();
}

class _OrderSourcePageState extends State<OrderSourcePage> {

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _showTypeButtons() {
    return OrderSources.validSources.map((source) => _showOrderSourceButton(source)).toList();
  }

  Widget _getImage(String sector) {
    var assetImage = AssetImage(sector);
    return Image(image: assetImage, height: 106.0, width: 86.0, fit: BoxFit.fitWidth,);
  }

  Widget _showOrderSourceButton(OrderSource orderSource) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: SizedBox(
        height: 100.0,
        child: RaisedButton(
          color: Color(0xFFE1DEDE),
          child: ListTile(
            title: Text(orderSource.viewName,
              style: TextStyle(fontSize: 20.0, color: Colors.blueGrey[600])),
            leading: _getImage(orderSource.image),
          ),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage(
            orderSource: orderSource,
            onLoggedOut: widget.onLoggedOut))
          ),
        ),
      ),
    );
  }

  Widget _showBody() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Form(
        child: ListView(
          shrinkWrap: true,
          children: _showTypeButtons(),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarWafi('Lugar'),
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
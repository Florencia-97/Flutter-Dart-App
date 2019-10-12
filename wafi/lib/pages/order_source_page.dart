import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/extras/bar_app.dart';
import 'package:wafi/extras/wafi_drawer.dart';
import 'package:wafi/login/authentification.dart';
import 'package:wafi/model/order_source.dart';
import 'package:wafi/model/requested_order.dart';
import 'package:wafi/pages/order_form_page.dart';
//import 'package:flutter_svg/flutter_svg.dart';

class OrderSourcePage extends StatefulWidget {
  OrderSourcePage({this.onLoggedOut});

  final Auth auth = Auth();
  final VoidCallback onLoggedOut;
  final DataBaseController db = FirebaseController();

  @override
  State<StatefulWidget> createState() =>  _OrderSourcePageState();
}

class _OrderSourcePageState extends State<OrderSourcePage> {

  // !!!!
  // final _typeOptions = ['Comedor', 'Fotocopiadora', 'Kiosco'];

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        // !!!!
      });
    });
  }

  List<Widget> _showTypeButtons() {

    return OrderSources.validSources.map((source) => _showOrderSourceButton(source)).toList();
  }

  Widget _getImage(String sector) {
    var assetImage = AssetImage(sector);
    var image = Image(image: assetImage, height: 106.0, width: 86.0, fit: BoxFit.fitWidth,);
    return image;
    // return SvgPicture.asset(
    //         'assets/coffe.svg',
    //         width: 34,
    //         height: 14);
  }

  Widget _showOrderSourceButton(OrderSource orderSource) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20), //EdgeInsets.fromLTRB(20.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 100.0,
          child: RaisedButton(
            color: Color(0xFFE1DEDE),
            child: ListTile(
              title: Text(orderSource.viewName,
                style: TextStyle(fontSize: 20.0, color: Colors.blueGrey)),
              leading: _getImage(orderSource.image),
              ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage(
              orderSource: orderSource,
              onLoggedOut: widget.onLoggedOut))),
          ),
        ));
  }

  Widget _showBody() {
    return Container(
        padding: EdgeInsets.fromLTRB(16, 80, 16, 0),
        child: Form(
          child: ListView(
            shrinkWrap: true,
            children: _showTypeButtons(),
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
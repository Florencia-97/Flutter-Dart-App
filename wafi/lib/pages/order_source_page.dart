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

  final PageController cntrl = PageController(viewportFraction: 0.8);
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    cntrl.addListener(() { 
      int next = cntrl.page.round();
      if (currentPage != next) { 
        setState(() {
          currentPage = next;
        });
      } 
    });
  }

  Widget _getImage(String sector) {
    var assetImage = AssetImage(sector);
    return Image(
      image: assetImage, 
      width: 186.0,
    );
  }

  Widget _buildStoryPage(OrderSource orderSource, bool active) {
    final double blur = active ? 30 : 0;
    final double offset = active ? 20 : 0;
    final double top = active ? 80 : 120;


    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOutQuint,
      margin: EdgeInsets.only(top: top, bottom: 40, right: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: blur, offset: Offset(offset, offset))
        ]
      ),
      child: RaisedButton(
        color: Colors.grey[300],
        child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getImage(orderSource.image),
                Text(orderSource.viewName, style: TextStyle(fontSize: 30, color: Colors.white)),
              ],)
          ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OrderPage(
          orderSource: orderSource,
          onLoggedOut: widget.onLoggedOut)
          )
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )
      )
    );
  }

  Widget _showBody(BuildContext context) {
    List<OrderSource> slideList = OrderSources.validSources;

    return Form(
      child : PageView.builder(
        controller: cntrl,
        itemCount: slideList.length,
        itemBuilder: (context, int currentIdx){
          if (slideList.length > currentIdx) {
                bool active = currentIdx == currentPage;
                return _buildStoryPage(slideList[currentIdx ], active);
          }
        },
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarWafi('Lugar'),
      body: Stack(
        children: <Widget>[
          _showBody(context),
        ],
      ),
      endDrawer: DrawerWafi(
          onLoggedOut: widget.onLoggedOut
      ),
    );
  }
}
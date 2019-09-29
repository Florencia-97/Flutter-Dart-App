import 'package:flutter/material.dart';

class BarWafi extends StatefulWidget implements PreferredSizeWidget {
    BarWafi({Key key}) : 
      preferredSize = Size.fromHeight(kToolbarHeight), super(key: key);

    @override
    final Size preferredSize; 

    @override
    _BarWafiState createState() => _BarWafiState();
}

class _BarWafiState extends State<BarWafi>{

    @override
    Widget build(BuildContext context) {
        return AppBar(
          title: Text("Wafi")/*,
          // !!!!
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(Icons.menu)
            )
          ],*/
        );
    }
}
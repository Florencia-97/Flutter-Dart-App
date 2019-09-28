import 'package:flutter/material.dart';
import 'package:wafi/extras/bar_app.dart';

class ButtomMenu extends StatelessWidget {
    final String text;

    ButtomMenu(this.text);

    @override
    Widget build(BuildContext context) {
        return RaisedButton(
            onPressed: () {},
            child:  Padding(
              padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 10.0, bottom: 10.0),
              child: Text( text,
              style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
            color: Colors.teal,
        );
    }
}

class MainMenuPage extends StatelessWidget {
  MainMenuPage();
  
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: BarWafi(),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 30),
            ButtomMenu("Pedir algo"),
          const SizedBox(height: 30),
            ButtomMenu("Ser Capo"),
        ],
      ),
  )
  ); 
}
  
}
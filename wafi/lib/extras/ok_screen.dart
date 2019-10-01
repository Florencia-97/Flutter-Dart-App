import 'package:flutter/material.dart';

class OkScreen extends StatefulWidget {
    @override
    _OkScreenState createState() => _OkScreenState();
}

class _OkScreenState extends State<OkScreen>{

    Animation animation;
    AnimationController animationController;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: Colors.teal,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RotationTransition(
                turns: AlwaysStoppedAnimation(-35/360),
                child: Icon(Icons.send,
                color: Colors.white,
                size: 120.0,
                )
              ),
              Center(child: Padding(
                  padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 35.0, bottom: 20.0),
                  child: Text('Tu pedido se realizó correctamente!',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),),
              RaisedButton(
                onPressed: () {Navigator.pop(context);},
                child: Padding(
                  padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 10.0, bottom: 10.0),
                  child: Text('Ir a mis pedidos',
                    style: TextStyle(fontSize: 22, color: Colors.teal),
                  ),
                ),
              color: Colors.white,
              )
            ],
          ),
        ),
      );
    }
}
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:wafi/pages/main_menu.dart';

class OkScreen extends StatefulWidget {
    @override
    _OkScreenState createState() => _OkScreenState();
}

class _OkScreenState extends State<OkScreen> with SingleTickerProviderStateMixin{

    static const FACE_LEFT_ANGLE = -pi / 2;
    static const FACE_RIGHT_ANGLE = pi / 2;

    Animation animation;
    AnimationController animationController;

    double _angle =  FACE_RIGHT_ANGLE;

    @override
    void initState() {
      super.initState();

      animationController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this)
        ..addListener(() {
        this.setState(() {});
      })
      ..addStatusListener((status){
      if (status == AnimationStatus.completed) {
        animationController.reverse();
        _angle = FACE_LEFT_ANGLE;
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
        _angle = FACE_RIGHT_ANGLE;
      }
      });

      Tween _tween = new AlignmentTween(
        begin: Alignment(-0.7, 0.0),
        end: Alignment(0.7, 0.0),
      );

      animation = _tween.animate(animationController);
      animationController.forward();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: Colors.teal,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                alignment: animation.value,
                child: Transform.rotate(
                  angle: _angle,
                  child:  RotationTransition(
                    turns: AlwaysStoppedAnimation(-90/360),
                    child: Icon(Icons.send,
                    color: Colors.white,
                    size: 100.0,
                    )
                  ),
                )
              ),
              Center(
                child: Container(
                padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 35.0, bottom: 20.0),
                child: Text(
                  'Tu pedido se realizó correctamente!',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => MainMenuPage()));},
                child: Container(
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

    @override
    void dispose() {
      animationController.dispose();
      super.dispose();
    }
}
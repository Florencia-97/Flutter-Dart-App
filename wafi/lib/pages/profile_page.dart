import 'package:flutter/material.dart';
import 'package:wafi/extras/bar_app.dart';

class MyProfile extends StatelessWidget {
  MyProfile(this._userId);

  final String _userId;

  Widget _headerBuilder(){
    return Container(
      height: 250,
      color: Color(0xFFCA4F4C),
      child: SizedBox.expand(
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: AssetImage('assets/turing_profile_ej.jpg'),
              radius: 70.0,
              //backgroundColor: Colors.red[200],
            ),
          ],
        ),
      )
    );
  }

  Container _field(String title, String text){
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('$title: ',
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(text,
                style: TextStyle(fontSize: 18),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                icon: Icon(Icons.edit,
                  color: Colors.blueGrey,
                ),
                onPressed: () => null, 
            ),
          ),
            ],
          ),
        ],
      )
    );
  }

  Widget _infoBuilder(){
    return Column(
      children: <Widget>[
        _field('Alias', 'Alan Turing'),
        _field('Mail', 'alan_turing_1@speedy.com'),
      ],
    );
  }

  Widget _boxStats(String text, int n){
    return Container(
      alignment: Alignment.center,
      height: 90,
      width: 90,
      color: Colors.pink[200],
      child: SizedBox.expand(
        child: Text('$text, $n'),
      ),
    );
  }

  Widget _statsBuilder(){
    return Column(
      children: <Widget>[
        Text('Data'),
        Container(
          height: 160,// remove hard code
          alignment: Alignment.center,
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _boxStats('Pedidos', 10),
            _boxStats('Tomados', 10),
        ],
      ),
        )
      ],
    );
  }

  Widget _body(){
    return Column(
      children: <Widget>[
        _headerBuilder(),
        _infoBuilder(),
        _statsBuilder(),
      ],
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: BarWafi('Perfil'),
        body: _body(), // Make it expanded?
    );
  }
}
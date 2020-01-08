import 'package:flutter/material.dart';
import 'package:wafi/model/requested_order.dart';

class CustomDialog extends StatelessWidget {

  final RequestedOrder order;

  CustomDialog(this.order){
  }

  Text _createText(String text){
    return Text(text,
      style: TextStyle(
        fontSize: 18, 
      ),
    );
  }

  Row rowButtons(){
    return Row(
        children: <Widget>[
          FlatButton(
            child: Text('IGNORAR',
                style: TextStyle(
                    fontSize: 16.0, color: Colors.black38)),
            onPressed: null,
          ),
          FlatButton(
            child: Text('TOMAR',
                style: TextStyle(
                    fontSize: 16.0, color: Colors.teal)),
            onPressed: null,
          ),
        ],
    );
  }

  Column details(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
          _createText('Compra: ${order?.title}'),
          _createText('Piso: ${order?.floor}'),
          _createText('Aula: ${order?.classroom}'),
          _createText('Descripción: ${order?.description}'),
      ],
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 400.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top:15.0),
              height: 200,
              child: Image(image: AssetImage('assets/buffet.png'))
            ),
            Container(
              child: details(),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: rowButtons(),
            )
          ],
        ),
      ),
    );
  }
}
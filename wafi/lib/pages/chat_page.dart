import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/model/chat.dart';
import 'package:wafi/model/requested_order.dart';

/*
  Copied from here...
  youtube: https://www.youtube.com/watch?v=1bNME5FWWXk
  github: https://github.com/tensor-programming/chat_app_live_stream/blob/master/lib/main.dart
*/
class ChatPage extends StatefulWidget {

  final String userId;
  final RequestedOrder requestedOrder;
  final FirebaseController db = FirebaseController();

  ChatPage(this.userId, this.requestedOrder);


  @override
  State createState() => _ChatPage();
}


class _ChatPage extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String _usernameBud = "";
  bool _isCapo = false;

  @override
  void initState() {
    String budId =  widget.requestedOrder.requesterUserId;
    if (budId == widget.userId){
      budId = widget.requestedOrder.takerUserId;
      _isCapo = true;
    }
    widget.db.getUserInfo(budId).then((username) {
      setState(() {
        _usernameBud = username;
      });
    });
  }

  Future<void> sendButtonCallback() async {

    var text = messageController.text.trim();
    if (text.length > 0) {

      var dateTime = DateTime.now().toIso8601String().toString();
      await widget.db.sendMessage(widget.requestedOrder.id, widget.userId, text, dateTime);

      messageController.clear();
      scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Widget buildMessage(ChatMessageWidget chatMessage) {
    return chatMessage;
  }

  Stream<List<ChatMessageWidget>> buildMessages() {
    return widget.db.getChat(widget.requestedOrder.id).map((chat) {
      return chat.messages.map((msg)  {
        bool own = msg.userId == widget.userId;
        return ChatMessageWidget(msg.text, own);
      }).toList();
    });
  }

  Widget _textChatArea(){
    return Container(
      height: 50.0,
      color: Colors.white,
      child: TextField(
        maxLines: null,
        style: TextStyle(color: Colors.black),
        onSubmitted: (value) => null, // It think it is not necessary since the send button does it. // !!!! (value) => callback(),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(15),
          hintText: "Ingresá un mensaje...",
          border: InputBorder.none,
        ),
      controller: messageController,
      ),
    );
  }


  Widget _doBuildChat(List<ChatMessageWidget> chatMessages) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => chatMessages[index],
              itemCount: chatMessages.length,
              reverse: true,
              controller: scrollController,
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _textChatArea(),
                ),
                SendButton(
                  text: "Send",
                  callback: sendButtonCallback,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_usernameBud),
            if(_isCapo) Text('Tu capo', style: TextStyle(color: Colors.grey[300], fontSize: 14) )
          ]
          ,)
        ),
      backgroundColor: Colors.blueGrey[200],
      body: StreamBuilder(
        stream: buildMessages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.teal))); // !!!! standarize circular progress
          } else {
            List<ChatMessageWidget> chatMessages = snapshot.data;
            return _doBuildChat(chatMessages);
          }
        },
      ),
    );
  }
}


class ChatMessageWidget extends StatelessWidget {

  final String text;
  final bool own;

  ChatMessageWidget(this.text, this.own);


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment:
        own ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: Material(
              color: own ? Colors.lightGreen[200] : Colors.grey[100],
              borderRadius: BorderRadius.circular(10.0),
              elevation: 3.0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}


class SendButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;

  const SendButton({Key key, this.text, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      child: FlatButton(
        color: Colors.grey[50],
        onPressed: callback,
        child: Icon(Icons.send, color: Colors.teal,),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';

class ChatPage extends StatefulWidget {

  final String userId;
  final FirebaseController db = FirebaseController();

  ChatPage(this.userId);


  @override
  State createState() => _ChatPage();
}


class _ChatPage extends State<ChatPage> {

  // !!!! remove eventually
  var counterStream = Stream<List<ChatMessageWidget>>.periodic(Duration(seconds: 1), (x) {
    return [
      ChatMessageWidget("holaa", true),
      ChatMessageWidget("no sos opi, no?", true),
      ChatMessageWidget("JAJAJAJA", false),
      ChatMessageWidget("no tranqui", false),
      ChatMessageWidget("che, el del buffet me escuchó mal y le puso leche al café", false),
    ].reversed;

    // return [x.toString(), (x + 1).toString(), (x + 2).toString()];
  }).take(15);


  Widget buildMessage(ChatMessageWidget chatMessage) {
    return chatMessage;
  }

  Stream<List<ChatMessageWidget>> buildMessages() {

    // return counterStream;

    // !!!!
    return widget.db.getChat("-LqO5fxzgC_RtIeETGRF").map((chat) {
      return chat.messages.map((msg)  {
        bool own = msg.userId == widget.userId;
        return ChatMessageWidget(msg.text, own);
      }).toList();
    });


    // !!!! return counterStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat con !!!!")),
      body: StreamBuilder(
        stream: buildMessages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent))); // !!!! standarize circular progress
          } else {
            List<ChatMessageWidget> chatMessages = snapshot.data;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => chatMessages[index],// !!!! buildMessage(listMessage[index], index % 2 == 0), // buildItem(index, snapshot.data.documents[index]),
              itemCount: chatMessages.length, // snapshot.data.documents.length,
              reverse: true,
              // controller: listScrollController,
            );
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
          Material(
            color: own ? Colors.lightGreen : Colors.grey,
            borderRadius: BorderRadius.circular(10.0),
            elevation: 6.0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(
                text,
              ),
            ),
          )
        ],
      ),
    );
  }
}
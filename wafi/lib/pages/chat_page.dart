import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wafi/db/data_base_controller.dart';
import 'package:wafi/model/chat.dart';


// copied from here
// youtube: https://www.youtube.com/watch?v=1bNME5FWWXk
// github: https://github.com/tensor-programming/chat_app_live_stream/blob/master/lib/main.dart
class ChatPage extends StatefulWidget {

  final String userId;
  final FirebaseController db = FirebaseController();

  ChatPage(this.userId);


  @override
  State createState() => _ChatPage();
}


class _ChatPage extends State<ChatPage> {

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  // !!!! remove eventually
  List<ChatMessageWidget> defaultMessages = [
    ChatMessageWidget("holaa", true),
    ChatMessageWidget("no sos opi, no?", true),
    ChatMessageWidget("JAJAJAJA", false),
    ChatMessageWidget("no tranqui", false),
    ChatMessageWidget("che, el del buffet me escuchó mal y le puso leche al café", false),
    ChatMessageWidget("NO", true),
    ChatMessageWidget("NOO", true),
    ChatMessageWidget("NOOO", true),
    ChatMessageWidget("NOOOO", true),
    ChatMessageWidget("NOOOOO", true),
    ChatMessageWidget("NOOOOOO", true),
    ChatMessageWidget("NOOOOOOO", true),
    ChatMessageWidget("NOOOOOOO", true),
    ChatMessageWidget("NOOOOOOO", true),
    ChatMessageWidget("NOOOOOOO", true),
    ChatMessageWidget("NOOOOOOO", true),

  ].reversed.toList();


  Widget buildMessage(ChatMessageWidget chatMessage) {
    return chatMessage;
  }

  Stream<List<ChatMessageWidget>> buildMessages() {

    return widget.db.getChat("-LqO5fxzgC_RtIeETGRF").map((chat) {
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
        onSubmitted: (value) => null, // (value) => callback(),
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
              itemBuilder: (context, index) => chatMessages[index],// !!!! buildMessage(listMessage[index], index % 2 == 0), // buildItem(index, snapshot.data.documents[index]),
              itemCount: chatMessages.length, // snapshot.data.documents.length,
              reverse: true, // !!!!!
              controller: scrollController,
              // controller: listScrollController,
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
                  callback: () => null// callback,
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
      appBar: AppBar(title: Text("Chat con !!!!")),
      backgroundColor: Colors.blueGrey[200],
      body: StreamBuilder(
        stream: buildMessages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _doBuildChat(defaultMessages);
            // !!!! Leave what is below
            return Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent))); // !!!! standarize circular progress
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

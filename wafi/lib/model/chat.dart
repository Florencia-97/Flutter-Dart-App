
class Chat {

  final List<ChatMessage> messages;

  Chat(this.messages);

  @override
  String toString() {
    return 'Chat{messages: $messages}';
  }
}


class ChatMessage {

  final String userId;
  final String text;
  final String dateTime;


  ChatMessage(this.userId, this.text, this.dateTime);

  ChatMessage.fromMap(dynamic obj)
      : userId = obj['userId'],
        text = obj['text'],
        dateTime = obj['dateTime'];

  @override
  String toString() {
    return 'ChatMessage{userId: $userId, text: $text}';
  }
}
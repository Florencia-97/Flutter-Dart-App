
class Chat {

  final List<ChatMessage> messages;

  Chat(this.messages);
}


class ChatMessage {

  final String userId;
  final String text;

  ChatMessage(this.userId, this.text);

  ChatMessage.fromMap(dynamic obj)
      : userId = obj['userId'],
        text = obj['message'];
}
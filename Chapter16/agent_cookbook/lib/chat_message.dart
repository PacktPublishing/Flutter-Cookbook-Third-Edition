enum MessageType {
  user,
  plan,
  toolCall,
  toolResult,
  reflect,
  response,
  error,
}

class ChatMessage {
  final MessageType type;
  final String text;

  /// A decoded UI node tree, when the reply is rendered as UI.
  final Map<String, dynamic>? tree;

  const ChatMessage({
    required this.type,
    required this.text,
    this.tree,
  });
}

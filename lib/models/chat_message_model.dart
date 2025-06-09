```dart
enum MessageType {
  text,
  image,
  video,
  audio,
  // Add other types as needed (e.g., file, location)
}

class ChatMessageModel {
  final String messageId;
  final String senderId; // Corresponds to UserModel.userId
  final String threadId; // Corresponds to ChatThreadModel.threadId
  final String text; // For text messages
  final DateTime timestamp;
  final MessageType type;
  final String? mediaUrl; // For image, video, audio messages
  final bool? isRead; // Optional: for read receipts

  ChatMessageModel({
    required this.messageId,
    required this.senderId,
    required this.threadId,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text, // Default to text
    this.mediaUrl,
    this.isRead,
  });

  // Example: Factory constructor for creating a new ChatMessageModel instance from a map
  factory ChatMessageModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ChatMessageModel(
      messageId: documentId,
      senderId: data['senderId'] ?? '',
      threadId: data['threadId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as dynamic)?.toDate() ?? DateTime.now(), // Handle Firestore Timestamp
      type: MessageType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => MessageType.text,
      ),
      mediaUrl: data['mediaUrl'],
      isRead: data['isRead'],
    );
  }

  // Example: Method to convert ChatMessageModel instance to a map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'threadId': threadId,
      'text': text,
      'timestamp': timestamp, // Will be converted to Firestore Timestamp server-side or via FieldValue
      'type': type.toString(),
      'mediaUrl': mediaUrl,
      'isRead': isRead,
    };
  }
}
```

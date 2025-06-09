```dart
// MessageType enum needs to be defined or imported if not already in this file
enum MessageType {
  text,
  image, // Assumes mediaUrl field would store the image URL
  video, // Assumes mediaUrl field
  audio, // Assumes mediaUrl field
  system, // For system messages like "User X joined the group"
  productRecommendationCard, // For the specific rich card from user's example
  custom, // For other generic structured content
  // Add other types as needed (e.g., file, location)
}

class ChatMessageModel {
  final String messageId;
  final String threadId;
  final String senderId; // Corresponds to UserModel.userId
  final String? text; // Nullable if messageType is not text
  final DateTime timestamp;
  final MessageType type;

  final String? mediaUrl; // For image, video, audio messages
  final Map<String, dynamic>? structuredContent; // For rich message types like product cards or other custom JSON

  // Optional fields for display or interaction
  final bool? isRead; // For read receipts (client-side might not set this, backend would)
  final String? senderDisplayName; // Denormalized, useful for quick display in notifications or if UserModel is not readily available
  final String? senderAvatarUrl;   // Denormalized

  ChatMessageModel({
    required this.messageId,
    required this.threadId,
    required this.senderId,
    this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.mediaUrl,
    this.structuredContent,
    this.isRead,
    this.senderDisplayName, // Optional: for convenience
    this.senderAvatarUrl,   // Optional: for convenience
  }) {
    // Ensure text is provided if type is text and no structured content is defining the message
    if (type == MessageType.text && (text == null || text!.isEmpty) && structuredContent == null) {
      // throw ArgumentError('Text cannot be null or empty for text messages if no structuredContent is provided.');
      // Or assign a default, though an error is better during development.
      // For conceptual, we might allow it for now, but real app needs validation.
    }
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> data, String documentId) {
    String typeString = data['type']?.toString() ?? 'text';
    MessageType messageType = MessageType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == typeString.toLowerCase(),
      orElse: () => MessageType.text,
    );

    return ChatMessageModel(
      messageId: documentId,
      threadId: data['threadId'] ?? '',
      senderId: data['senderId'] ?? '',
      text: data['text'],
      timestamp: (data['timestamp'] as dynamic)?.toDate() ?? DateTime.now(), // Handle Firestore Timestamp or similar
      type: messageType,
      mediaUrl: data['mediaUrl'],
      structuredContent: data['structuredContent'] != null ? Map<String, dynamic>.from(data['structuredContent']) : null,
      isRead: data['isRead'],
      senderDisplayName: data['senderDisplayName'],
      senderAvatarUrl: data['senderAvatarUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // messageId is often the document ID, not stored in the map itself by Firestore/MongoDB
      'threadId': threadId,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp, // Firestore FieldValue.serverTimestamp() or DateTime for other DBs
      'type': type.toString().split('.').last, // Store enum value as string
      'mediaUrl': mediaUrl,
      'structuredContent': structuredContent,
      'isRead': isRead,
      'senderDisplayName': senderDisplayName,
      'senderAvatarUrl': senderAvatarUrl,
    };
  }
}
```

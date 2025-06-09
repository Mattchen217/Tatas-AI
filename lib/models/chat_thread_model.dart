```dart
import './chat_message_model.dart'; // To potentially hold the last message object

class ChatThreadModel {
  final String threadId;
  final List<String> participantIds; // List of UserModel.userId
  final ChatMessageModel? lastMessage; // The most recent message in the thread
  final int unreadCount; // Number of unread messages for the current user in this thread
  final DateTime? lastActivity; // Timestamp of the last message or thread update
  final String? threadName; // Optional: for group chats
  final String? threadAvatarUrl; // Optional: for group chat avatars

  ChatThreadModel({
    required this.threadId,
    required this.participantIds,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastActivity,
    this.threadName,
    this.threadAvatarUrl,
  });

  // Example: Factory constructor for creating a new ChatThreadModel instance from a map
  factory ChatThreadModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ChatThreadModel(
      threadId: documentId,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      // lastMessage might be a sub-collection or a denormalized map
      lastMessage: data['lastMessage'] != null
          ? ChatMessageModel.fromMap(data['lastMessage'] as Map<String, dynamic>, data['lastMessage']['messageId'] ?? '')
          : null,
      unreadCount: data['unreadCount'] ?? 0,
      lastActivity: (data['lastActivity'] as dynamic)?.toDate(), // Handle Firestore Timestamp
      threadName: data['threadName'],
      threadAvatarUrl: data['threadAvatarUrl'],
    );
  }

  // Example: Method to convert ChatThreadModel instance to a map
  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      // lastMessage might be handled differently (e.g., updated via a cloud function)
      'lastMessage': lastMessage?.toMap(),
      'unreadCount': unreadCount,
      'lastActivity': lastActivity, // Or FieldValue.serverTimestamp()
      'threadName': threadName,
      'threadAvatarUrl': threadAvatarUrl,
    };
  }
}
```

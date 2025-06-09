```dart
import 'package:flutter/material.dart'; // For Color type
import './chat_message_model.dart';
import './user_model.dart'; // For participant details if needed directly

class ChatThreadModel {
  final String threadId;
  final List<String> participantIds; // List of UserModel.userId
  final ChatMessageModel? lastMessage;
  final int unreadCount;
  final DateTime? lastActivity;

  // Group-specific fields
  final String? groupName; // Used if isGroup is true
  final String? groupAvatarUrl;
  final bool isGroup;

  // Client-side display helpers
  final String? clientSideAvatarColorHex; // Hex string for color

  ChatThreadModel({
    required this.threadId,
    required this.participantIds,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastActivity,
    this.groupName,
    this.groupAvatarUrl,
    required this.isGroup,
    this.clientSideAvatarColorHex,
  });

  // Client-side helper to get display name for 1-on-1 chat or group name
  // Requires access to current user's ID and potentially a list of users to find partner's name
  String getDisplayName(String currentUserId, List<UserModel> allUsers) {
    if (isGroup) {
      return groupName ?? 'Unnamed Group';
    } else {
      // Find the other participant
      final otherParticipantId = participantIds.firstWhere((id) => id != currentUserId, orElse: () => '');
      if (otherParticipantId.isNotEmpty) {
        final otherUser = allUsers.firstWhere((user) => user.userId == otherParticipantId,
                              orElse: () => UserModel(userId: '', displayName: 'Unknown User')); // Fallback
        return otherUser.displayName;
      }
      return 'Unknown Chat';
    }
  }

  // Client-side helper for avatar color (for group or 1-on-1 if no user avatar)
  Color getDisplayAvatarColor(BuildContext context) {
    if (clientSideAvatarColorHex != null && clientSideAvatarColorHex!.isNotEmpty) {
      try {
        return Color(int.parse(clientSideAvatarColorHex!.replaceFirst('#', '0xff')));
      } catch (e) { /* fallback */ }
    }
    // Generate a color based on threadId or groupName hash for consistency
    final String nameSource = (isGroup ? groupName : threadId) ?? threadId;
    final hash = nameSource.hashCode;
    return Colors.primaries[hash % Colors.primaries.length].withOpacity(0.8);
  }

  String getAvatarInitials(BuildContext context, String currentUserId, List<UserModel> allUsers) {
    String name = getDisplayName(currentUserId, allUsers);
    if (name.isEmpty) return "?";
    if (isGroup && groupName != null && groupName!.isNotEmpty) return groupName![0].toUpperCase();

    List<String> nameParts = name.split(" ").where((part) => part.isNotEmpty).toList();
    if (nameParts.isEmpty) return "?";
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts.last[0].toUpperCase();
    }
    return nameParts[0][0].toUpperCase();
  }


  factory ChatThreadModel.fromMap(Map<String, dynamic> data, String documentId) {
    ChatMessageModel? lastMsg;
    if (data['lastMessage'] != null && data['lastMessage'] is Map) {
        // Assuming lastMessage map might not have a messageId if it's directly embedded
        // Or it might. Adjust based on actual backend structure.
        // For now, let's assume it's a full ChatMessageModel map.
        lastMsg = ChatMessageModel.fromMap(data['lastMessage'] as Map<String, dynamic>, data['lastMessage']['messageId'] ?? '');
    }

    return ChatThreadModel(
      threadId: documentId,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      lastMessage: lastMsg,
      unreadCount: data['unreadCount'] ?? 0,
      lastActivity: (data['lastActivity'] as dynamic)?.toDate(), // Handle Firestore Timestamp or similar
      groupName: data['groupName'],
      groupAvatarUrl: data['groupAvatarUrl'],
      isGroup: data['isGroup'] ?? (data['groupName'] != null || (List<String>.from(data['participantIds'] ?? [])).length > 2), // Infer if not provided
      clientSideAvatarColorHex: data['clientSideAvatarColorHex'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'lastMessage': lastMessage?.toMap(), // Assuming ChatMessageModel has toMap()
      'unreadCount': unreadCount,
      'lastActivity': lastActivity, // Or FieldValue.serverTimestamp()
      'groupName': groupName,
      'groupAvatarUrl': groupAvatarUrl,
      'isGroup': isGroup,
      'clientSideAvatarColorHex': clientSideAvatarColorHex,
    };
  }
}
```

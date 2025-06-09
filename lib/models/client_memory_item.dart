```dart
import 'package:flutter/material.dart'; // For IconData if we want to map type to icon

class ClientMemoryItem {
  final String id;
  final String title;
  final String contentSnippet;
  final DateTime date;
  final String type; // e.g., "Conversation Summary", "User Fact", "Learned Preference"
  final IconData? icon; // Optional: client-side icon based on type

  ClientMemoryItem({
    required this.id,
    required this.title,
    required this.contentSnippet,
    required this.date,
    required this.type,
    this.icon,
  });

  // Example factory from a more complex PMS MemoryItem map (conceptual)
  factory ClientMemoryItem.fromPmsMap(Map<String, dynamic> pmsMap) {
    String typeDisplay = pmsMap['type'] ?? 'Memory';
    IconData iconData = Icons.memory_outlined; // Default icon
    switch (typeDisplay.toLowerCase()) {
      case 'user_fact':
        typeDisplay = 'User Fact';
        iconData = Icons.fact_check_outlined;
        break;
      case 'conversation_summary':
        typeDisplay = 'Conversation Summary';
        iconData = Icons.chat_bubble_outline;
        break;
      case 'learned_preference':
        typeDisplay = 'Learned Preference';
        iconData = Icons.rule_outlined;
        break;
      case 'key_entity':
         typeDisplay = 'Key Entity';
        iconData = Icons.bookmark_border_outlined;
        break;
    }

    return ClientMemoryItem(
      id: pmsMap['memoryId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: pmsMap['title'] ?? pmsMap['contentText']?.substring(0, min(30, pmsMap['contentText']?.length ?? 0)) ?? 'Untitled Memory',
      contentSnippet: pmsMap['contentText'] ?? 'No content preview available.',
      // Assuming date is stored as ISO string or Firestore Timestamp in PMS
      date: pmsMap['createdAt'] != null ? (pmsMap['createdAt'] as dynamic)?.toDate() ?? DateTime.parse(pmsMap['createdAt']) : DateTime.now(),
      type: typeDisplay,
      icon: iconData,
    );
  }
}
```

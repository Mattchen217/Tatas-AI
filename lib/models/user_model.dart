```dart
import 'package:flutter/material.dart'; // For Color type

class UserModel {
  final String userId;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  // avatarColor is often derived on the client-side if not provided by backend
  // It's not typically part of the core backend UserModel but can be a display property.
  // For consistency, if the backend *could* suggest a color, it can be here.
  final String? avatarColorHex; // e.g., "#FF5733"

  UserModel({
    required this.userId,
    required this.displayName,
    this.email,
    this.avatarUrl,
    this.avatarColorHex,
  });

  // Client-side helper to get the display avatar color
  Color get displayAvatarColor {
    if (avatarColorHex != null && avatarColorHex!.isNotEmpty) {
      try {
        return Color(int.parse(avatarColorHex!.replaceFirst('#', '0xff')));
      } catch (e) {
        // fallback to default if hex is invalid
      }
    }
    // Generate a color based on userId or displayName hash for consistency
    // This is a simple example; more sophisticated hashing can be used.
    final hash = userId.hashCode ^ displayName.hashCode;
    return Colors.primaries[hash % Colors.primaries.length].withOpacity(0.8);
  }

  String get initials {
    if (displayName.isEmpty) return "?";
    List<String> nameParts = displayName.split(" ").where((part) => part.isNotEmpty).toList();
    if (nameParts.isEmpty) return "?";
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts.last[0].toUpperCase();
    }
    return nameParts[0][0].toUpperCase();
  }

  // Example: Factory constructor for creating a new UserModel instance from a map
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      userId: documentId, // Assuming documentId from DB is the userId
      displayName: data['displayName'] ?? 'Unknown User',
      email: data['email'],
      avatarUrl: data['avatarUrl'],
      avatarColorHex: data['avatarColorHex'],
    );
  }

  // Example: Method to convert UserModel instance to a map
  Map<String, dynamic> toMap() {
    return {
      // userId is often the document ID in Firestore/MongoDB, so not always in the map
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'avatarColorHex': avatarColorHex,
    };
  }
}
```

```dart
class UserModel {
  final String userId;
  final String displayName;
  final String? avatarUrl; // Nullable if user might not have an avatar
  final String? email; // Optional, depending on auth method

  UserModel({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.email,
  });

  // Example: Factory constructor for creating a new UserModel instance from a map (e.g., from Firestore)
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      userId: documentId,
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'],
      email: data['email'],
    );
  }

  // Example: Method to convert UserModel instance to a map (e.g., for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'email': email,
      // userId is typically the document ID, so not stored as a field in the document
    };
  }
}
```

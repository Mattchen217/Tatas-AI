```dart
import 'package:flutter/material.dart';

class ContactItemWidget extends StatelessWidget {
  final String name;
  final String? status; // e.g., "Online", "Offline", "Last seen..."
  final Color avatarColor; // Or String avatarUrl
  final VoidCallback onTap;

  const ContactItemWidget({
    Key? key,
    required this.name,
    this.status,
    required this.avatarColor, // Replace with avatarUrl if using images
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    if (status?.toLowerCase() == 'online') {
      statusColor = Colors.green.shade600;
    } else if (status?.toLowerCase() == 'offline') {
      statusColor = Colors.grey.shade400;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        // backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: status != null
          ? Text(
              status!,
              style: TextStyle(fontSize: 12, color: statusColor),
            )
          : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]), // Or an action button like "Chat"
      onTap: onTap,
    );
  }
}
```

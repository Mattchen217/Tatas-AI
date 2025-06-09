```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ChatItemWidget extends StatelessWidget {
  final String name;
  final String lastMessage;
  final DateTime time;
  final Color avatarColor; // Or String avatarUrl
  final bool isGroup;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatItemWidget({
    Key? key,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarColor, // Replace with avatarUrl if using images
    this.isGroup = false,
    this.unreadCount = 0,
    required this.onTap,
  }) : super(key: key);

  String _formatTimestamp(DateTime ts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (ts.year == today.year && ts.month == today.month && ts.day == today.day) {
      return DateFormat('HH:mm').format(ts); // e.g., 10:30
    } else if (ts.year == yesterday.year && ts.month == yesterday.month && ts.day == yesterday.day) {
      return 'Yesterday';
    } else if (ts.year == now.year) {
      return DateFormat('MMM d').format(ts); // e.g., Oct 28
    } else {
      return DateFormat('yyyy/MM/dd').format(ts); // e.g., 2022/10/28
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: avatarColor,
        // backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : (isGroup ? 'G' : '?'),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            _formatTimestamp(time),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 4.0),
          if (unreadCount > 0)
            Container(
              padding: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : unreadCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold),
              ),
            )
          else
            SizedBox(height: 16), // To maintain alignment if no badge
        ],
      ),
      onTap: onTap,
    );
  }
}
```

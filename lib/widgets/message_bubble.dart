```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting - add to pubspec.yaml conceptually
import '../models/chat_message_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isCurrentUser;
  final String? senderDisplayName; // New parameter for group chats

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.senderDisplayName, // Initialize
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isCurrentUser ? Theme.of(context).primaryColor.withAlpha(200) : Colors.grey[300];
    final textColor = isCurrentUser ? Colors.white : Colors.black87;
    final nameColor = isCurrentUser ? Colors.white70 : Theme.of(context).primaryColorDark;

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: isCurrentUser ? Radius.circular(16) : Radius.circular(0),
      bottomRight: isCurrentUser ? Radius.circular(0) : Radius.circular(16),
    );

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (senderDisplayName != null && !isCurrentUser) // Display sender's name for group messages
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  senderDisplayName!,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: nameColor, // Or a specific color for names
                  ),
                ),
              ),
            if (message.type == MessageType.text)
              Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 16.0),
              )
            else if (message.type == MessageType.image && message.mediaUrl != null)
              Image.network(
                message.mediaUrl!,
                height: 150,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(height: 150, child: Center(child: CircularProgressIndicator()));
                },
                errorBuilder: (context, error, stacktrace) =>
                    Container(height: 150, child: Center(child: Icon(Icons.broken_image, color: textColor.withOpacity(0.7)))),
              )
            else
              Text(
                '[Unsupported message type]',
                style: TextStyle(color: textColor.withOpacity(0.7), fontStyle: FontStyle.italic),
              ),
            SizedBox(height: 4.0),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

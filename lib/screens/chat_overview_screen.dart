```dart
import 'package:flutter/material.dart';
// import './individual_chat_screen.dart'; // Will be used for navigation

class ChatOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: ListView.builder(
        itemCount: 10, // Placeholder for actual chat threads
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              // Placeholder for contact avatar
              child: Icon(Icons.person_outline),
            ),
            title: Text('Chat Contact ${index + 1}'),
            subtitle: Text('Last message snippet...'),
            trailing: Text('10:00 AM'), // Placeholder for timestamp
            onTap: () {
              // TODO: Navigate to IndividualChatScreen
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => IndividualChatScreen(chatId: 'some_chat_id_${index + 1}'),
              //   ),
              // );
              print('Navigate to chat with Contact ${index + 1}');
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to a screen to start a new chat
          print('New chat FAB pressed');
        },
        child: Icon(Icons.add_comment_outlined),
      ),
    );
  }
}
```

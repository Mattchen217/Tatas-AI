```dart
import 'package:flutter/material.dart';
// import './individual_chat_screen.dart'; // Will be used for navigation

class FriendsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
      ),
      body: ListView.builder(
        itemCount: 15, // Placeholder for actual friends list
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              // Placeholder for friend's avatar
              child: Icon(Icons.person_outline),
            ),
            title: Text('Friend ${index + 1}'),
            trailing: IconButton(
              icon: Icon(Icons.chat_bubble_outline),
              onPressed: () {
                // TODO: Navigate to IndividualChatScreen with this friend
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => IndividualChatScreen(userId: 'friend_id_${index + 1}'),
                //   ),
                // );
                print('Chat with Friend ${index + 1}');
              },
            ),
            onTap: () {
              // TODO: Navigate to Friend's profile screen (optional)
              print('View profile of Friend ${index + 1}');
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to a screen to add new friends
          print('Add new friend FAB pressed');
        },
        child: Icon(Icons.person_add_alt_1_outlined),
      ),
    );
  }
}
```

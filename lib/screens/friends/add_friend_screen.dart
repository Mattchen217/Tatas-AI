```dart
import 'package:flutter/material.dart';
import '../../services/friend_service.dart'; // Will be created later
import '../../models/user_model.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FriendService _friendService = FriendService();
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String _searchMessage = '';

  Future<void> _searchUsers() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchMessage = 'Please enter a search query.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _searchMessage = '';
    });
    try {
      final results = await _friendService.searchUsers(_searchController.text.trim());
      setState(() {
        _searchResults = results;
        if (results.isEmpty) {
          _searchMessage = 'No users found.';
        }
      });
    } catch (e) {
      setState(() {
        _searchMessage = 'Error searching users: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addFriend(String userId) async {
    // In a real app, you might want to disable the button or show a loading indicator per item
    print('Attempting to add friend: $userId');
    bool success = await _friendService.addFriend(userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend added successfully (simulated)!')),
      );
      // Optionally, refresh search results or mark as added
      // For simplicity, we might just pop or let user search again
      // Consider updating the state of the specific user in _searchResults if needed
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add friend (simulated).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by username or email...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchUsers(),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchUsers,
                ),
              ],
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          if (_searchMessage.isNotEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_searchMessage),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    // backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null ? Icon(Icons.person_outline) : null,
                  ),
                  title: Text(user.displayName),
                  subtitle: Text(user.email ?? 'No email'), // Display email if available
                  trailing: ElevatedButton(
                    onPressed: () {
                      _addFriend(user.userId);
                    },
                    child: Text('Add'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

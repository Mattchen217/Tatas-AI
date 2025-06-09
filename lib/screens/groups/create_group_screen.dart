```dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/friend_service.dart'; // To get list of friends to select from
import '../../services/chat_service.dart';   // To create the group chat

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupNameController = TextEditingController();
  final FriendService _friendService = FriendService();
  final ChatService _chatService = ChatService(); // Conceptual

  List<UserModel> _friends = [];
  Map<String, bool> _selectedFriends = {}; // Using a Map to track selection: userId -> isSelected
  bool _isLoadingFriends = true;
  bool _isCreatingGroup = false;

  // Conceptual: Current user's ID, normally from AuthService
  final String _currentUserId = 'currentUser123';

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _isLoadingFriends = true;
    });
    try {
      final friendsList = await _friendService.getFriends();
      setState(() {
        _friends = friendsList;
        _friends.forEach((friend) {
          _selectedFriends[friend.userId] = false; // Initialize all as unselected
        });
        _isLoadingFriends = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFriends = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load friends: $e')),
      );
    }
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final List<String> selectedMemberIds = _selectedFriends.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one member for the group.')),
      );
      return;
    }

    // Add current user to the group automatically
    if (!_selectedFriends.containsKey(_currentUserId)) {
         selectedMemberIds.add(_currentUserId);
    }


    setState(() {
      _isCreatingGroup = true;
    });

    try {
      // Conceptual: In a real app, ChatService.createGroupChat would return the new ChatThreadModel or its ID
      // For now, it's a Future<ChatThreadModel> in definition, but we'll treat it as success/failure
      final newGroupThread = await _chatService.createGroupChat(
        _groupNameController.text.trim(),
        selectedMemberIds,
        // conceptualGroupAvatarUrl: "some_url_if_implemented"
      );

      setState(() {
        _isCreatingGroup = false;
      });

      if (newGroupThread != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group "${newGroupThread.threadName}" created successfully!')),
        );
        // TODO: Navigate to the new group chat screen or back to chat overview
        // For example:
        // Navigator.of(context).pop(); // Go back
        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //   builder: (context) => IndividualChatScreen(
        //     chatId: newGroupThread.threadId,
        //     chatParticipantName: newGroupThread.threadName ?? 'Group Chat',
        //   ),
        // ));
        Navigator.of(context).pop(true); // Pop and indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group.')),
        );
      }
    } catch (e) {
      setState(() {
        _isCreatingGroup = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating group: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Group'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group_work_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Select Members:', style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            Expanded(
              child: _isLoadingFriends
                  ? Center(child: CircularProgressIndicator())
                  : _friends.isEmpty
                      ? Center(child: Text('No friends available to add.'))
                      : ListView.builder(
                          itemCount: _friends.length,
                          itemBuilder: (context, index) {
                            final friend = _friends[index];
                            return CheckboxListTile(
                              title: Text(friend.displayName),
                              subtitle: Text(friend.email ?? 'No email'),
                              secondary: CircleAvatar(
                                child: Icon(Icons.person_outline), // Placeholder for avatar
                              ),
                              value: _selectedFriends[friend.userId],
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedFriends[friend.userId] = value ?? false;
                                });
                              },
                            );
                          },
                        ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: _isCreatingGroup
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createGroup,
                      child: Text('Create Group'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
```

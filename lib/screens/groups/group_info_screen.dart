```dart
import 'package:flutter/material.dart';
import '../../models/chat_thread_model.dart';
import '../../models/user_model.dart';
import '../../services/chat_service.dart'; // For group management actions
import '../../services/user_service.dart'; // Conceptual: For fetching user details by ID

class GroupInfoScreen extends StatefulWidget {
  final String threadId; // ID of the group chat thread

  // We'd also need to fetch the ChatThreadModel or pass it.
  // For simplicity, let's assume we fetch it or already have parts of it.
  // final ChatThreadModel groupThread;

  const GroupInfoScreen({Key? key, required this.threadId}) : super(key: key);

  @override
  _GroupInfoScreenState createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService(); // Conceptual service

  // State variables
  ChatThreadModel? _groupThread; // To hold full group details
  List<UserModel> _members = [];
  bool _isLoading = true;
  // String _currentUserId = 'currentUser123'; // From AuthService

  @override
  void initState() {
    super.initState();
    _loadGroupDetails();
  }

  Future<void> _loadGroupDetails() async {
    setState(() { _isLoading = true; });
    try {
      // 1. Fetch the group thread details (including participant IDs)
      // This method might need to be added to ChatService or assumed to be part of a more complex getThreadById
      // For now, we'll simulate it or assume ChatService can provide it.
      // _groupThread = await _chatService.getChatThreadDetails(widget.threadId); // Conceptual

      // Simulate fetching group details
      _groupThread = await _chatService.getGroupThreadDetails(widget.threadId);


      if (_groupThread != null) {
        // 2. Fetch UserModel for each participantId
        final memberDetails = <UserModel>[];
        for (String userId in _groupThread!.participantIds) {
          try {
            final user = await _userService.getUserById(userId); // Conceptual
            if (user != null) {
              memberDetails.add(user);
            }
          } catch (e) {
            print("Failed to fetch user $userId: $e");
            // Add a placeholder or skip if a user can't be fetched
            memberDetails.add(UserModel(userId: userId, displayName: "Unknown User ($userId)"));
          }
        }
        setState(() {
          _members = memberDetails;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load group details: $e')),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _leaveGroup() async {
    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Leave Group'),
          content: Text('Are you sure you want to leave "${_groupThread?.threadName ?? 'this group'}"?'),
          actions: <Widget>[
            TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
            TextButton(child: Text('Leave'), style: TextButton.styleFrom(foregroundColor: Colors.red), onPressed: () => Navigator.of(context).pop(true)),
          ],
        );
      },
    );

    if (confirm == true) {
      print('Leaving group: ${widget.threadId}');
      // TODO: Call ChatService method to leave group
      // bool success = await _chatService.leaveGroup(widget.threadId, _currentUserId);
      // if (success) {
      //   Navigator.of(context).popUntil((route) => route.isFirst); // Go back to ChatOverview
      // } else { ... show error ... }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Left group (simulated)')));
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(appBar: AppBar(title: Text('Group Info')), body: Center(child: CircularProgressIndicator()));
    }

    if (_groupThread == null) {
      return Scaffold(appBar: AppBar(title: Text('Group Info')), body: Center(child: Text('Group not found.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_groupThread!.threadName ?? 'Group Details'),
        actions: [
          // IconButton(icon: Icon(Icons.edit), onPressed: () { /* TODO: Edit group name/avatar */ }),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  // backgroundImage: _groupThread!.threadAvatarUrl != null ? NetworkImage(_groupThread!.threadAvatarUrl!) : null,
                  child: _groupThread!.threadAvatarUrl == null ? Icon(Icons.group, size: 50) : null,
                ),
                SizedBox(height: 12),
                Text(
                  _groupThread!.threadName ?? 'Unnamed Group',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('${_members.length} members'),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.group_add_outlined),
            title: Text('Add Members'),
            onTap: () {
              // TODO: Navigate to a screen to select and add new members
              print('Add members tapped');
              // Navigator.push(context, MaterialPageRoute(builder: (_) => AddMembersToGroupScreen(threadId: widget.threadId)));
            },
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Members', style: Theme.of(context).textTheme.titleMedium),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // As it's inside another ListView
            itemCount: _members.length,
            itemBuilder: (context, index) {
              final member = _members[index];
              return ListTile(
                leading: CircleAvatar(
                  // backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                  child: member.avatarUrl == null ? Icon(Icons.person_outline) : null,
                ),
                title: Text(member.displayName),
                subtitle: Text(member.email ?? member.userId),
                // trailing: (member.userId == _currentUserId)
                //     ? Text('(You)')
                //     : IconButton(icon: Icon(Icons.more_vert), onPressed: () { /* TODO: Admin options e.g. remove user */}) ,
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text('Leave Group', style: TextStyle(color: Colors.red)),
            onTap: _leaveGroup,
          ),
        ],
      ),
    );
  }
}

// Conceptual UserService (would be in lib/services/user_service.dart)
class UserService {
  // Simulated user data store
  final Map<String, UserModel> _users = {
    'currentUser123': UserModel(userId: 'currentUser123', displayName: 'Me', email: 'me@example.com'),
    'friend_user_id_1': UserModel(userId: 'friend_user_id_1', displayName: 'Alice W.', email: 'alice@example.com'),
    'user1': UserModel(userId: 'user1', displayName: 'Alice Wonderland', email: 'alice@example.com'),
    'user2': UserModel(userId: 'user2', displayName: 'Bob The Builder', email: 'bob@example.com'),
    'friend2': UserModel(userId: 'friend2', displayName: 'Grace Hopper', email: 'grace@example.com'),
     // Add more users as needed by participantIds in ChatThreadModel
  };

  Future<UserModel?> getUserById(String userId) async {
    await Future.delayed(Duration(milliseconds: 100)); // Simulate network delay
    return _users[userId];
  }
}
```

```dart
import 'package:flutter/material.dart';
// Conceptual placeholder screens for navigation targets
// These would be defined in their own files in a real app.

class EditProfileScreen extends StatelessWidget { // Placeholder
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Edit Personal Profile')), body: Center(child: Text('Profile Editing Page')));
}
class AccountSecurityScreen extends StatelessWidget { // Placeholder
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Account Security')), body: Center(child: Text('Account Security Settings')));
}
class YouthModeScreen extends StatelessWidget { // Placeholder
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Youth Mode')), body: Center(child: Text('Youth Mode Settings')));
}
class CareModeScreen extends StatelessWidget { // Placeholder
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Care Mode')), body: Center(child: Text('Care Mode Settings')));
}
class NotificationSettingsScreen extends StatelessWidget { // Placeholder
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Notification Settings')), body: Center(child: Text('Notification Preferences')));
}
class DeviceLinkingScreen extends StatelessWidget { // Placeholder
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('Device Linking')), body: Center(child: Text('Manage Linked Devices')));
}
class GeneralSettingsScreen extends StatelessWidget { // Placeholder
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('General Settings')), body: Center(child: Text('General App Settings')));
}
// --- End Placeholder Screens ---

// ProfileMenuItemWidget (Helper Widget)
class ProfileMenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const ProfileMenuItemWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      onTap: onTap,
    );
  }
}
// --- End ProfileMenuItemWidget ---


class MyProfilePage extends StatelessWidget { // Can be StatefulWidget if profile data is fetched dynamically
  // Conceptual user data
  final String userName = "Tatas AI User";
  final String userEmail = "user@example.tatas.ai";
  final String userAvatarUrl = "https://via.placeholder.com/150/007bff/FFFFFF?Text=U"; // Placeholder

  // Conceptual logout function (would call AuthService)
  void _logout(BuildContext context) {
    // context.read<AuthService>().logout();
    // AuthWrapper in main.dart would handle navigation to LoginScreen
    print("Logout action triggered");
    // For now, simulate by just showing a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logout action triggered (conceptual)."))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        // elevation: 0, // Flat appbar
      ),
      body: ListView(
        children: <Widget>[
          // User Info Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(userAvatarUrl),
                  child: userAvatarUrl.isEmpty ? Text(userName.isNotEmpty ? userName[0] : 'U', style: TextStyle(fontSize: 30)) : null,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.grey[600]),
                  tooltip: 'Edit Profile',
                  onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen()));
                  },
                )
              ],
            ),
          ),

          // Menu Items Section
          // Divider(thickness: 8, color: Colors.grey[100]), // Section divider

          ProfileMenuItemWidget(
            icon: Icons.person_pin_outlined,
            title: 'Personal资料 (Profile)',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen())),
          ),
          ProfileMenuItemWidget(
            icon: Icons.security_outlined,
            title: '账号安全 (Account Security)',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AccountSecurityScreen())),
          ),

          SizedBox(height: 8), // Spacer for sectioning
          Divider(),
          SizedBox(height: 8),

          ProfileMenuItemWidget(
            icon: Icons.child_friendly_outlined, // Example, might need custom icon for "未成年人"
            title: '未成年人模式 (Youth Mode)',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => YouthModeScreen())),
          ),
          ProfileMenuItemWidget(
            icon: Icons.accessibility_new_outlined, // Example for "关怀模式"
            title: '关怀模式 (Care Mode)',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CareModeScreen())),
          ),

          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 8),

          ProfileMenuItemWidget(
            icon: Icons.notifications_active_outlined,
            title: '消息通知 (Notifications)',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationSettingsScreen())),
          ),
          ProfileMenuItemWidget(
            icon: Icons.devices_other_outlined,
            title: '设备链接 (Device Linking)',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeviceLinkingScreen())),
          ),
          ProfileMenuItemWidget(
            icon: Icons.tune_outlined,
            title: '通用 (General Settings)',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GeneralSettingsScreen())),
          ),

          SizedBox(height: 8),
          Divider(),
          SizedBox(height: 8),

          ProfileMenuItemWidget(
            icon: Icons.logout_outlined,
            title: 'Logout',
            iconColor: Colors.red.shade700,
            textColor: Colors.red.shade700,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
```

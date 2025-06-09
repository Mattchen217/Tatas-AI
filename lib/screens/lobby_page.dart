```dart
import 'package:flutter/material.dart';

class LobbyPage extends StatefulWidget {
  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Titles for the tabs
  final List<String> _tabs = ["Follow", "Recommended", "Hot Topics", "Discover", "Ads"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby'),
        // In a real app, the AppBar might be part of the TabBar system
        // or a custom header might be used if search/actions are needed here.
        // For now, a simple AppBar and the TabBar below it.
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true, // Allows tabs to scroll horizontally if many
          tabs: _tabs.map((String title) => Tab(text: title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((String title) {
          // Each child is the content for a tab
          return _buildLobbyTabContent(title);
        }).toList(),
      ),
    );
  }

  // Conceptual content for each lobby tab
  Widget _buildLobbyTabContent(String tabTitle) {
    // In a real app, each tab would likely have its own widget and data fetching logic.
    // This is a simplified placeholder.
    return ListView.builder(
      key: PageStorageKey(tabTitle), // Preserve scroll position for each tab
      itemCount: 15, // Placeholder for 15 items per tab
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$tabTitle - Item Title ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                if (tabTitle != "Ads") // Ads might have a different layout
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(6.0),
                      image: DecorationImage(
                        image: NetworkImage('https://picsum.photos/seed/${tabTitle.hashCode + index}/500/250'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (tabTitle == "Ads") // Example of different layout for Ads
                  Container(
                     padding: EdgeInsets.all(10),
                     color: Colors.blueGrey[50],
                     child: Row(children: [
                       Icon(Icons.campaign_outlined, color: Colors.blueGrey[700]),
                       SizedBox(width: 10),
                       Expanded(child: Text("Promotional Content ${index + 1}", style: TextStyle(color: Colors.blueGrey[800]))),
                     ]),
                  ),
                SizedBox(height: 8.0),
                Text(
                  'Short description for $tabTitle item ${index + 1}. Content here would vary based on the tab\'s purpose (e.g., user posts, articles, trends).',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Source/Author ${index +1}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    TextButton(
                      onPressed: () {
                        print('Interacting with $tabTitle Item ${index + 1}');
                      },
                      child: Text(tabTitle == "Ads" ? 'Learn More' : 'View'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/chat_message_model.dart'; // Assuming this model is updated for structured content
import '../../widgets/message_bubble.dart';   // Assuming this widget is updated for rich messages
// import '../../widgets/chat_input_bar_widget.dart'; // This will be defined in 1.6
import '../../services/ai/on_device_ai_service.dart';

// --- Conceptual ChatInputBar Widget (placeholder from IndividualChatScreen) ---
class ChatInputBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoidCallback? onAttachPressed;
  const ChatInputBarWidget({Key? key, required this.controller, required this.onSendPressed, this.onAttachPressed}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: MediaQuery.of(context).padding.bottom + 8.0, top: 8.0),
      color: Theme.of(context).cardColor,
      child: Row(children: <Widget>[
        if(onAttachPressed != null) IconButton(icon: Icon(Icons.add_photo_alternate_outlined), onPressed: onAttachPressed, tooltip: "Attach media"),
        Expanded(child: TextField(controller: controller, decoration: InputDecoration(hintText: 'Type a message...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide.none), filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor, contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0)), minLines: 1, maxLines: 5, textInputAction: TextInputAction.send, onSubmitted: (_) => onSendPressed())),
        SizedBox(width: 8.0),
        IconButton(icon: Icon(Icons.send_rounded), color: Theme.of(context).colorScheme.primary, onPressed: onSendPressed, tooltip: "Send message"),
      ]),
    );
  }
}
// --- End Conceptual ChatInputBar Widget ---

// --- Conceptual Product Recommendation Card Widget ---
// This would be in its own file: lib/widgets/product_recommendation_card_widget.dart
class ProductRecommendationCardItem {
  final String imageUrl;
  final String name;
  final String price;
  final List<String> features;
  final String productUrl; // For "View" button

  ProductRecommendationCardItem({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.features,
    required this.productUrl,
  });
}

class ProductRecommendationCardWidget extends StatelessWidget {
  final List<ProductRecommendationCardItem> products;

  const ProductRecommendationCardWidget({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return SizedBox.shrink();

    return Container(
      height: 280, // Adjust height as needed
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.only(left: index == 0 ? 16 : 8, right: index == products.length - 1 ? 16 : 0, top: 8, bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: 200, // Adjust card width
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(product.imageUrl, fit: BoxFit.cover, width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40),
                        loadingBuilder: (context, child, progress) => progress == null ? child : Center(child: CircularProgressIndicator(strokeWidth: 2))
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(product.name, style: TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(product.price, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  ...product.features.take(2).map((feature) => Text('• $feature', style: TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis,)),
                  Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () { /* TODO: Handle view product */ print('View ${product.name}'); }, child: Text('View')),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
// --- End Conceptual Product Recommendation Card Widget ---


class MyAIChatbotPage extends StatefulWidget {
  final String aiName;

  const MyAIChatbotPage({Key? key, this.aiName = "小她"}) : super(key: key); // Default AI name from user's code

  @override
  _MyAIChatbotPageState createState() => _MyAIChatbotPageState();
}

class _MyAIChatbotPageState extends State<MyAIChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final OnDeviceAiService _aiService = OnDeviceAiService();
  List<dynamic> _chatItems = []; // Can hold ChatMessageModel or DateTime for dividers
  bool _isAiTyping = false;

  static const String _currentUserId = 'user_self_chatbot';
  static const String _aiId = 'xiao_ta_ai_id';

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onInputChanged);
    _addInitialGreeting();
    // Simulate receiving a product recommendation for testing
    // _receiveProductRecommendation();
  }

  void _addInitialGreeting() {
     WidgetsBinding.instance.addPostFrameCallback((_) {
      _addMessageToUi(ChatMessageModel(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _aiId,
        threadId: 'local_ai_chatbot',
        text: '你好，我是${widget.aiName} ✨，你的专属数字生命伴侣。有什么可以帮助你的吗？',
        timestamp: DateTime.now(),
        type: MessageType.text,
      ));
    });
  }

  // Simulate receiving a product recommendation for testing purposes
  void _receiveProductRecommendation() {
     WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(seconds: 2)); // Simulate delay
      _addMessageToUi(ChatMessageModel(
        messageId: 'prod_rec_1',
        senderId: _aiId,
        threadId: 'local_ai_chatbot',
        text: "I found some products you might like:", // Optional accompanying text
        timestamp: DateTime.now(),
        type: MessageType.custom, // Or a new MessageType.productRecommendationCard
        structuredContent: {
          "cardType": "productRecommendation",
          "products": [
            {"imageUrl": "https://via.placeholder.com/150/FFA500/FFFFFF?Text=Product+1", "name": "智能手表 S1", "price": "¥1299", "features": ["心率监测", "GPS定位"], "productUrl": "..." },
            {"imageUrl": "https://via.placeholder.com/150/4CAF50/FFFFFF?Text=Product+2", "name": "蓝牙降噪耳机 X5", "price": "¥799", "features": ["主动降噪", "超长待机"], "productUrl": "..." },
            {"imageUrl": "https://via.placeholder.com/150/2196F3/FFFFFF?Text=Product+3", "name": "便携咖啡机 Mini", "price": "¥349", "features": ["USB充电", "易清洗"], "productUrl": "..." },
          ]
        }
      ));
    });
  }


  void _onInputChanged() {
    // Could be used to clear suggestions if user types, similar to other chat screens
  }

  void _addMessageToUi(ChatMessageModel message) {
    if(mounted){
      DateTime? lastDate;
      if (_chatItems.isNotEmpty) {
        var lastItem = _chatItems.first; // Since list is reversed for display
        if (lastItem is ChatMessageModel) {
          lastDate = DateTime(lastItem.timestamp.year, lastItem.timestamp.month, lastItem.timestamp.day);
        } else if (lastItem is DateTime) { // It's already a date divider
          lastDate = lastItem;
        }
      }

      final messageDate = DateTime(message.timestamp.year, message.timestamp.month, message.timestamp.day);
      if (lastDate == null || !(lastDate.year == messageDate.year && lastDate.month == messageDate.month && lastDate.day == messageDate.day)) {
         // If list is empty or new date, add new date divider first (for reversed list)
        if (_chatItems.isNotEmpty && lastDate != null && messageDate.isBefore(lastDate)) {
          // This logic is a bit off for reversed list.
          // Simpler: just add message, then re-process for dividers when building.
        }
      }
      setState(() {
        _chatItems.insert(0, message);
      });
    }
  }

  Future<void> _handleUserMessageSubmission() async {
    final userInputText = _messageController.text.trim();
    if (userInputText.isEmpty) return;

    final userMessage = ChatMessageModel(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      threadId: 'local_ai_chatbot',
      text: userInputText,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
    _addMessageToUi(userMessage);
    _messageController.clear();

    if(mounted) setState(() => _isAiTyping = true );
    try {
      final aiResponseText = await _aiService.getResponse(userInputText);
      final aiMessage = ChatMessageModel(
        messageId: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        senderId: _aiId,
        threadId: 'local_ai_chatbot',
        text: aiResponseText,
        timestamp: DateTime.now(),
        type: MessageType.text,
      );
      _addMessageToUi(aiMessage);
    } catch (e) { /* ... error handling ... */ }
    finally { if(mounted) setState(() => _isAiTyping = false ); }
  }

  List<dynamic> _getProcessedChatItems() {
    List<dynamic> items = [];
    DateTime? lastDate;
    // Iterate messages from oldest to newest to insert date dividers correctly
    for (var i = _chatItems.length - 1; i >= 0; i--) {
      final item = _chatItems[i];
      if (item is ChatMessageModel) {
        final messageDate = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
        if (lastDate == null || !(lastDate.year == messageDate.year && lastDate.month == messageDate.month && lastDate.day == messageDate.day)) {
          items.add(messageDate);
          lastDate = messageDate;
        }
        items.add(item);
      }
    }
    return items.reversed.toList(); // Reverse to show newest at the bottom of ListView
  }

  Widget _buildDateDivider(DateTime date) { /* ... same as IndividualChatScreen ... */
    return Center(child: Container(padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0), margin: EdgeInsets.symmetric(vertical: 8.0), decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(12.0)), child: Text(DateFormat.yMMMd().format(date), style: TextStyle(fontSize: 12.0, color: Colors.black54, fontWeight: FontWeight.w600))));
  }

  @override
  void dispose() {
    _messageController.removeListener(_onInputChanged);
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _getProcessedChatItems();
    return Scaffold(
      appBar: AppBar(
        title: Text('与${widget.aiName}对话 ✨'), // "Chat with 小她 ✨"
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: displayItems.isEmpty
                ? Center(child: Text('Start chatting with ${widget.aiName}!'))
                : ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.all(8.0),
                    itemCount: displayItems.length,
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      if (item is DateTime) {
                        return _buildDateDivider(item);
                      } else if (item is ChatMessageModel) {
                        // Check for custom message types for rich UI
                        if (item.type == MessageType.custom && item.structuredContent?['cardType'] == 'productRecommendation') {
                           List<ProductRecommendationCardItem> products = (item.structuredContent!['products'] as List)
                              .map((p) => ProductRecommendationCardItem(
                                    imageUrl: p['imageUrl'], name: p['name'], price: p['price'],
                                    features: List<String>.from(p['features']), productUrl: p['productUrl']
                                  )).toList();
                          return ProductRecommendationCardWidget(products: products);
                        }
                        // Standard message bubble
                        return MessageBubble(
                          message: item,
                          isCurrentUser: item.senderId == _currentUserId,
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
          ),
          if (_isAiTyping) /* ... AI typing indicator ... */ Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(strokeWidth: 2), SizedBox(width:8), Text("${widget.aiName} is thinking...")])),
          ChatInputBarWidget( // Using the conceptual widget
            controller: _messageController,
            onSendPressed: _isAiTyping ? (){} : _handleUserMessageSubmission,
            onAttachPressed: () { print("Attach file to AI chat"); }, // Example action
            hintText: 'Message ${widget.aiName}...',
          ),
        ],
      ),
    );
  }
}
```

```dart
import 'package:flutter/material.dart';

class ChatInputBarWidget extends StatefulWidget { // Changed to StatefulWidget to manage send button state
  final TextEditingController messageController;
  final FocusNode? focusNode;
  final String hintText;
  final bool isLoading; // e.g., AI is typing, or message is being sent
  final bool isDisabled; // To disable the entire bar, e.g. if chat is read-only

  final VoidCallback onSendMessage;
  final VoidCallback? onAddFilePressed; // For attachments
  final VoidCallback? onEmojiPressed;   // For emoji picker
  final VoidCallback? onVoiceInputPressed; // For voice input

  const ChatInputBarWidget({
    Key? key,
    required this.messageController,
    this.focusNode,
    this.hintText = 'Type a message...',
    this.isLoading = false,
    this.isDisabled = false,
    required this.onSendMessage,
    this.onAddFilePressed,
    this.onEmojiPressed,
    this.onVoiceInputPressed,
  }) : super(key: key);

  @override
  _ChatInputBarWidgetState createState() => _ChatInputBarWidgetState();
}

class _ChatInputBarWidgetState extends State<ChatInputBarWidget> {
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(_onTextChanged);
    _canSend = widget.messageController.text.trim().isNotEmpty;
  }

  @override
  void didUpdateWidget(ChatInputBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messageController != oldWidget.messageController) {
      oldWidget.messageController.removeListener(_onTextChanged);
      widget.messageController.addListener(_onTextChanged);
      _canSend = widget.messageController.text.trim().isNotEmpty;
    }
  }

  void _onTextChanged() {
    if (mounted) {
      final newCanSend = widget.messageController.text.trim().isNotEmpty;
      if (_canSend != newCanSend) {
        setState(() {
          _canSend = newCanSend;
        });
      }
    }
  }

  @override
  void dispose() {
    widget.messageController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool effectivelyDisabled = widget.isDisabled || widget.isLoading;
    final bool sendButtonEnabled = _canSend && !effectivelyDisabled;

    return Container(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        top: 8.0,
        bottom: MediaQuery.of(context).padding.bottom + 8.0 // Handles keyboard/notch
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Or a specific background color
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -1),
            blurRadius: 4.0,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom if TextField grows
        children: <Widget>[
          // Add File Button (Optional)
          if (widget.onAddFilePressed != null)
            IconButton(
              icon: Icon(Icons.add_circle_outline), // User's example used a simple plus
              onPressed: effectivelyDisabled ? null : widget.onAddFilePressed,
              tooltip: 'Attach file',
              color: Theme.of(context).iconTheme.color?.withOpacity(effectivelyDisabled ? 0.5 : 1.0),
            ),

          // Emoji Button (Optional)
          if (widget.onEmojiPressed != null)
            IconButton(
              icon: Icon(Icons.emoji_emotions_outlined),
              onPressed: effectivelyDisabled ? null : widget.onEmojiPressed,
              tooltip: 'Insert emoji',
              color: Theme.of(context).iconTheme.color?.withOpacity(effectivelyDisabled ? 0.5 : 1.0),
            ),

          // Voice Input Button (Optional)
          // This might change icon based on voice input state (e.g., listening)
          if (widget.onVoiceInputPressed != null)
            IconButton(
              icon: Icon(Icons.mic_none_outlined), // Or Icons.mic
              onPressed: effectivelyDisabled ? null : widget.onVoiceInputPressed,
              tooltip: 'Voice input',
              color: Theme.of(context).iconTheme.color?.withOpacity(effectivelyDisabled ? 0.5 : 1.0),
            ),

          // Text Input Field
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.0), // Small padding around textfield
              child: TextField(
                controller: widget.messageController,
                focusNode: widget.focusNode,
                enabled: !effectivelyDisabled,
                textInputAction: TextInputAction.send, // Allows keyboard 'send' action
                onSubmitted: sendButtonEnabled ? (_) => widget.onSendMessage() : null,
                decoration: InputDecoration(
                  hintText: widget.isLoading ? 'AI is thinking...' : widget.hintText,
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor, // Or a slightly different shade
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  // To match user's example, ensure no underline when focused/enabled
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5), // Highlight on focus
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0), // Subtle border when enabled
                  ),
                  disabledBorder: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1.0),
                  )
                ),
                minLines: 1,
                maxLines: 5, // Allow multiline input
                style: TextStyle(
                  color: effectivelyDisabled ? Colors.grey[600] : null
                ),
              ),
            ),
          ),
          SizedBox(width: 4.0),

          // Send Button
          // The user's example shows an upward arrow in a circle.
          // IconButton is common, or a small ElevatedButton/FloatingActionButton.
          Material( // To provide splash effect on a custom shape
            color: sendButtonEnabled ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(25.0),
            child: InkWell(
              onTap: sendButtonEnabled ? widget.onSendMessage : null,
              borderRadius: BorderRadius.circular(25.0),
              child: Padding(
                padding: const EdgeInsets.all(10.0), // Adjust padding for icon size
                child: Icon(
                  Icons.arrow_upward_rounded, // User's example icon
                  // Icons.send, // Alternative
                  color: Colors.white,
                  size: 24.0, // Adjust size
                ),
              ),
            ),
          )
          // Alternative using IconButton:
          // IconButton(
          //   icon: Icon(Icons.send),
          //   onPressed: sendButtonEnabled ? widget.onSendMessage : null,
          //   tooltip: 'Send message',
          //   color: sendButtonEnabled ? Theme.of(context).primaryColor : Colors.grey,
          // ),
        ],
      ),
    );
  }
}

```

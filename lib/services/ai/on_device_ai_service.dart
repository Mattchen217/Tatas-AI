```dart
import 'dart:async';
import 'dart:math'; // For a random joke selection or varied suggestions

class OnDeviceAiService {
  final Random _random = Random();

  // Existing method for direct AI chat
  Future<String> getResponse(String userInput) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)));
    String normalizedInput = userInput.toLowerCase().trim();

    if (normalizedInput == "hello" || normalizedInput == "hi") {
      return "Hello there! How can I help you today?";
    } else if (normalizedInput == "how are you?" || normalizedInput == "how are you") {
      return "I am doing well, thank you for asking! I'm ready for your questions.";
    } else if (normalizedInput.startsWith("my name is ")) {
      String name = userInput.substring("my name is ".length).trim();
      if (name.isNotEmpty) {
        return "Nice to meet you, $name!";
      } else {
        return "It sounds like you were about to tell me your name!";
      }
    } else if (normalizedInput == "tell me a joke" || normalizedInput == "joke") {
      List<String> jokes = [
        "Why don't scientists trust atoms? Because they make up everything!",
        "Why did the scarecrow win an award? Because he was outstanding in his field!",
        "Why don't skeletons fight each other? They don't have the guts.",
        "What do you call fake spaghetti? An impasta!"
      ];
      return jokes[_random.nextInt(jokes.length)];
    } else if (normalizedInput == "what is your name?" || normalizedInput == "what's your name?" || normalizedInput == "who are you?") {
      return "I am your Personal AI, here to assist you.";
    } else if (normalizedInput == "what can you do?" || normalizedInput == "help") {
      return "I can respond to a few simple phrases like 'hello', 'how are you', 'tell me a joke', 'what is your name?', and 'my name is [Your Name]'. I'm still under development!";
    }

    return "I am a simple AI. I'm still learning. You said: \"$userInput\"";
  }

  // Existing method for generating Copilot suggestions
  Future<String?> getCopilotSuggestion(String incomingMessageText, String? originalSenderName) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));
    String normalizedMessage = incomingMessageText.toLowerCase().trim();
    String senderName = originalSenderName ?? "them";

    if (normalizedMessage.contains("question") || normalizedMessage.endsWith("?") || normalizedMessage.contains("how does") || normalizedMessage.contains("what is") || normalizedMessage.contains("why is")) {
      List<String> suggestions = [
        "Let me check on that for you, $senderName.",
        "Good question, $senderName! I'll find out.",
        "That's an interesting point, $senderName. I'll need a moment to think.",
      ];
      return suggestions[_random.nextInt(suggestions.length)];
    } else if (normalizedMessage.contains("thank you") || normalizedMessage.contains("thanks") || normalizedMessage.contains("appreciate it")) {
      List<String> suggestions = [
        "You're welcome, $senderName!",
        "No problem, $senderName!",
        "Happy to help, $senderName!",
        "Anytime, $senderName!"
      ];
      return suggestions[_random.nextInt(suggestions.length)];
    } else if (normalizedMessage.contains("urgent") || normalizedMessage.contains("asap") || normalizedMessage.contains("important")) {
      List<String> suggestions = [
        "Got it, $senderName. I'll look into this right away.",
        "Understood, $senderName. I'll prioritize this.",
        "Acknowledged, $senderName. Treating this with urgency."
      ];
      return suggestions[_random.nextInt(suggestions.length)];
    } else if (normalizedMessage == "hello" || normalizedMessage == "hi" || normalizedMessage == "hey" || normalizedMessage == "greetings") {
      List<String> suggestions = [
        "Hey $senderName!",
        "Hello $senderName, how are you?",
        "Hi $senderName!"
      ];
      return suggestions[_random.nextInt(suggestions.length)];
    } else if (normalizedMessage.contains("sorry") || normalizedMessage.contains("apologies") || normalizedMessage.contains("my bad")) {
       List<String> suggestions = [
        "No worries, $senderName.",
        "It's alright, $senderName.",
        "That's okay, $senderName. Thanks for letting me know."
      ];
      return suggestions[_random.nextInt(suggestions.length)];
    } else if (normalizedMessage.length > 10 && (normalizedMessage.endsWith(".") || normalizedMessage.endsWith("!") ) ) {
       List<String> suggestions = [
        "Okay, sounds good.",
        "Understood.",
        "Got it.",
        "Thanks for letting me know, $senderName."
      ];
      return suggestions[_random.nextInt(suggestions.length)];
    }
    return null;
  }

  // New method for generating Autopilot replies
  Future<String?> getAutopilotReply(String incomingMessageText, String? originalSenderName) async {
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(300))); // Slightly longer than copilot, less than direct chat
    String normalizedMessage = incomingMessageText.toLowerCase().trim();
    String senderName = originalSenderName ?? "there"; // Default for use in replies

    // Rule 1: Simple availability questions (conservative reply)
    if (normalizedMessage == "are you free later?" ||
        normalizedMessage == "are you free later" ||
        normalizedMessage == "can you talk?" ||
        normalizedMessage == "can you talk" ||
        normalizedMessage == "are you busy?" ||
        normalizedMessage == "are you busy" ||
        normalizedMessage == "u free?" ||
        normalizedMessage == "you free?") {
      return "I'll have to check my schedule and get back to you, $senderName.";
    }

    // Rule 2: Simple greetings (conservative reply, managing expectations)
    // Only reply if it's JUST a greeting, to avoid interrupting a more complex statement that starts with "hello".
    if (normalizedMessage == "hi" ||
        normalizedMessage == "hello" ||
        normalizedMessage == "hey" ||
        normalizedMessage == "hey there" ||
        normalizedMessage == "greetings") {
      return "Hello $senderName! I'm a bit busy at the moment but will get back to you when I can.";
    }

    // Rule 3: Simple thanks (polite, safe reply)
    if (normalizedMessage == "thank you" ||
        normalizedMessage == "thanks" ||
        normalizedMessage == "ty" ||
        normalizedMessage == "thx") {
      return "You're welcome, $senderName!";
    }

    // Rule 4: Simple positive acknowledgements (e.g., "sounds good", "ok great")
    if (normalizedMessage == "ok" ||
        normalizedMessage == "okay" ||
        normalizedMessage == "got it" ||
        normalizedMessage == "sounds good" ||
        normalizedMessage == "great" ||
        normalizedMessage == "cool") {
        return "👍"; // A simple emoji acknowledgement
    }

    // Rule 5: Simple "how are you?"
    if (normalizedMessage == "how are you?" ||
        normalizedMessage == "how are you" ||
        normalizedMessage == "how's it going?" ||
        normalizedMessage == "hows it going") {
        return "Doing well, thanks for asking, $senderName! Hope you are too.";
    }


    // Default: No reply for Autopilot if no specific safe rule is met
    return null;
  }
}
```

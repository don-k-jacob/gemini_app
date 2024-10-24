import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(
    id: '0',
    firstName: 'User',
  );
  ChatUser geminiUser = ChatUser(
      id: '1',
      firstName: 'Gemini',
      profileImage:
          "https://www.shutterstock.com/image-vector/new-google-ai-gemini-logo-260nw-2398812253.jpg");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini App'),
        centerTitle: true,
      ),
      body: DashChat(
          currentUser: currentUser, onSend: _sendMessgae, messages: messages),
    );
  }

  _sendMessgae(ChatMessage message) {
    setState(() {
      messages = [message, ...messages];
    });
    try {
      String question = message.text;
      gemini.streamGenerateContent(question)
        .listen((event) {
          ChatMessage? lastMessage = messages.firstOrNull;
          if (lastMessage != null && lastMessage.user == geminiUser) {
            lastMessage = messages.removeAt(0);
            String response = event.content?.parts
                    ?.fold("", (previous, current) => "$previous ${current.text}") ??
                "";
            lastMessage.text = response;
            setState(() {
              messages = [lastMessage!, ...messages];
            });
          } else {
            String response = event.content?.parts
                    ?.fold("", (previous, current) => "$previous ${current.text}") ??
                "";
            ChatMessage newMessage = ChatMessage(
                user: geminiUser, createdAt: DateTime.now(), text: response);
            setState(() {
              messages = [newMessage, ...messages];
            });
          }
        });
    } catch (e) {
      print(e);
    }
  }
}

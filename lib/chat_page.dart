import 'dart:io';
import 'dart:typed_data';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
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
          inputOptions: InputOptions(trailing: [
            IconButton(
                onPressed: _sendMediaMessage, icon: const Icon(Icons.image))
          ]),
          currentUser: currentUser,
          onSend: _sendMessge,
          messages: messages),
    );
  }

  _sendMessge(ChatMessage chatMessage) {
    setState(() {messages = [chatMessage, ...messages];});
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if(chatMessage.medias?.isNotEmpty??false)
      {
        images = [File(chatMessage.medias!.first.url).readAsBytesSync()];
      }
      gemini.streamGenerateContent(question, images:images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous ${current.text}") ??
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

  _sendMediaMessage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      ChatMessage newMessage = ChatMessage(
          user: currentUser,
          createdAt: DateTime.now(),
          text: "Discribe this image?",
          medias: [
            ChatMedia(
              url: file.path,
              fileName: "",
              type: MediaType.image,
            )
          ]);
      _sendMessge(newMessage);
    }
  }
}

// import 'dart:js_interop';
import 'package:chat_app/widgets/chat_messages.widgets.dart';
import 'package:chat_app/widgets/new_message.widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  void setuppushnotification() async {
    final firebase = FirebaseMessaging.instance;
    await firebase.requestPermission();
    final token = await firebase.getToken();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setuppushnotification();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter chatapp'),
          actions: [
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.primary,
                ))
          ],
        ),
        body: Column(
          children: const [Expanded(child: ChatMessage()), NewMessage()],
        ));
  }
}

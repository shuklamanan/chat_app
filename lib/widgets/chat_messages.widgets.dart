import 'package:chat_app/widgets/message_bubble.widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final _authuser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error'),
          );
        }
        final loadmsg = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemBuilder: (context, index) {
            final chatmessage = loadmsg[index].data();
            final nextmessage =
                index + 1 < loadmsg.length ? loadmsg[index + 1].data() : null;

            final currmsguserid = chatmessage['userId'];
            final nextmsguserid =
                nextmessage != null ? nextmessage['userId'] : null;
            final nextuserissame = nextmsguserid == currmsguserid;
            if (nextuserissame) {
              return MessageBubble.next(
                  message: chatmessage['text'],
                  isMe: _authuser.uid == currmsguserid);
            } else {
              return MessageBubble.first(
                  userImage: chatmessage['image_url'],
                  username: chatmessage['username'],
                  message: chatmessage['text'],
                  isMe: _authuser.uid == currmsguserid);
            }
          },
          itemCount: loadmsg.length,
        );
      },
    );
  }
}

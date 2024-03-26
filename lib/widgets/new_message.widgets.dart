import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _msgcontrl = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    _msgcontrl.dispose();
    super.dispose();
  }

  void submitmessage() async {
    final enteredmessage = _msgcontrl.text;
    if (enteredmessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context)
        .unfocus(); // keyboard will close after sending the message
    //send it to firebase
    final user = FirebaseAuth.instance.currentUser!;
    final userdata = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredmessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userdata.data()!['username'],
      'image_url': userdata.data()!['imageurl'],
    });
    _msgcontrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, right: 1, left: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgcontrl,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'Send a Message...'),
            ),
          ),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: submitmessage,
              icon: const Icon(Icons.send)),
        ],
      ),
    );
  }
}

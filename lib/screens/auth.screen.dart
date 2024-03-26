import 'dart:io';

import 'package:chat_app/widgets/image_picker.widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _islogin = true;
  final _form = GlobalKey<FormState>();
  var _email = '';
  var _password = '';
  var _isauthenticating = false;
  var _username = '';
  final _firebaseinstance = FirebaseAuth.instance;
  File? _selectedimage;

  void submit() async {
    final _isvalid = _form.currentState!.validate();
    if (!_isvalid || (!_islogin && _selectedimage == null)) {
      return;
    }
    _form.currentState!.save();
    try {
      setState(() {
        _isauthenticating = true;
      });
      if (_islogin) {
        //login user
        final usercredentials = await _firebaseinstance
            .signInWithEmailAndPassword(email: _email, password: _password);
        print(usercredentials);
      } else {
        final usercredentials = await _firebaseinstance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        final storageref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${usercredentials.user!.uid}.jpeg');

        await storageref.putFile(_selectedimage!);
        final imageurl = await storageref.getDownloadURL();

        FirebaseFirestore.instance
            .collection('users')
            .doc(usercredentials.user!.uid)
            .set({
          'username': _username,
          'email': _email,
          'imageurl': imageurl,
        });
        print(imageurl);
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
      _isauthenticating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 20,
                  top: 30,
                  bottom: 20,
                  right: 20,
                ),
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_islogin)
                            UserImagePicker(
                              onpickimage: (pickedimage) {
                                _selectedimage = pickedimage;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Enter a vaid Email address';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value!;
                            },
                          ),
                          if (!_islogin)
                            TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Username'),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Enter a valid username(4 characters long)';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _username = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be of  character long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isauthenticating)
                            const CircularProgressIndicator(),
                          if (!_isauthenticating)
                            ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(_islogin ? 'Login' : 'SignUp'),
                            ),
                          if (!_isauthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _islogin = !_islogin;
                                });
                              },
                              child: Text(_islogin
                                  ? 'Create an account'
                                  : 'Already have an Account'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

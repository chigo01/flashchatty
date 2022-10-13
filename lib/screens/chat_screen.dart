import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static const id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User? loggedInUser = FirebaseAuth.instance.currentUser!;
  String? messageText;

  //use for getting the user that logged in

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
  }

  void getMessages() async {
    var messages;
    await _fireStore.collection('messages').get().then(
          (value) => value.docs.forEach(
            (doc) {
              messages = doc.data();
              print(messages);
            },
          ),
        );
  }

  // void getMessages() async {
  //   final messages = await _fireStore.collection('messages').get();
  //   for (var message in messages.docs) {
  //     print(message.data());
  //   }
  // }
//getting the data from another sender and ours
  void messagesStream() async {
    //looping through a map of fireStore collection nad getting its data using a snapshot
    //use a nested loop, to loop through the of docs
    await for (var snapshot in _fireStore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MyMessagesStream(
              fireStore: _fireStore,
              loggedInUser: loggedInUser,
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      //Implement send functionality.
                      _fireStore.collection('messages').add(
                        {
                          'text': messageText,
                          'sender': loggedInUser!.email,
                          'ts': Timestamp.now(),
                        },
                      );
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyMessagesStream extends StatelessWidget {
  const MyMessagesStream({
    Key? key,
    required FirebaseFirestore fireStore,
    required this.loggedInUser,
  })  : _fireStore = fireStore,
        super(key: key);

  final FirebaseFirestore _fireStore;
  final User? loggedInUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore
          .collection('messages')
          .orderBy('ts', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        List<Widget> messageWidgets = [];
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        {
          final messages = snapshot.data!.docs;

          for (var message in messages) {
            final messageText = message['text'];
            final messageSender = message['sender'];
            final Timestamp messageTime = message['ts'] as Timestamp;

            final currentUser = loggedInUser!.email;

            final messageBubbles = MessageBubble(
              sender: messageSender,
              text: messageText,
              isMe: currentUser == messageSender,
              time: messageTime,
            );

            messageWidgets.add(messageBubbles);
          }
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            children: messageWidgets,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.sender,
    required this.text,
    required this.isMe,
    required this.time,
  }) : super(key: key);

  final String sender;
  final String text;
  final bool isMe;
  final Timestamp time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: isMe ? Radius.circular(30) : Radius.zero,
              topRight: isMe ? Radius.zero : Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 20,
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

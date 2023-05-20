// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentor_mind/model/call.dart';
import 'package:mentor_mind/screens/call_screen.dart';

class CallPickupScreen extends StatelessWidget {
  final Widget scaffold;
  CallPickupScreen({super.key, required this.scaffold});
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          firestore.collection('call').doc(auth.currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          Call call =
              Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          if (!call.hasDialled) {
            return Scaffold(
              body: Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('incoming call'),
                  SizedBox(
                    height: 20,
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(call.callerPic),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(call.callerName),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => CallScreen(
                                      channelId: call.callId,
                                      call: call,
                                      isGroupChat: false,
                                    )),
                          );
                        },
                        icon: Icon(Icons.call),
                        color: Colors.green,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.call_end),
                        color: Colors.red,
                      )
                    ],
                  ),
                ],
              )),
            );
          }
        }
        return scaffold;
      },
    );
  }
}

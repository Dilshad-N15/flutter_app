// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentor_mind/screens/homescreen.dart';
import 'package:mentor_mind/utils/apply_box.dart';
import 'package:mentor_mind/utils/category_box.dart';
import 'package:mentor_mind/utils/description_box.dart';
import 'package:mentor_mind/utils/request_box.dart';
import 'package:mentor_mind/utils/skills_box.dart';

class Description extends StatefulWidget {
  Description({super.key, required this.dSnap});
  var dSnap;

  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final user = FirebaseAuth.instance.currentUser!;

  Future applyToTeach() async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        'applied': FieldValue.arrayUnion(
          [widget.dSnap['requestID']],
        ),
      });
    } catch (e) {
      print(e.toString());
    }

    try {
      await _firestore
          .collection('requests')
          .doc(widget.dSnap['requestID'])
          .update({
        'applicants': FieldValue.arrayUnion(
          [user.uid],
        ),
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isApplied = false;
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.dSnap['requestID'])
            .get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;

          if (data == null) {
            return Text('User not found');
          }
          final applied = data['applicants'] as List<dynamic>;
          final requestID = user.uid;
          print(applied);
          print(requestID);
          isApplied = applied.contains(requestID);
          print(isApplied);
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              elevation: 0,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  CupertinoIcons.back,
                ),
              ),
              title: Text(
                'Job Details',
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  RequestBox(
                    type: '',
                    dSnap: widget.dSnap,
                    col: Colors.primaries[Random().nextInt(
                      Colors.primaries.length,
                    )],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DescriptionBox(
                    description: widget.dSnap['description'],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RequirementBox(skill: widget.dSnap['topic']),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              height: 50,
              width: double.infinity,
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // CategoryBox(name: 'Message'),
                  isApplied
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: ApplyBox(name: 'Already applied'),
                        )
                      : GestureDetector(
                          onTap: () {
                            applyToTeach();
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Request uploaded 👍'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: ApplyBox(name: 'Apply Now'),
                          ),
                        ),
                ],
              ),
            ),
          );
        });
  }
}

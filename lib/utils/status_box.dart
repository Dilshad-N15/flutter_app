// ignore_for_file: sort_child_properties_last, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:mentor_mind/screens/applications.dart';
import 'package:mentor_mind/screens/profilePage.dart';
import 'package:mentor_mind/utils/category_box_inside_req.dart';

class ApplicationStatusViewBox extends StatelessWidget {
  ApplicationStatusViewBox({super.key, required this.col, required this.dSnap});
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Color col;
  var dSnap;

  @override
  Widget build(BuildContext context) {
    CollectionReference users = _firestore.collection('users');

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              // if (dSnap['mentor'] == '' || dSnap['mentor'] == null) {
              //   Navigator.of(context).push(
              //     MaterialPageRoute(
              //       builder: (context) => RequestedApplicantsPage(
              //         requestID: dSnap['requestID'],
              //       ),
              //     ),
              //   );
              // } else {
              //   Navigator.of(context).push(
              //     MaterialPageRoute(
              //       builder: (context) => ProfilePageNew(
              //           mentorID: dSnap['mentor'],
              //           topic: dSnap['topic']),
              //     ),
              //   );
              // }
            },
            child: Container(
              decoration: BoxDecoration(
                color: col,
                borderRadius: BorderRadius.circular(20),
              ),
              height: 230,
              child: Column(
                children: [
                  Container(
                    height: 180,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black26,
                                ),
                                child: Icon(
                                  CupertinoIcons.smiley,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dSnap['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(dSnap['topic']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CategoryBoxInside(
                                  title:
                                      '${dSnap["date"].toDate().day}-${DateFormat("MMM").format(DateTime.now())}'),
                              // CategoryBoxInside(title: 'Physics'),
                              CategoryBoxInside(title: dSnap['type']),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            dSnap['description'],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: dSnap['mentor'] == ''
                          ? Colors.blueGrey[200]
                          : dSnap['mentor'] == user.uid
                              ? Colors.green
                              : Colors.redAccent,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: dSnap['mentor'] == ''
                                ? Text(
                                    'Pending ⌛',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : dSnap['mentor'] == user.uid
                                    ? GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ProfilePageNew(
                                                admin: false,
                                                mentorID: dSnap['uid'],
                                                topic: dSnap['topic'],
                                                requestID: dSnap['requestID'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Approved 😃 click me!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : Text(
                                        'Rejected 😥',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content: Text(
                          'Are you sure you want to remove this application?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(true); // Return true when confirmed
                          },
                        ),
                      ],
                    );
                  },
                ).then((confirmed) async {
                  if (confirmed != null && confirmed) {
                    try {
                      await _firestore
                          .collection('requests')
                          .doc(dSnap['requestID'])
                          .update({
                        'applicants': FieldValue.arrayRemove(
                          [user.uid],
                        ),
                      });
                    } catch (e) {}
                    try {
                      await _firestore.collection('users').doc(user.uid).update(
                        {
                          'applied':
                              FieldValue.arrayRemove([dSnap['requestID']]),
                        },
                      );
                    } catch (e) {}
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => PersonalApplicationsView(),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Application Removed'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                });
              },
              child: dSnap['mentor'] == ''
                  ? Container(
                      height: 40,
                      width: 170,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(CupertinoIcons.delete),
                          Text('Remove Application'),
                        ],
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        color: Colors.black,
                      ),
                    )
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mentor_mind/screens/profile.dart';
import 'package:mentor_mind/screens/profilePage.dart';

class Comment {
  final String name;
  final String text;

  const Comment({required this.name, required this.text});
}

class CommentModalSheet extends StatefulWidget {
  CommentModalSheet({
    super.key,
    required this.topic,
    required this.mentorID,
  });
  final String topic;
  final String mentorID;
  @override
  State<CommentModalSheet> createState() => _CommentModalSheetState();
}

class _CommentModalSheetState extends State<CommentModalSheet> {
  Future<List<Comment>> getComments() async {
    final subjectName = widget.topic;
    final commentsRef = FirebaseFirestore.instance
        .collection('comments')
        .doc(widget.mentorID)
        .collection(subjectName);

    final commentsSnap = await commentsRef.get();
    final comments = <Comment>[];

    for (final doc in commentsSnap.docs) {
      //
      //
      if (!doc.data().containsKey('rating')) {
        final commentText = doc['comment'];
        final fromUid = doc['from'];

        final userRef =
            FirebaseFirestore.instance.collection('users').doc(fromUid);

        final userSnap = await userRef.get();
        final userName = userSnap['name'];

        print('$userName commented: $commentText');
        comments.add(Comment(name: userName, text: commentText));
      }
    }
    return comments;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.5,
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Text(
                          'Reviews',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(''),
                      ],
                    ),
                  ),
                  Row(children: [
                    const Icon(Icons.toggle_off_outlined),
                    const SizedBox(
                      width: 5,
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close)),
                  ])
                ],
              ),
              // AddCommentBox(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: FutureBuilder<List<Comment>>(
                        future: getComments(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final comments = snapshot.data!;
                            return ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return CommentBox(
                                  name: comment.name,
                                  comment: comment.text,
                                );
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApplicantBox extends StatelessWidget {
  ApplicantBox({
    super.key,
    required this.dSnap,
    required this.reqDocID,
    required this.topic,
  });
  var dSnap;
  final String topic;
  final String reqDocID;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;

  void assignMentor() async {
    await _firestore
        .collection('requests')
        .doc(reqDocID)
        .update({"mentor": dSnap['uid']});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 80,
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 153, 152, 152),
            borderRadius: BorderRadius.circular(8)),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 49, 49, 49),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Color(0xFFBCCEF8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 224, 223, 223),
                            child: Container(
                              height: 20,
                              width: 20,
                              child: SvgPicture.network(
                                'https://avatars.dicebear.com/api/identicon/${dSnap["name"]}.svg',
                              ),
                            ))
                      ],
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            dSnap['name'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                            width: 150,
                            child: Text(
                              dSnap['email'],
                              style: const TextStyle(fontSize: 12),
                            )),
                        SizedBox(
                            width: 150,
                            child: GestureDetector(
                              onTap: () => showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  context: context,
                                  builder: (context) {
                                    return CommentModalSheet(
                                      topic: topic,
                                      mentorID: dSnap['uid'],
                                    );
                                  }),
                              child: Text(
                                'view comments',
                                style: const TextStyle(fontSize: 12),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Assign Mentor'),
                              content: Text(
                                  'Do you want to assign ${dSnap['name']} as your mentor?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                        false); // Returns false when canceled
                                  },
                                ),
                                TextButton(
                                  child: Text('Confirm'),
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                        true); // Returns true when confirmed
                                  },
                                ),
                              ],
                            );
                          },
                        ).then((value) {
                          // Handle the user's choice
                          if (value != null && value) {
                            assignMentor();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ProfilePage()));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Assigned as mentor 👍'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {}
                        });
                      },
                      icon: Icon(
                        CupertinoIcons.arrowshape_turn_up_right_circle_fill,
                        color: Colors.green[300],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //     builder: (_) => Player(
                        //       pageNumber: index,
                        //       book: widget.book,
                        //     ),
                        //   ),
                        // );
                      },
                      icon: Icon(
                        CupertinoIcons.delete,
                        color: Colors.red[300],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Padding(
    //   padding: EdgeInsets.all(8.0),
    //   child: Container(
    //     color: Colors.black54,
    //     child: ListTile(
    //       leading: const Icon(CupertinoIcons.person_crop_circle),
    //       title: Row(
    //         children: [
    //           Text(dSnap['name']),
    //           SizedBox(
    //             width: 10,
    //           ),
    //           GestureDetector(
    //             onTap: () => showModalBottomSheet(
    //                 shape: RoundedRectangleBorder(
    //                     borderRadius: BorderRadius.circular(10)),
    //                 context: context,
    //                 builder: (context) {
    //                   return CommentModalSheet(
    //                     topic: topic,
    //                     mentorID: dSnap['uid'],
    //                   );
    //                 }),
    //             child: Text('4.0  ⭐'),
    //           ),
    //         ],
    //       ),
    //       subtitle: Text(dSnap['email']),
    //       trailing: Row(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           GestureDetector(
    //             onTap: () {
    //               assignMentor();
    //               // Navigator.of(context).push(
    //               //     MaterialPageRoute(builder: (_) => ProfilePageNew()));
    //             },
    //             child: const Icon(
    //               CupertinoIcons.square_arrow_right_fill,
    //               color: Colors.green,
    //             ),
    //           ),
    //           const SizedBox(
    //             width: 15,
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}

class AddCommentBox extends StatefulWidget {
  const AddCommentBox({super.key});

  @override
  State<AddCommentBox> createState() => _AddCommentBoxState();
}

class _AddCommentBoxState extends State<AddCommentBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          foregroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1658188920091-8d38c64bcb79?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=764&q=80'),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Add comment',
              hintStyle: TextStyle(fontSize: 13),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class CommentBox extends StatelessWidget {
  const CommentBox({super.key, required this.name, required this.comment});
  final String name;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
                backgroundColor: Color.fromARGB(255, 85, 77, 77),
                child: SvgPicture.network(
                  'https://api.dicebear.com/5.x/identicon/svg?seed=${name}',
                  width: 20,
                  height: 20,
                )),
            SizedBox(
              width: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(name), Text(comment)],
            )
          ],
        ));
  }
}

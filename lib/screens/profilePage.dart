// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentor_mind/screens/chat_screen.dart';
import 'package:mentor_mind/screens/rate.dart';
import 'package:mentor_mind/utils/applicant_box.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:mentor_mind/.env';

class ProfilePageNew extends StatefulWidget {
  ProfilePageNew({
    super.key,
    required this.mentorID,
    this.requestID = '',
    required this.topic,
    required this.admin,
  });
  final String mentorID;
  final String requestID;
  final String topic;
  final bool admin;

  @override
  State<ProfilePageNew> createState() => _ProfilePageNewState();
}

class _ProfilePageNewState extends State<ProfilePageNew> {
  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $sk',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  Future<double> getRating(String type, String mentorId, String userId) async {
    DocumentSnapshot ratingSnapshot;
    print('widget.admin');
    print(widget.admin);
    print(mentorId);
    print(userId);
    if (widget.admin) {
      ratingSnapshot = await FirebaseFirestore.instance
          .collection('comments') // Replace 'type' with your collection name
          .doc(mentorId) // Replace 'userId' with the desired document ID
          .collection(type)
          .doc(
              'rating') // Assuming the rating is stored in a document named 'rating'
          .get();
    } else {
      ratingSnapshot = await FirebaseFirestore.instance
          .collection('comments') // Replace 'type' with your collection name
          .doc(userId) // Replace 'userId' with the desired document ID
          .collection(type)
          .doc(
              'rating') // Assuming the rating is stored in a document named 'rating'
          .get();
    }

    print("ratingSnapshot.exists");
    print(ratingSnapshot.exists);

    if (ratingSnapshot.exists) {
      print("ratingSnapshot.data()");

      final d = ratingSnapshot.data() as Map<String, dynamic>;
      print(d['rating']);
      double rating = d['rating'];
      print("rating");
      print(rating);
      return rating;
    } else {
      return 0; // Return 0 if the rating document doesn't exist
    }
  }

  displayPaymentSheet(String link) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.requestID)
            .update({'payment': true});
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          Text("Payment Successful"),
                        ],
                      ),
                    ],
                  ),
                ));

        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Rating(
              type: widget.topic,
              link: link,
              mentorID: widget.mentorID,
            ),
          ),
        );
        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  Future<void> makePayment(String link) async {
    try {
      paymentIntent = await createPaymentIntent('500', 'INR');
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
                  // googlePay: const PaymentSheetGooglePay(testEnv: true, currencyCode: "US", merchantCountryCode: "+92"),
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Mentor Mind'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet(link);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? paymentIntent;

  final user = FirebaseAuth.instance.currentUser!;

  String chatRoomID(String user1, String user2) {
    print("ring ring");
    String x = widget.requestID.replaceAll("-", "");
    print(x);
    print(user1);
    print(user2);
    print(widget.requestID.replaceAll("-", ""));
    if (user1[0].toLowerCase().codeUnits[0] >
        user2[0].toLowerCase().codeUnits[0]) {
      print("$user1$user2$x");
      return "$user1$user2$x";
    } else {
      print("$user1$user2$x");
      return "$user2$user1$x";
    }
  }

  @override
  Widget build(BuildContext context) {
    print('admin is ${widget.admin}');
    CollectionReference users = _firestore.collection('users');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: widget.admin ? Text('Your Mentor') : Text('Your Mentee'),
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(CupertinoIcons.back)),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<DocumentSnapshot>(
        future: users.doc(widget.mentorID).get(),
        builder: (((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text(''),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> snap =
                snapshot.data!.data() as Map<String, dynamic>;

            print(snap);
            return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('requests')
                    .doc(widget.requestID)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text(''),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> reqsnap =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            margin: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xFF0A2647).withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            height: 300.0,
                            width: 300.0,
                            child: Container(
                              margin: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xFF144272).withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              height: 300.0,
                              width: 300.0,
                              child: Container(
                                margin: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Color(0xFF205295).withOpacity(0.4),
                                  shape: BoxShape.circle,
                                ),
                                height: 300.0,
                                width: 300.0,
                                child: Container(
                                  margin: EdgeInsets.all(20),
                                  height: 150.0,
                                  width: 150.0,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF2C74B3).withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.all(20),
                                    child: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(snap['img']),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: FutureBuilder<double>(
                              future: getRating(reqsnap['topic'],
                                  reqsnap['mentor'], reqsnap['uid']),
                              builder: (context, snapshotx) {
                                if (snapshotx.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // Show a loading indicator while fetching the rating
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  double rating = snapshotx.data ??
                                      0; // Retrieve the rating value or default to 0
                                  return Column(
                                    children: [
                                      Text(
                                        snap['name'],
                                        style: GoogleFonts.getFont(
                                          'Noto Sans Display',
                                          textStyle: TextStyle(
                                            fontSize: 20,
                                            letterSpacing: .5,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      GestureDetector(
                                        onTap: () => showModalBottomSheet(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            context: context,
                                            builder: (context) {
                                              return CommentModalSheet(
                                                topic: reqsnap['topic'],
                                                mentorID: widget.admin
                                                    ? reqsnap['mentor']
                                                    : reqsnap['uid'],
                                              );
                                            }),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(CupertinoIcons.star_fill,
                                                color: rating >= 1
                                                    ? Color(0xFFFFC4DD)
                                                    : Colors.white),
                                            Icon(CupertinoIcons.star_fill,
                                                color: rating >= 2
                                                    ? Color(0xFFFFC4DD)
                                                    : Colors.white),
                                            Icon(CupertinoIcons.star_fill,
                                                color: rating >= 3
                                                    ? Color(0xFFFFC4DD)
                                                    : Colors.white),
                                            Icon(CupertinoIcons.star_fill,
                                                color: rating >= 4
                                                    ? Color(0xFFFFC4DD)
                                                    : Colors.white),
                                            Icon(CupertinoIcons.star_fill,
                                                color: rating >= 5
                                                    ? Color(0xFFFFC4DD)
                                                    : Colors.white),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        '${rating.toStringAsFixed(2)} out of 5.0',
                                        style: GoogleFonts.getFont(
                                          'Noto Sans Display',
                                          textStyle: TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                String roomID =
                                    chatRoomID(user.uid, widget.mentorID);
                                print(roomID);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      //i was here
                                      reqsnap: reqsnap,
                                      Mentorsnap: snap,
                                      admin: widget.admin,
                                      requestID: widget.requestID,
                                      roomID: roomID,
                                      mentorID: widget.mentorID,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFC4DD),
                                ),
                                child: Icon(
                                  CupertinoIcons.chat_bubble,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ),
                            ),
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFeef2f5),
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  final String phoneNumber =
                                      '1234567890'.trim();
                                  final Uri phoneCall =
                                      Uri(scheme: 'tel', path: phoneNumber);
                                  try {
                                    if (await canLaunch(phoneCall.toString())) {
                                      await launch(phoneCall.toString());
                                    }
                                  } catch (e) {
                                    print(e.toString());
                                  }
                                },
                                child: Icon(
                                  CupertinoIcons.phone_circle_fill,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (!widget.admin) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => Rating(
                                        type: widget.topic,
                                        link: reqsnap['link'],
                                        mentorID: widget.mentorID,
                                      ),
                                    ),
                                  );
                                } else {
                                  await makePayment(reqsnap['link']);
                                }
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFC4DD),
                                ),
                                child: Center(
                                  child: FaIcon(
                                    widget.admin
                                        ? FontAwesomeIcons.creditCard
                                        : FontAwesomeIcons.star,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return Container();
                });
          }
          return Container();
        })),
      ),
    );
  }
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
        final link = doc['link'];

        final userRef =
            FirebaseFirestore.instance.collection('users').doc(fromUid);

        final userSnap = await userRef.get();
        final userName = userSnap['name'];
        final img = userSnap['img'];

        print('$userName commented: $commentText');
        comments.add(
            Comment(name: userName, text: commentText, image: img, link: link));
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
                    // const Icon(Icons.toggle_off_outlined),
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
                                print("comment");
                                print(comment.name);
                                return CommentBox(
                                  comment: comment,
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

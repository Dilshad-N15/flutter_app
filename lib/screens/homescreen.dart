// ignore_for_file: prefer_const_constructors
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mentor_mind/model/request_model.dart';
import 'package:mentor_mind/screens/call_pickup_screen.dart';
import 'package:mentor_mind/screens/chat_requests.dart';
import 'package:mentor_mind/screens/description.dart';
import 'package:mentor_mind/screens/profile.dart';
import 'package:mentor_mind/screens/request.dart';
import 'package:mentor_mind/utils/category_box_for_filter.dart';
import 'package:mentor_mind/utils/request_box.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _selectedTopic;
  late String _filtertopic;

  bool _showIcon = false;

  void setStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({"status": status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setStatus("online");
    } else {
      setStatus("offline");
    }
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("online");
    _selectedTopic = 'All';
    _filtertopic = 'All';
  }

  @override
  Widget build(BuildContext context) {
    // _selectedTopic = 'All';
    // _filtertopic = 'All';
    CollectionReference users = _firestore.collection('users');
    return CallPickupScreen(
      scaffold: Scaffold(
        body: FutureBuilder<DocumentSnapshot>(
            future: users.doc(user.uid).get(),
            builder: (((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text(''),
                );
              }
              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> snap =
                    snapshot.data!.data() as Map<String, dynamic>;
                if (snap.containsKey('groups') && snap['groups'].length > 0) {
                  _showIcon = true;
                } else {
                  _showIcon = false;
                }
                return Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    title: Text(
                      'Hello ${snap["name"].toString().split(" ")[0]} 👋',
                    ),
                    actions: [
                      if (_showIcon)
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatRequestsPage(),
                            ),
                          ),
                          child: Icon(
                            CupertinoIcons.chat_bubble_2_fill,
                          ),
                        ),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RequestPage(
                              subjects: Request.topics,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            CupertinoIcons.add,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        ),
                        child: Icon(
                          CupertinoIcons.person_crop_circle_fill,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      const Text(
                        'Find Jobs',
                        style: TextStyle(
                          fontSize: 30,
                          fontFamily: 'Satoshi',
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Expanded(
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return Column(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: Request.types.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            if (Request.types[index] !=
                                                'Others') {
                                              print(
                                                  "creating for ${Request.types[index]}");
                                              return Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedTopic =
                                                          Request.types[index];
                                                      _filtertopic =
                                                          Request.types[index];
                                                    });
                                                  },
                                                  child: CategoryBoxForFilter(
                                                    filterTopic: _filtertopic,
                                                    name: Request.types[index],
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Container();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: FutureBuilder<QuerySnapshot>(
                                          future: FirebaseFirestore.instance
                                              .collection('requests')
                                              .get(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  snapshot) {
                                            if (snapshot.hasError) {
                                              return Text(
                                                  'Something went wrong');
                                            }

                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return LoadingAnimationWidget
                                                  .waveDots(
                                                      color: Colors.white,
                                                      size: 40);
                                            }

                                            return ListView.builder(
                                              physics: BouncingScrollPhysics(),
                                              cacheExtent: 50,
                                              itemCount:
                                                  snapshot.data!.docs.length,
                                              itemBuilder: (context, index) {
                                                Map<String, dynamic> data =
                                                    snapshot.data!.docs[index]
                                                            .data()
                                                        as Map<String, dynamic>;

                                                if (data['uid'] != user.uid &&
                                                    data['mentor'] == "") {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              Description(
                                                            dSnap: data,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: RequestBox(
                                                      type: _selectedTopic,
                                                      dSnap: data,
                                                      col: Colors.primaries[
                                                          Random().nextInt(
                                                        Colors.primaries.length,
                                                      )],
                                                    ),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container();
            }))),
      ),
    );
  }
}

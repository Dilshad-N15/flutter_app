import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mentor_mind/data/get_request_box_data.dart';
import 'package:mentor_mind/utils/status_box.dart';

class PersonalApplicationsView extends StatefulWidget {
  const PersonalApplicationsView({super.key});

  @override
  State<PersonalApplicationsView> createState() =>
      Personal_ApplicationsViewState();
}

class Personal_ApplicationsViewState extends State<PersonalApplicationsView> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> appliedIDsOfUser = [];
  List<QueryDocumentSnapshot> documents = [];

  Future getappliedIDsOfUser() async {
    await _firestore.collection('users').doc(user.uid).get().then((doc) {
      appliedIDsOfUser = doc.data()!['applied'];
    });
  }

  Future getRequests(List<dynamic> requestIds) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    List<Future<QuerySnapshot>> futures = [];

    for (String id in requestIds) {
      futures.add(_firestore
          .collection('requests')
          .where('requestID', isEqualTo: id)
          .get());
    }

    List<QuerySnapshot> snapshots = await Future.wait(futures);

    documents = [];

    for (QuerySnapshot snapshot in snapshots) {
      print(snapshot.docs.first);

      try {
        documents.add(snapshot.docs.first);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Future _handleRefresh() async {
    return await Future.delayed(Duration(seconds: 2));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getappliedIDsOfUser(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child:
                LoadingAnimationWidget.waveDots(color: Colors.white, size: 40),
          );
        }

        if (appliedIDsOfUser.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text('No Applications found.'),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Applications'),
            ),
            body: SingleChildScrollView(
              child: Expanded(
                child: Column(
                  children: [
//
                    Container(
                      height: MediaQuery.of(context).size.height - 70,
                      child: FutureBuilder(
                        future: getRequests(appliedIDsOfUser),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: LoadingAnimationWidget.waveDots(
                                  color: Colors.white, size: 40),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.done) {}

                          return Expanded(
                            child: ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> data = documents[index]
                                    .data() as Map<String, dynamic>;
                                return ApplicationStatusViewBox(
                                  dSnap: data,
                                  col: Colors.primaries[Random()
                                      .nextInt(Colors.primaries.length)],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
//

                    // LiquidPullToRefresh(
                    //   onRefresh: _handleRefresh,
                    //   color: Color(0xFFC31DC7),
                    //   child: SizedBox(
                    //     height: MediaQuery.of(context).size.height,
                    //     child: ListView.builder(
                    //       physics: BouncingScrollPhysics(),
                    //       itemCount: appliedIDsOfUser.length,
                    //       itemBuilder: (BuildContext context, int index) {
                    //         return GetAppliedBoxData(
                    //           docID: appliedIDsOfUser[index],
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          );
        }
        return Container();
      }),
    );
  }
}

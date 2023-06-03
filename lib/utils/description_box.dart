// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DescriptionBox extends StatelessWidget {
  DescriptionBox({super.key, required this.description});
  String description;

  void _launchURL() async {
    if (await canLaunch(description)) {
      await launch(description);
    } else {
      throw 'Could not launch $description';
    }
  }

  @override
  Widget build(BuildContext context) {
    print(description);
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        height: 150,
        child: Column(
          children: [
            Container(
              height: 150,
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
                            CupertinoIcons.pen,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Links',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              // Text('Flutter'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RichText(
                      text: TextSpan(
                        text: description,
                        style: TextStyle(color: Colors.white),
                        recognizer: TapGestureRecognizer()..onTap = _launchURL,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

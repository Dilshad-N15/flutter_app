import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  final String topic;
  final String description;
  final String uid;
  // final String subject;
  final DateTime date;
  final String type;
  final String name;
  final String amount;
  final String requestID;
  final List<String> applicants;
  final String mentor;
  final DateTime datetime;
  final bool payment;
  final String link;
  static List<String> types = [
    'All',
    'Flutter',
    'React JS',
    'Algorithms',
    'DL',
    'ML',
    'Others',
  ];
  static List<String> topics = [
    'Flutter',
    'React JS',
    'Algorithms',
    'DL',
    'ML',
    'Others',
  ];

  Request({
    required this.topic,
    required this.description,
    required this.name,
    required this.uid,
    // required this.subject,
    required this.date,
    required this.type,
    required this.amount,
    required this.requestID,
    this.applicants = const [],
    this.mentor = '',
    required this.datetime,
    this.payment = false,
    this.link = '',
  });

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'description': description,
        'uid': uid,
        // 'subject': subject,
        'date': date,
        'type': type,
        'amount': amount,
        'requestID': requestID,
        'applicants': applicants,
        'mentor': mentor,
        'datetime': datetime,
        'name': name,
        'payment': payment,
        'link': link,
      };

  static Request fromSnap(DocumentSnapshot documentSnapshot) {
    var snapshot = documentSnapshot.data() as Map<String, dynamic>;
    return Request(
      topic: snapshot['topic'],
      name: snapshot['name'],
      description: snapshot['description'],
      uid: snapshot['uid'],
      // subject: snapshot['subject'],
      date: snapshot['date'],
      type: snapshot['type'],
      amount: snapshot['amount'],
      requestID: snapshot['requestID'],
      applicants: snapshot['applicants'],
      mentor: snapshot['mentor'],
      datetime: snapshot['datetime'],
      payment: snapshot['payment'],
      link: snapshot['link'],
    );
  }
}

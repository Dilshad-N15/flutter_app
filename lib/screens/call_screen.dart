import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentor_mind/conf/agora.dart';
import 'package:mentor_mind/model/call.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final Call call;
  final bool isGroupChat;
  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  AgoraClient? client;
  String baseUrl = 'https://whatsapp-clone-rrr.herokuapp.com';

  @override
  void initState() {
    super.initState();
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: AgoraConfig.appId,
        channelName: widget.channelId,
        tokenUrl: baseUrl,
      ),
    );
    initAgora();
  }

  void initAgora() async {
    await client!.initialize();
  }

  void endCall(
    String callerId,
    String receiverId,
  ) async {
    try {
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('call').doc(callerId).delete();
      await firestore.collection('call').doc(receiverId).delete();
    } catch (e) {
      // showSnackBar(context: context, content: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: client == null
          ? const CircularProgressIndicator()
          : SafeArea(
              child: Stack(
                children: [
                  AgoraVideoViewer(client: client!),
                  AgoraVideoButtons(
                    client: client!,
                    disconnectButtonChild: IconButton(
                      onPressed: () async {
                        await client!.engine.leaveChannel();
                        endCall(widget.call.callerId, widget.call.receiverId);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.call_end),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

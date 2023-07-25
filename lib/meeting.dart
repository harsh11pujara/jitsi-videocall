import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_trial/join_meeting.dart';
import 'package:jitsi_trial/user_model.dart';

class Meeting extends StatefulWidget {
  const Meeting({Key? key, required this.uid, required this.isCallComing, this.callUrl}) : super(key: key);
  final String uid;
  final bool isCallComing;
  final String? callUrl;

  @override
  State<Meeting> createState() => _MeetingState();
}

class _MeetingState extends State<Meeting> {
  final serverText = TextEditingController();
  final roomText = TextEditingController(text: "video-call-trial");
  final subjectText = TextEditingController(text: "Group Video Call");
  final tokenText = TextEditingController();
  final userDisplayNameText = TextEditingController();
  final userEmailText = TextEditingController();
  final userAvatarUrlText = TextEditingController();

  bool isAudioMuted = false;
  bool isAudioOnly = false;
  bool isVideoMuted = false;

  List<UserModel> allUsers = [];
  Map<String, dynamic>? userData = {};
  List<String> callList = [];
  String callUrl = "";
  bool isCallComing = false;

  @override
  void initState() {
    super.initState();

    print("is call coming ${widget.isCallComing}");
    getUserData();

    /// Listener for firebase message when app is on
    FirebaseMessaging.onMessage.listen((event) {
      print(event.data["title"]);
      print(event.data["body"]);

      callUrl = event.data["body"];
      isCallComing = true;
      setState(() {});
    });

    isCallComing = widget.isCallComing;
    callUrl = widget.callUrl ?? "";
    setState(() {});
  }

  Future<void> getUserData() async {
    var user = await FirebaseFirestore.instance.collection("Users").doc(widget.uid).get();
    print(user.data());
    userData = user.data();
    userDisplayNameText.text = userData!["name"] ?? "";
    userEmailText.text = userData!["email"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Video Calling'),
          actions: [
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.output)),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("Users").snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          allUsers = snapshot.data!.docs.map((e) {
                            return UserModel.fromJson(e.data());
                          }).toList();
                          allUsers.removeWhere((element) => element.uid.toString() == widget.uid);
                          print(allUsers.length);
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: allUsers.length,
                            itemBuilder: (context, index) {
                              return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  child: ListTile(
                                    leading: IconButton(
                                      icon: Icon(callList.contains(allUsers[index].fmcToken.toString())
                                          ? Icons.check_box_outlined
                                          : Icons.check_box_outline_blank_sharp),
                                      onPressed: () {
                                        if (callList.contains(allUsers[index].fmcToken.toString())) {
                                          callList.remove(allUsers[index].fmcToken.toString());
                                        } else {
                                          callList.add(allUsers[index].fmcToken.toString());
                                        }
                                        print(callList);
                                        setState(() {});
                                      },
                                    ),
                                    minVerticalPadding: 20,
                                    tileColor: Colors.yellow[200],
                                    title: Text(allUsers[index].name.toString()),
                                    subtitle: Text(allUsers[index].email.toString()),
                                  ));
                            },
                          );
                        } else {
                          return const Center(child: Text("No data"));
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 64.0,
                    width: double.maxFinite,
                    child: ElevatedButton(
                      onPressed: () async {
                        print("list  user $callList");
                        List<String> tempList = callList;
                        await JoinMeeting().joinMeeting(
                            nameOrUrl: "group-video-call",
                            creatingRoom: true,
                            userList: tempList,
                            userName: userDisplayNameText.text,
                            userEmail: userEmailText.text,
                          clearList: clearCallList
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                      ),
                      child: const Text(
                        "Join Call",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              isCallComing
                  ? Center(
                      child: Container(
                        height: 150,
                        width: 200,
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              "Call coming",
                              style: TextStyle(color: Colors.white),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      isCallComing = false;
                                      setState(() {});
                                    },
                                    icon: const CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.red,
                                      child: Icon(Icons.close, color: Colors.white),
                                    )),
                                IconButton(
                                    onPressed: () async {
                                      isCallComing = false;
                                      setState(() {});
                                      await JoinMeeting().joinMeeting(nameOrUrl: callUrl, creatingRoom: false, userList: [],userName: userDisplayNameText.text, userEmail: userEmailText.text);
                                      // await launchUrl(Uri.parse(event.notification!.body.toString()),mode: LaunchMode.externalApplication);
                                    },
                                    icon: const CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.green,
                                      child: Icon(Icons.call, color: Colors.white),
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      );
  }

  void clearCallList(){
    callList.clear();
    setState(() {});
  }
}

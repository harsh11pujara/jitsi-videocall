import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jitsi_trial/join_meeting.dart';
import 'package:jitsi_trial/meeting.dart';
import 'package:jitsi_trial/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:jitsi_trial/trial.dart';

String callUrl = "";

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message ${message.messageId}');
  showAwesomeNotification(message);
}

showAwesomeNotification(RemoteMessage message) async{
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 112236,
      channelKey: 'basic_channel',
      title: message.data['title'],
      body: message.data['body'],
      wakeUpScreen: true,
      fullScreenIntent: true,
      autoDismissible: true,
      category: NotificationCategory.Call,
      locked: true,
      displayOnForeground: true,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'accept',
        label: 'Accept',
      ),
      NotificationActionButton(
        isDangerousOption: true,
        key: 'reject',
        label: 'Reject',
        // autoDismissible: true,
        actionType: ActionType.SilentBackgroundAction
      ),
    ],
  );
}

Future<void> onBgAction(ReceivedAction action) async{
  if(action.buttonKeyPressed == "accept"){
    ///Open meeting
    JoinMeeting().joinMeeting(nameOrUrl:  action.body, creatingRoom: false, userName: "Random User", userEmail: "userEmail",userList: []);
  }
  else if(action.buttonKeyPressed == "reject"){
    ///Call reject
  }else{
    ///open app to receive call
    Get.to(Meeting(uid: FirebaseAuth.instance.currentUser!.uid, isCallComing: true,callUrl: action.body,));
  }
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await AwesomeNotifications().requestPermissionToSendNotifications();

  AwesomeNotifications().initialize(
      'resource://drawable/app_icon',
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic Notification',
            channelDescription: 'Hello world',
            importance: NotificationImportance.High,
            channelShowBadge: true,
            vibrationPattern: highVibrationPattern
        ),
      ]
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  AwesomeNotifications().setListeners(onActionReceivedMethod: onBgAction);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Meeting(uid: snapshot.data!.uid.toString(),isCallComing: false,);
          } else {
            return Signup();
          }
        },
      ),
    );
  }
}

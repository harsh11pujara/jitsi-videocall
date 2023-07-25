import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

class JoinMeeting{

  Future<void> joinMeeting({String? nameOrUrl, required bool creatingRoom, String? userName, String? userEmail, required List<String> userList, Function? clearList}) async {
    // String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    Map<String, Object> featureFlags = {};

    // Define meetings options here
    var options = JitsiMeetingOptions(
      roomNameOrUrl: nameOrUrl ?? "",
      serverUrl: null,
      subject:  "Group Video Call",
      token: "",
      isAudioMuted: false,
      isAudioOnly: false,
      isVideoMuted: false,
      userDisplayName: userName ?? "Random User",
      userEmail: userEmail,
      featureFlags: featureFlags,
    );
  print(userList);
    debugPrint("JitsiMeetingOptions: $options");
    await JitsiMeetWrapper.joinMeeting(
      options: options,
      listener: JitsiMeetingListener(
        onOpened: () => debugPrint("onOpened"),
        onConferenceWillJoin: (url) async {
          debugPrint("onConferenceWillJoin: url: $url");
          if (creatingRoom) {
            debugPrint("call list lenght ${userList.length}");
            for (var element in userList) {
              debugPrint("fmc token ${element.toString()}");
              await sendNotificationToOtherUsers(element.toString(), url, userName ?? "Random User" );
            }
            clearList != null? clearList() : null;
          }
        },
        onConferenceJoined: (url) {
          debugPrint("onConferenceJoined: url: $url");
        },
        onConferenceTerminated: (url, error) {
          debugPrint("onConferenceTerminated: url: $url, error: $error");
        },
        onAudioMutedChanged: (isMuted) {
          debugPrint("onAudioMutedChanged: isMuted: $isMuted");
        },
        onVideoMutedChanged: (isMuted) {
          debugPrint("onVideoMutedChanged: isMuted: $isMuted");
        },
        onScreenShareToggled: (participantId, isSharing) {
          debugPrint(
            "onScreenShareToggled: participantId: $participantId, "
                "isSharing: $isSharing",
          );
        },
        onParticipantJoined: (email, name, role, participantId) {
          debugPrint(
            "onParticipantJoined: email: $email, name: $name, role: $role, "
                "participantId: $participantId",
          );
        },
        onParticipantLeft: (participantId) {
          debugPrint("onParticipantLeft: participantId: $participantId");
        },
        onParticipantsInfoRetrieved: (participantsInfo, requestId) {
          debugPrint(
            "onParticipantsInfoRetrieved: participantsInfo: $participantsInfo, "
                "requestId: $requestId",
          );
        },
        onChatMessageReceived: (senderId, message, isPrivate) {
          debugPrint(
            "onChatMessageReceived: senderId: $senderId, message: $message, "
                "isPrivate: $isPrivate",
          );
        },
        onChatToggled: (isOpen) => debugPrint("onChatToggled: isOpen: $isOpen"),
        onClosed: () => debugPrint("onClosed"),
      ),
    );
  }


  Future<void> sendNotificationToOtherUsers(String targetUserToken, String message, String userName) async {
    try {
      String serverKey =
          "AAAA4aA4MsA:APA91bGOv6tW5xa9dQoFEHgqAUWXGt4475CDZtxthlzIu1buMZHg5oURb3IsJgk6HHI4ywOJ4wqgmNJy0YYxnBrds77vHO-eWXkHKowdAj60LaQDnLFB8OchWp6eds68sG4cRkaG7P-p"; // You can find this key in the Firebase Console under "Project settings" -> "Cloud Messaging"
      String url = 'https://fcm.googleapis.com/fcm/send';

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      };

      Map<String, dynamic> data = {
        'to': targetUserToken,
        'data': {
          'title': "${userName} Calling...",
          'body': message,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK', // Optional, customize the action when the user taps the notification
        },
      };

      String body = jsonEncode(data);

      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        print('Notification sent successfully.');
      } else {
        print('Failed to send notification. Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

}
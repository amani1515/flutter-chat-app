import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../model/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Save the FCM token to Firestore
  Future<void> saveFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      String currentUserId = _firebaseAuth.currentUser!.uid;
      // Save the token in Firestore under the current user
      await _firestore.collection('users').doc(currentUserId).update({
        'fcmToken': token,
      });
    }
  }

  // Send message
  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // Create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Construct chat room ID from current user ID and receiver ID
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Add new message to Firestore
    await _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());

    // Send notification to receiver
    sendNotification(receiverId, message);
  }

  // Get messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return _firestore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timeStamp', descending: false).snapshots();
  }

  // Send notification to the receiver
  Future<void> sendNotification(String receiverId, String message) async {
    // Get the receiver's FCM token from Firestore
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(receiverId).get();
    String? receiverToken = userDoc['fcmToken'];

    if (receiverToken != null) {
      // Create the notification payload
      try {
        // Send the notification using Firebase Cloud Messaging
        await _firebaseMessaging.subscribeToTopic(receiverId); // Optionally subscribe user to a topic

        // You can now use a HTTP request to send the notification to the FCM token
        await _firebaseMessaging.sendMessage(
          to: receiverToken,
          data: {
            'title': 'New Message',
            'body': message,
          },
        );
      } catch (e) {
        print("Error sending notification: $e");
      }
    }
  }

  // Delete message
  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print("Error deleting message: $e");
    }
  }

  // Block user
  Future<void> blockUser(String blockedUserId) async {
    String currentUserId = _firebaseAuth.currentUser!.uid;
    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'blockedUsers': FieldValue.arrayUnion([blockedUserId])
      });
    } catch (e) {
      print("Error blocking user: $e");
    }
  }

  // Check if the user is blocked
  Future<bool> isUserBlocked(String blockedUserId) async {
    String currentUserId = _firebaseAuth.currentUser!.uid;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUserId).get();
    List<dynamic> blockedUsers = userDoc['blockedUsers'] ?? [];
    return blockedUsers.contains(blockedUserId);
  }
}

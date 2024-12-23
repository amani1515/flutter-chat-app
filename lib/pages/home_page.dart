import 'package:chatt3/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'setting_page.dart'; // Import the SettingsPage
import 'chat_page.dart'; // Import the ChatPage

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = ''; // State variable for search query
  List<Map<String, dynamic>> _users = []; // List to store user data
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Fetch users when the page is initialized
    _initializeFirebaseMessaging();
  }

  // Initialize Firebase Messaging and set up notification handling
  void _initializeFirebaseMessaging() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission();

    // Get FCM token and save to Firestore
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print("FCM Token: $token");
      _saveFCMToken(token);
    }

    // Listen for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a foreground message: ${message.notification?.title}");
      _showNotificationPopup(message);
    });

    // Listen for background notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("App opened from notification: ${message.notification?.title}");
      _navigateToChatPage(message);
    });

    // Check if the app was opened from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("App opened from terminated state: ${message.notification?.title}");
        _navigateToChatPage(message);
      }
    });
  }

  // Save the FCM token to Firestore
  Future<void> _saveFCMToken(String token) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUserId)
          .update({
        'fcmToken': token,
      });
    } catch (e) {
      print("Error saving FCM token: $e");
    }
  }

  // Function to handle sign out
  void _signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pop(context); // This will take you back to the login page or previous screen
  }

  // Function to navigate to the settings page
  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  // Function to navigate to ChatPage
  void _startChat(String receiverUserEmail, String receiverUserID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          receiverUserEmail: receiverUserEmail,
          receiverUserID: receiverUserID,
        ),
      ),
    );
  }

  // Show a popup notification with the message content
  void _showNotificationPopup(RemoteMessage message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message.notification?.title ?? 'New Message'),
          content: Text(message.notification?.body ?? 'No message content'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToChatPage(message);
              },
              child: Text('Go to Chat'),
            ),
          ],
        );
      },
    );
  }

  // Navigate to the chat page when the notification is tapped
  void _navigateToChatPage(RemoteMessage message) {
    String receiverUserEmail = message.data['receiverEmail'];
    String receiverUserID = message.data['receiverId'];

    _startChat(receiverUserEmail, receiverUserID);
  }

  // Function to fetch users from Firebase Firestore
  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Users').get();
      setState(() {
        _users = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'Settings') {
              _showSettings();  // Navigate to settings page when clicked
            } else if (value == 'Logout') {
              _signOut();
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'Settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ];
          },
        ),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(), // Search bar widget
          Expanded(
            child: _buildUserList(), // List of users
          ),
        ],
      ),
    );
  }

  // Build search bar widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search by email',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query.toLowerCase(); // Update search query
          });
        },
      ),
    );
  }

  // Build the list of users and filter by search query
  Widget _buildUserList() {
    List<Map<String, dynamic>> filteredUsers = _users
        .where((user) {
      return user['email']
          .toString()
          .toLowerCase()
          .contains(_searchQuery);
    })
        .toList();

    if (filteredUsers.isEmpty) {
      return const Center(child: Text('No users found.'));
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        var user = filteredUsers[index];
        return ListTile(
          title: Text(user['displayName'] ?? 'No Display Name'),
          subtitle: Text(user['email'] ?? 'No Email'),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            // Navigate to ChatPage with the necessary details when tapped
            _startChat(user['email'], user['uid']);
          },
        );
      },
    );
  }
}

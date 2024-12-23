import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _displayNameController = TextEditingController();
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  // Fetch current user details (like display name)
  Future<void> _getUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _displayNameController.text = doc['displayName'] ?? '';
        });
      }
    }
  }

  // Update display name
  Future<void> _updateDisplayName() async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'displayName': _displayNameController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name updated!')),
      );
    }
  }

  // Toggle dark mode
  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // Save the preference to SharedPreferences or elsewhere
  }

  // Toggle notifications
  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    // Implement enabling/disabling notifications
  }

  @override
  void initState() {
    super.initState();
    _getUserDetails(); // Get user details when the settings page is opened
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Display Name Setting
            ListTile(
              title: const Text('Display Name'),
              subtitle: TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(hintText: 'Enter your display name'),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.save),
                onPressed: _updateDisplayName,
              ),
            ),
            const Divider(),

            // Dark Mode Setting
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: _toggleDarkMode,
              ),
            ),
            const Divider(),

            // Notifications Setting
            ListTile(
              title: const Text('Enable Notifications'),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ),
            const Divider(),

            // Logout Button
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.logout),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

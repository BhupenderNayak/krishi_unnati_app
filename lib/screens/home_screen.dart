
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:krishi_01/screens/view_profile.dart';

import 'profile_screen.dart';

// 1. CONVERT TO A STATEFULWIDGET
// This allows us to check for data and update the UI.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // 2. ADD STATE VARIABLES
  // To track loading status and if the profile exists.
  bool _isLoading = true;
  bool _profileExists = false;

  @override
  void initState() {
    super.initState();
    _checkProfileStatus();
  }

  // 3. THE CORE LOGIC
  // This function checks Firestore to see if a document exists for the current user.
  Future<void> _checkProfileStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await _firestore.collection('farmers').doc(user.uid).get();
      setState(() {
        _profileExists = doc.exists;
        _isLoading = false;
      });
    } catch (e) {
      // If there's an error, assume no profile and stop loading
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kisan Dashboard'),
        actions: [
          // This profile icon in the corner will ALWAYS take you to the ViewProfileScreen
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewProfileScreen()))
                  .then((_) => _checkProfileStatus()); // Refresh after coming back
            },
            tooltip: 'My Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Welcome, ${user?.email ?? 'Farmer'}!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              // 4. CONDITIONAL UI
              // Show a loading circle, or the correct button based on the profile status.
              if (_isLoading)
                const CircularProgressIndicator()
              else
                _buildProfileButton(context),

              // You can add other dashboard widgets here later
            ],
          ),
        ),
      ),
    );
  }

  // 5. HELPER WIDGET
  // This builds the correct button to keep the main build method clean.
  Widget _buildProfileButton(BuildContext context) {
    if (_profileExists) {
      // If profile exists, show a button to VIEW it.
      return ElevatedButton.icon(
        icon: const Icon(Icons.person),
        label: const Text('View My Profile'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewProfileScreen()))
              .then((_) => _checkProfileStatus()); // Refresh after coming back
        },
      );
    } else {
      // If no profile, show a button to CREATE one.
      return ElevatedButton.icon(
        icon: const Icon(Icons.edit_document),
        label: const Text('Create Your Farmer Profile'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))
              .then((_) => _checkProfileStatus()); // Refresh after you save a new profile
        },
      );
    }
  }
}


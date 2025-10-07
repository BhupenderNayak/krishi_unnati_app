

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:krishi_01/screens/view_profile.dart';

import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _profileExists = false;

  @override
  void initState() {
    super.initState();
    _checkProfileStatus();
  }

  Future<void> _checkProfileStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await _firestore.collection('farmers').doc(user.uid).get();
      if (mounted) {
        setState(() {
          _profileExists = doc.exists;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kisan Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewProfileScreen()))
                  .then((_) => _checkProfileStatus());
            },
            tooltip: 'My Profile',
          ),
          // THIS IS THE CORRECT AND ONLY SIGNOUT LOGIC YOU NEED
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              // The AuthWrapper in main.dart will handle navigation automatically.
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        // ... (The rest of your HomeScreen UI remains the same)
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Welcome, ${user?.email ?? user?.phoneNumber ?? 'Farmer'}!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                _buildProfileButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    // ... (This helper widget also remains the same)
    if (_profileExists) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.person),
        label: const Text('View My Profile'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewProfileScreen()))
              .then((_) => _checkProfileStatus());
        },
        // ... styles
      );
    } else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.edit_document),
        label: const Text('Create Your Farmer Profile'),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))
              .then((_) => _checkProfileStatus());
        },
        // ... styles
      );
    }
  }
}
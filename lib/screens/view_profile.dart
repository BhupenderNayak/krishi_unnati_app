import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _profileData;

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return _firestore.collection('farmers').doc(user.uid).get();
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Profile?'),
          content: const Text('Are you sure you want to delete your profile? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  final user = _auth.currentUser;
                  if (user != null) {
                    await _firestore.collection('farmers').doc(user.uid).delete();
                  }
                  if (mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                } catch (e) {

                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _showDeleteConfirmationDialog,
            tooltip: 'Delete Profile',
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile.'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No profile found. Please create one.'));
          }


          _profileData = snapshot.data!.data();
          final data = _profileData!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileItem('Name', data['name']),
                _buildProfileItem('Preferred Language', data['preferredLanguage']),
                _buildProfileItem('Farm Size', '${data['farmSizeAcres']} acres'),
                _buildProfileItem('Address', data['address']),
                _buildProfileItem('Soil Type/ID', data['soilTypeOrId']),
                _buildProfileItem('Irrigation Source', data['irrigationSource']),
                _buildProfileItem('Owned Equipment', (data['ownedEquipment'] as List).join(', ')),
                _buildProfileItem('Current Crops', (data['primaryCrops'] as List).join(', ')),
                _buildProfileItem('Crop History', data['pastCropHistory']),
                _buildProfileItem('Past Yields', data['pastYieldsPerAcre']),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {

          if (_profileData != null) {
            Navigator.push(
              context,
              MaterialPageRoute(

                builder: (context) => ProfileScreen(initialData: _profileData),
              ),
            ).then((_) {

              setState(() {});
            });
          }
        },
        label: const Text('Edit Profile'),
        icon: const Icon(Icons.edit),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }
}


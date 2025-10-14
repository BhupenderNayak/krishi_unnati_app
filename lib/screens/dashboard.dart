import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:krishi_01/screens/view_profile.dart';
import 'package:krishi_01/screens/profile_screen.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _userName;
  bool _isLoading = true;
  bool _profileExists = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    setState(() {
      _userName = user.displayName ?? user.phoneNumber ?? "Kisan";
    });
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
    final String formattedDate = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
        children: [
          Text(
            'Namaste, ${_userName ?? "Kisan"}!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            formattedDate,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ))
          else
            _buildProfileButton(context),
          const SizedBox(height: 24),
          _buildWeatherCard(),
          const SizedBox(height: 20),
          _buildSectionTitle('Quick Stats'),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Onion Price', '₹1,850 /q', Icons.trending_up, Colors.orange.shade700),
              _buildStatCard('Soil Moisture', '45% (Good)', Icons.water_drop, Colors.blue.shade700),
              _buildStatCard('Next Task', 'Irrigation', Icons.task_alt, Colors.green.shade700),
              _buildStatCard('Fertilizer', 'Urea (Stock)', Icons.eco, Colors.brown.shade700),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Tip of the Day'),
          const SizedBox(height: 10),
          _buildTipCard(),
        ],
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    if (_profileExists) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(Icons.person_outline, color: Colors.green[700]),
          title: const Text('View My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewProfileScreen()))
                .then((_) => _fetchUserData());
          },
        ),
      );
    } else {
      return Card(
        color: Colors.green[50],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(Icons.edit_note, color: Colors.orange[800]),
          title: const Text('Complete Your Farmer Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('To get better recommendations'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))
                .then((_) => _fetchUserData());
          },
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.wb_cloudy, color: Colors.white, size: 50),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sabzi Mandi, Delhi', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('28°C, Haze', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                Text('Humidity: 65%', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Card(
      color: Colors.green[50],
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: const ListTile(
        leading: Icon(Icons.lightbulb_outline_rounded, color: Colors.green),
        title: Text('Din ki Salah', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Mitti ki jaanch har 2 saal mein karayein taaki sahi khaad ka istemaal ho sake.'),
      ),
    );
  }
}
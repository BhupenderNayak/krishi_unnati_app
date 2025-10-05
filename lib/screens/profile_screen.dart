import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();


  final _nameController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _cropsController = TextEditingController();


  Position? _currentPosition;
  String _locationMessage = "No location selected";
  bool _isFetchingLocation = false;


  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationMessage = "Location permission denied.");
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _locationMessage = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
      });
    } catch (e) {
      setState(() => _locationMessage = "Could not fetch location.");
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }


  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fetch your location first.')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('farmers').doc(user.uid).set({
        'name': _nameController.text,
        'farmSizeAcres': double.tryParse(_farmSizeController.text) ?? 0,
        'primaryCrops': _cropsController.text.split(','),
        'location': GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        'profileComplete': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextField(_nameController, 'Full Name', 'Please enter your name'),
              const SizedBox(height: 16),
              _buildTextField(_farmSizeController, 'Farm Size (in acres)', 'Please enter farm size', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_cropsController, 'Primary Crops (comma-separated)', 'Please enter your crops'),
              const SizedBox(height: 24),


              const Text('Farm Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(_locationMessage)),
                    _isFetchingLocation
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator())
                        : IconButton(icon: const Icon(Icons.my_location, color: Colors.green), onPressed: _getCurrentLocation),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Profile', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextField(TextEditingController controller, String label, String validationMessage, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }
}

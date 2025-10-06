import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ProfileScreen extends StatefulWidget {
  // 1. THIS CONSTRUCTOR IS THE KEY CHANGE
  // It accepts an optional map of data. If the map is provided,
  // the screen knows it's in "Edit Mode".
  final Map<String, dynamic>? initialData;

  const ProfileScreen({super.key, this.initialData});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _primaryCropsController = TextEditingController();
  final _soilTypeController = TextEditingController();
  final _ownedEquipmentController = TextEditingController();
  final _cropHistoryController = TextEditingController();
  final _pastYieldsController = TextEditingController();
  final _pastPricesController = TextEditingController();

  String? _selectedIrrigationSource;
  final List<String> _irrigationOptions = ['Canal', 'Well', 'Borewell', 'Rain-fed', 'Drip', 'Sprinkler', 'Other'];
  String? _selectedLanguage;
  final List<String> _languageOptions = ['English', 'Hindi', 'Marathi', 'Punjabi', 'Telugu', 'Tamil', 'Other'];

  Position? _currentPosition;
  String _locationMessage = "No location selected";
  bool _isFetchingLocation = false;
  String _address = "";

  // 2. THE initState METHOD
  // This runs when the screen is first built. We check for initialData here
  // and pre-fill all the form fields if it exists.
  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _nameController.text = data['name'] ?? '';
      _farmSizeController.text = data['farmSizeAcres']?.toString() ?? '';
      _primaryCropsController.text = (data['primaryCrops'] as List<dynamic>?)?.join(', ') ?? '';
      _soilTypeController.text = data['soilTypeOrId'] ?? '';
      _ownedEquipmentController.text = (data['ownedEquipment'] as List<dynamic>?)?.join(', ') ?? '';
      _cropHistoryController.text = data['pastCropHistory'] ?? '';
      _pastYieldsController.text = data['pastYieldsPerAcre'] ?? '';
      _pastPricesController.text = data['pastSalePrices'] ?? '';

      // Pre-select dropdowns
      _selectedIrrigationSource = data['irrigationSource'];
      _selectedLanguage = data['preferredLanguage'];

      // Pre-fill location
      _address = data['address'] ?? '';
      _locationMessage = _address.isNotEmpty ? _address : "Location data exists";
      if (data['location'] != null) {
        final locationPoint = data['location'] as GeoPoint;
        _currentPosition = Position(
            latitude: locationPoint.latitude,
            longitude: locationPoint.longitude,
            timestamp: DateTime.now(), accuracy: 50, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _farmSizeController.dispose();
    _primaryCropsController.dispose();
    _soilTypeController.dispose();
    _ownedEquipmentController.dispose();
    _cropHistoryController.dispose();
    _pastYieldsController.dispose();
    _pastPricesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() { _isFetchingLocation = true; _locationMessage = "Fetching location..."; });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationMessage = "Location permission denied.");
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await _getAddressFromLatLng(position);
      setState(() {
        _currentPosition = position;
        _locationMessage = _address;
      });
    } catch (e) {
      setState(() => _locationMessage = "Could not fetch location or address.");
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      });
    } catch (e) {
      setState(() { _address = "Could not determine address."; });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fetch your location first.')));
        return;
      }

      await FirebaseFirestore.instance.collection('farmers').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'preferredLanguage': _selectedLanguage ?? '',
        'farmSizeAcres': double.tryParse(_farmSizeController.text.trim()) ?? 0,
        'soilTypeOrId': _soilTypeController.text.trim(),
        'irrigationSource': _selectedIrrigationSource ?? '',
        'ownedEquipment': _ownedEquipmentController.text.split(',').map((e) => e.trim()).toList(),
        'primaryCrops': _primaryCropsController.text.split(',').map((e) => e.trim()).toList(),
        'pastCropHistory': _cropHistoryController.text.trim(),
        'pastYieldsPerAcre': _pastYieldsController.text.trim(),
        'pastSalePrices': _pastPricesController.text.trim(),
        'location': GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
        'address': _address,
        'profileComplete': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 3. DYNAMIC TITLE
        title: Text(widget.initialData == null ? 'Create Profile' : 'Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
            tooltip: 'Save Profile',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // -- Sections and Fields (This part remains the same) --
              _buildSectionHeader('Personal Details'),
              _buildTextField(_nameController, 'Full Name', 'Please enter your name'),
              const SizedBox(height: 16),
              _buildDropdownField(_languageOptions, 'Preferred Language', (val) => setState(() => _selectedLanguage = val), _selectedLanguage),
              const SizedBox(height: 24),
              _buildSectionHeader('Farm & Equipment Details'),
              _buildTextField(_farmSizeController, 'Farm Size (in acres)', 'Please enter farm size', keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_soilTypeController, 'Soil Type / Soil Health Card ID', 'Please enter soil details'),
              const SizedBox(height: 16),
              _buildDropdownField(_irrigationOptions, 'Irrigation Source', (val) => setState(() => _selectedIrrigationSource = val), _selectedIrrigationSource),
              const SizedBox(height: 16),
              _buildTextField(_ownedEquipmentController, 'Owned Equipment (e.g. Tractor, Pump)', 'Please list equipment'),
              const SizedBox(height: 24),
              _buildSectionHeader('Crop History'),
              _buildTextField(_primaryCropsController, 'Current Primary Crops (comma-separated)', 'Please enter current crops'),
              const SizedBox(height: 16),
              _buildTextField(_cropHistoryController, 'Past 3–5 Seasons\' Crop History', 'Please describe past crops', maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField(_pastYieldsController, 'Past Yields (per Acre, e.g. 25 quintal)', 'Please enter past yields'),
              const SizedBox(height: 16),
              _buildTextField(_pastPricesController, 'Past Sale Prices (Optional)', 'You can leave this empty', isOptional: true),
              const SizedBox(height: 24),
              _buildSectionHeader('Farm Location'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Expanded(child: Text(_locationMessage, style: const TextStyle(fontSize: 14))),
                    _isFetchingLocation
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.0))
                        : IconButton(icon: const Icon(Icons.my_location, color: Colors.green), onPressed: _getCurrentLocation, tooltip: 'Get Current Location'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: Center(child: const Text('Save Profile', style: TextStyle(fontSize: 18))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String validationMessage, {TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(List<String> items, String label, ValueChanged<String?> onChanged, String? value) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select an option' : null,
    );
  }
}


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PriceRecord {
  final String date;
  final String minPrice;
  final String maxPrice;
  final String modalPrice;

  PriceRecord({
    required this.date,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
  });

  factory PriceRecord.fromJson(Map<String, dynamic> json) {
    return PriceRecord(
      date: json['date'] ?? 'N/A',
      minPrice: json['min_price'] ?? 'N/A',
      maxPrice: json['max_price'] ?? 'N/A',
      modalPrice: json['modal_price'] ?? 'N/A',
    );
  }
}

class ApiResponse {
  final List<PriceRecord> results;
  final String? error;

  ApiResponse({required this.results, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var resultsList = json['results'] as List?;
    List<PriceRecord> records = resultsList != null
        ? resultsList.map((i) => PriceRecord.fromJson(i)).toList()
        : [];
    return ApiResponse(
      results: records,
      error: json['error'],
    );
  }
}


class KrishiApp extends StatelessWidget {
  const KrishiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: const PriceFinderScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PriceFinderScreen extends StatefulWidget {
  const PriceFinderScreen({super.key});

  @override
  State<PriceFinderScreen> createState() => _PriceFinderScreenState();
}

class _PriceFinderScreenState extends State<PriceFinderScreen> {

  final List<String> _commodities = ["Onion", "Potato", "Tomato", "Wheat", "Paddy"];
  final Map<String, Map<String, List<String>>> _locationData = {
    "Maharashtra": {
      "Pune": ["Pune"],
      "Nashik": ["Nasik", "Lasalgaon"]
    },
    "Karnataka": {
      "Bangalore": ["Bangalore"],
      "Belgaum": ["Belgaum"]
    },
    "Uttar Pradesh": {
      "Agra": ["Agra"],
      "Lucknow": ["Lucknow"]
    }
  };

  // User selections
  String? _selectedCommodity;
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedMarket;

  // UI state
  bool _isLoading = false;
  ApiResponse? _apiResponse;
  String? _errorMessage;

  // --- 3. API Call Logic ---
  Future<void> _fetchPrices() async {
    if (_selectedCommodity == null ||
        _selectedState == null ||
        _selectedDistrict == null ||
        _selectedMarket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all the fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _apiResponse = null;
      _errorMessage = null;
    });


    const String host = '10.223.35.72'; // Your computer ip address
    final url = Uri.parse(
        'http://$host:5000/price?commodity=$_selectedCommodity&state=$_selectedState&district=$_selectedDistrict&market=$_selectedMarket&days=7');

    print('Calling API: $url');

    try {

      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _apiResponse = ApiResponse.fromJson(data);
          if(_apiResponse!.error != null){
            _errorMessage = _apiResponse!.error;
          } else if (_apiResponse!.results.isEmpty){
            _errorMessage = "No price data found for the selected criteria in the last 7 days.";
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Server returned an error: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to connect to the server. Make sure your Python API is running and accessible.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdown(
              hint: 'Select Commodity',
              value: _selectedCommodity,
              items: _commodities,
              onChanged: (value) {
                setState(() => _selectedCommodity = value);
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              hint: 'Select State',
              value: _selectedState,
              items: _locationData.keys.toList(),
              onChanged: (value) {
                setState(() {
                  _selectedState = value;
                  _selectedDistrict = null;
                  _selectedMarket = null;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              hint: 'Select District',
              value: _selectedDistrict,
              items: _selectedState != null
                  ? _locationData[_selectedState]!.keys.toList()
                  : [],
              onChanged: (value) {
                setState(() {
                  _selectedDistrict = value;
                  _selectedMarket = null;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              hint: 'Select Market',
              value: _selectedMarket,
              items: _selectedState != null && _selectedDistrict != null
                  ? _locationData[_selectedState]![_selectedDistrict]!
                  : [],
              onChanged: (value) {
                setState(() => _selectedMarket = value);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchPrices,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Get Prices'),
            ),
            const SizedBox(height: 24),
            _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  // --- 5. Helper Widgets ---
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      isExpanded: true,
    );
  }

  Widget _buildResultsSection() {
    if (_isLoading) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Fetching prices from server...\nThis can take up to 2 minutes. Please be patient.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    if (_errorMessage != null) {
      return Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: $_errorMessage',
            style: TextStyle(color: Colors.red[800], fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_apiResponse != null && _apiResponse!.results.isNotEmpty) {
      return _buildResultsTable();
    }
    return const SizedBox.shrink();
  }

  Widget _buildResultsTable() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
          columnSpacing: 10,
          columns: const [
            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Min', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Max', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Modal', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _apiResponse!.results.map((record) => DataRow(
            cells: [
              DataCell(Text(record.date)),
              DataCell(Text(record.minPrice)),
              DataCell(Text(record.maxPrice)),
              DataCell(Text(record.modalPrice)),
            ],
          )).toList(),
        ),
      ),
    );
  }
}
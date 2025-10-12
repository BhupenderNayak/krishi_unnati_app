import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/database.dart';


class ApiService {

  final String _priceApiBaseUrl = 'http://10.223.35.72:5000';  // Your ip address of computer:5000
  final String _chatApiBaseUrl = 'http://10.223.35.72:5001';   // Your ip address of computer:5001


  Future<List<dynamic>> fetchCropPrices({
    required String commodity,
    required String state,
    required String district,
    required String market,
  }) async {
    final uri = Uri.parse('$_priceApiBaseUrl/price').replace(queryParameters: {
      'commodity': commodity,
      'state': state,
      'district': district,
      'market': market,
    });
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Server se price nahi mila');
      }
    } catch (e) {
      throw Exception('Price server se connect nahi ho paaya.');
    }
  }


  Future<String> chatWithBot(String message) async {
    final uri = Uri.parse('$_chatApiBaseUrl/chat');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'message': message}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['reply'] ?? 'Bot se jawaab nahi mila.';
      } else {
        throw Exception('Server se chat reply nahi mila');
      }
    } catch (e) {
      throw Exception('Chatbot server se connect nahi ho paaya.');
    }
  }


  Future<List<Product>> fetchProducts() async {
    try {

      final String jsonString = await rootBundle.loadString('assets/products.json');


      final List<dynamic> productData = json.decode(jsonString);


      return productData.map((data) => Product.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching local products: $e');
      throw Exception('Could not load products from assets.');
    }
  }
}
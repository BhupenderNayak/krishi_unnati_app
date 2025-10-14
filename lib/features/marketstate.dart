import 'package:flutter/material.dart';
import 'dart:async';

// Main widget, same structure as before
class MarketplaceTab extends StatelessWidget {
  const MarketplaceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Farmer Marketplace'),
          backgroundColor: Colors.green.shade800,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            tabs: [
              Tab(icon: Icon(Icons.storefront_outlined), text: 'Sell'),
              Tab(icon: Icon(Icons.local_shipping_outlined), text: 'Track'),
              Tab(icon: Icon(Icons.science_outlined), text: 'Lab Test'),
              Tab(icon: Icon(Icons.verified_user_outlined), text: 'Services'),
              Tab(icon: Icon(Icons.account_balance_wallet_outlined), text: 'Payments'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SellGoodsView(),
            TrackStatusView(),
            LabTestingView(),
            ServicesView(),
            PaymentsView(),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------
// 1. Sell Goods Tab (Now fully interactive)
// -----------------------------------------
class SellGoodsView extends StatefulWidget {
  const SellGoodsView({super.key});

  @override
  State<SellGoodsView> createState() => _SellGoodsViewState();
}

class _SellGoodsViewState extends State<SellGoodsView> {
  // Converted to a non-final list to allow adding new items
  final List<Map<String, dynamic>> _products = [
    {'name': 'Hybrid Wheat Seeds', 'price': '₹2,500 / quintal', 'status': 'Listed', 'icon': Icons.grain},
    {'name': 'Organic Tomatoes', 'price': '₹1,800 / quintal', 'status': 'Listed', 'icon': Icons.local_florist},
    {'name': 'Basmati Rice', 'price': '₹6,000 / quintal', 'status': 'Sold Out', 'icon': Icons.rice_bowl},
  ];

  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();

  // Function to handle adding the new product to the list
  void _addProduct() {
    if (_productNameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
      setState(() {
        _products.insert(0, {
          'name': _productNameController.text,
          'price': _priceController.text,
          'status': 'Listed',
          'icon': Icons.eco, // Generic icon for new items
        });
      });
      _productNameController.clear();
      _priceController.clear();
      Navigator.pop(context); // Close the bottom sheet
    }
  }

  void _showAddProductSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('List a New Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _productNameController, decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price (e.g., ₹2000 / quintal)', border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _addProduct, child: const Text('Add Product')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green.shade50,
                child: Icon(product['icon'], color: Colors.green.shade600, size: 30),
              ),
              title: Text(product['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(product['price']!, style: TextStyle(color: Colors.grey.shade700)),
              trailing: Chip(
                label: Text(product['status']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: product['status'] == 'Listed' ? Colors.blue.shade600 : Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductSheet,
        label: const Text('Sell New Item'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}

// -----------------------------------------
// 2. Track Status Tab (No change needed)
// -----------------------------------------
class TrackStatusView extends StatelessWidget { /* ... existing code ... */
  const TrackStatusView({super.key});

  final List<Map<String, dynamic>> _shipments = const [
    {'id': 'TRK789012', 'item': '100kg Wheat to Delhi', 'status': 'In Transit', 'steps': [
      {'title': 'Order Confirmed', 'done': true}, {'title': 'Packed', 'done': true}, {'title': 'Dispatched', 'done': true},
      {'title': 'In Transit', 'done': true}, {'title': 'Out for Delivery', 'done': false}, {'title': 'Delivered', 'done': false},
    ]},
    {'id': 'TRK789011', 'item': '200kg Rice to Jaipur', 'status': 'Delivered', 'steps': [
      {'title': 'Order Confirmed', 'done': true}, {'title': 'Packed', 'done': true}, {'title': 'Dispatched', 'done': true},
      {'title': 'In Transit', 'done': true}, {'title': 'Out for Delivery', 'done': true}, {'title': 'Delivered', 'done': true},
    ]},
  ];

  @override
  Widget build(BuildContext context) { /* ... same as previous version ... */
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _shipments.length,
      itemBuilder: (context, index) {
        final shipment = _shipments[index];
        return Card(
            elevation: 5, margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shipment['item'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('ID: ${shipment['id']}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),
                  ...List.generate(shipment['steps'].length, (stepIndex) {
                    final step = shipment['steps'][stepIndex];
                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(color: step['done'] ? Colors.green : Colors.grey.shade300, shape: BoxShape.circle),
                                child: const Icon(Icons.check, color: Colors.white, size: 14),
                              ),
                              if (stepIndex < shipment['steps'].length - 1)
                                Expanded(child: Container(width: 2, color: step['done'] ? Colors.green : Colors.grey.shade300)),
                            ],
                          ),
                          const SizedBox(width: 15),
                          Text(step['title'], style: TextStyle(fontWeight: step['done'] ? FontWeight.w600 : FontWeight.normal, color: step['done'] ? Colors.black : Colors.grey)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            )
        );
      },
    );
  }
}

// -----------------------------------------
// 3. Lab Testing Tab (Now shows pending requests)
// -----------------------------------------
class LabTestingView extends StatefulWidget {
  const LabTestingView({super.key});

  @override
  State<LabTestingView> createState() => _LabTestingViewState();
}

class _LabTestingViewState extends State<LabTestingView> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _selectedSampleType;

  // List to store the submitted requests
  final List<Map<String, String>> _testRequests = [];

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 2));

      // Add the new request to our list
      setState(() {
        _isLoading = false;
        _testRequests.insert(0, {
          'type': _selectedSampleType!,
          'desc': _descriptionController.text,
          'status': 'Pending',
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Success! Your request has been submitted.'), backgroundColor: Colors.green),
      );
      _formKey.currentState!.reset();
      _descriptionController.clear();
      setState(() => _selectedSampleType = null);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // The Form section
          Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.biotech, size: 60, color: Colors.green),
                const SizedBox(height: 16),
                const Text('Request Produce Testing', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Get a digital report on the quality of your produce.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 30),
                DropdownButtonFormField<String>(
                  value: _selectedSampleType,
                  decoration: const InputDecoration(labelText: 'Sample Type', border: OutlineInputBorder()),
                  items: ['Soil', 'Wheat Seeds', 'Maize Seeds', 'Water', 'Pesticide Residue']
                      .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedSampleType = value),
                  validator: (value) => value == null ? 'Please select a sample type' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description (e.g., from North Field)', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Submit Request', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // **NEW**: Displaying the list of submitted requests
          if (_testRequests.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Your Requests", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _testRequests.length,
                  itemBuilder: (context, index) {
                    final request = _testRequests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.hourglass_top, color: Colors.orange),
                        title: Text(request['type']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(request['desc']!),
                        trailing: Chip(
                          label: Text(request['status']!, style: const TextStyle(color: Colors.white)),
                          backgroundColor: Colors.orange.shade700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
        ],
      ),
    );
  }
}

// -----------------------------------------
// 4. Services Tab (Now navigates to new pages)
// -----------------------------------------
class ServicesView extends StatelessWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildServiceCard(
          context: context,
          title: 'Crop Insurance',
          description: 'Protect your crops from unforeseen events. Secure your investment.',
          icon: Icons.shield_outlined,
          color: Colors.blue,
          buttonText: 'Explore Insurance Plans',
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const InsuranceListPage()));
          },
        ),
        const SizedBox(height: 20),
        _buildServiceCard(
          context: context,
          title: 'Farmer Loans',
          description: 'Get easy, low-interest loans for buying seeds, fertilizers, and equipment.',
          icon: Icons.local_atm,
          color: Colors.green,
          buttonText: 'Apply for a Loan',
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LoanListPage()));
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required BuildContext context, required String title, required String description,
    required IconData icon, required Color color, required String buttonText, required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 45),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Text(description, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(buttonText),
            )
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------
// 5. Payments Tab (No change needed)
// -----------------------------------------
class PaymentsView extends StatefulWidget { /* ... existing code ... */
  const PaymentsView({super.key});
  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}
class _PaymentsViewState extends State<PaymentsView> { /* ... same as previous version ... */
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Map<String, String>> _transactions = [];
  bool _isLoading = true;
  @override
  void initState() { super.initState(); _loadTransactions(); }
  void _loadTransactions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
    final dummyData = [
      {'amount': '+ ₹15,000', 'desc': 'From "National Traders" for Wheat', 'date': 'Oct 12, 2025'},
      {'amount': '- ₹2,500', 'desc': 'For "Urea Fertilizer"', 'date': 'Oct 10, 2025'},
      {'amount': '+ ₹8,000', 'desc': 'From "Local Mandi" for Tomatoes', 'date': 'Oct 9, 2025'},
      {'amount': '- ₹1,200', 'desc': 'For "Sprayer Pump"', 'date': 'Oct 7, 2025'},
    ];
    for (var i = 0; i < dummyData.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _transactions.add(dummyData[i]);
      _listKey.currentState?.insertItem(i);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity, color: Colors.green.shade50, padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            const Text('Available Balance', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 5),
            Text('₹ 2,45,750.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
          ]),
        ),
        const Padding(padding: EdgeInsets.all(16.0), child: Align(alignment: Alignment.centerLeft, child: Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
        if (_isLoading) const Expanded(child: Center(child: CircularProgressIndicator()))
        else Expanded(
          child: AnimatedList(
            key: _listKey, initialItemCount: _transactions.length,
            itemBuilder: (context, index, animation) {
              final transaction = _transactions[index]; final isCredit = transaction['amount']!.startsWith('+');
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: FadeTransition(
                  opacity: animation,
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: isCredit ? Colors.green.shade100 : Colors.red.shade100, child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? Colors.green : Colors.red)),
                    title: Text(transaction['desc']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(transaction['date']!),
                    trailing: Text(transaction['amount']!, style: TextStyle(fontWeight: FontWeight.bold, color: isCredit ? Colors.green : Colors.red, fontSize: 16)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


// -----------------------------------------
// **NEW PAGES** for Insurance and Loans
// -----------------------------------------

// Page to show a list of dummy insurance plans
class InsuranceListPage extends StatelessWidget {
  const InsuranceListPage({super.key});

  final List<Map<String, String>> insurancePlans = const [
    {'name': 'Basic Crop Cover', 'coverage': 'Drought & Flood', 'premium': '₹500 / acre'},
    {'name': 'All-Risk Weather Shield', 'coverage': 'All weather events', 'premium': '₹1200 / acre'},
    {'name': 'Pest & Disease Guard', 'coverage': 'Specific pest attacks', 'premium': '₹750 / acre'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insurance Plans'), backgroundColor: Colors.blue.shade700),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: insurancePlans.length,
        itemBuilder: (context, index) {
          final plan = insurancePlans[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.policy, color: Colors.blue, size: 40),
              title: Text(plan['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Covers: ${plan['coverage']!}\nPremium: ${plan['premium']!}"),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}

// Page to show a list of dummy loan options
class LoanListPage extends StatelessWidget {
  const LoanListPage({super.key});

  final List<Map<String, String>> loanOptions = const [
    {'name': 'Kisan Credit Card (KCC)', 'rate': '4% - 7%', 'tenure': 'Up to 5 years'},
    {'name': 'Equipment Purchase Loan', 'rate': '8.5%', 'tenure': 'Up to 7 years'},
    {'name': 'Short-Term Crop Loan', 'rate': '7%', 'tenure': 'Up to 1 year'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Options'), backgroundColor: Colors.green.shade700),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: loanOptions.length,
        itemBuilder: (context, index) {
          final loan = loanOptions[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.request_quote, color: Colors.green, size: 40),
              title: Text(loan['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Interest Rate: ${loan['rate']!}\nTenure: ${loan['tenure']!}"),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
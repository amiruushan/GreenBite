import 'package:flutter/material.dart';

void main() {
  runApp(const CustomerManagementApp());
}

class CustomerManagementApp extends StatelessWidget {
  const CustomerManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const CustomerManagement(),
    );
  }
}

class CustomerManagement extends StatefulWidget {
  const CustomerManagement({super.key});

  @override
  _CustomerManagementState createState() => _CustomerManagementState();
}

class _CustomerManagementState extends State<CustomerManagement> {
  // Placeholder for customers list
  List<Map<String, dynamic>> customers = [
    {
      'id': 1,
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'status': 'Active'
    },
    {
      'id': 2,
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'status': 'Active'
    },
  ];

  // Placeholder API request simulation
  Future<void> fetchCustomers() async {
    // Simulate a delay for fetching data from API
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Simulating response data
      customers = [
        {
          'id': 1,
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'status': 'Active'
        },
        {
          'id': 2,
          'name': 'Jane Smith',
          'email': 'jane.smith@example.com',
          'status': 'Active'
        },
      ];
    });
  }

  // Simulated delete function
  Future<void> deleteCustomer(int id) async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      customers.removeWhere((customer) => customer['id'] == id);
    });
  }

  // Simulated ban function
  Future<void> banCustomer(int id) async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      var customer = customers.firstWhere((customer) => customer['id'] == id);
      customer['status'] = 'Banned';
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Management"),
        backgroundColor: Colors.green.shade700,
      ),
      body: customers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.green.shade50,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        customer['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green.shade800,
                        ),
                      ),
                      subtitle: Text(
                        customer['email'],
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              // Implement edit functionality here
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.block,
                              color: Colors.red,
                            ),
                            onPressed: () => banCustomer(customer['id']),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.black,
                            ),
                            onPressed: () => deleteCustomer(customer['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

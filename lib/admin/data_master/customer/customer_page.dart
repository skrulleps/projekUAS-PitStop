import 'package:flutter/material.dart';
import 'package:pitstop/data/api/customer/customer_service.dart';
import 'package:pitstop/data/model/customer/customer_model.dart';
import 'package:pitstop/admin/data_master/customer/pages/edit_customer_page.dart';
import 'package:pitstop/admin/data_master/customer/pages/customer_form.dart';
import 'package:pitstop/admin/data_master/customer/pages/customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  List<CustomerModel> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await CustomerService().getCustomers();
    setState(() {
      _customers = customers ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Data Customer'),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : RefreshIndicator(
              onRefresh: _loadCustomers,
              color: Colors.amber,
              child: _customers.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            'Tidak ada data customer.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _customers.length,
                      itemBuilder: (context, index) {
                        final customer = _customers[index];
                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                            leading: const Icon(Icons.person, color: Colors.amber),
                            title: Text(
                              customer.fullName ?? 'No Name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Phone: ${customer.phone ?? "-"}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  'Address: ${customer.address ?? "-"}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.amber),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) => EditCustomerPage(
                                              customer: customer,
                                            ),
                                          ),
                                        )
                                        .then((value) {
                                      if (value == true) _loadCustomers();
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () async {
                                    final customerId = customer.id;
                                    if (customerId == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('ID customer tidak valid'),
                                        ),
                                      );
                                      return;
                                    }

                                    final success = await CustomerService().deleteCustomer(customerId);
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Data customer berhasil dihapus'),
                                        ),
                                      );
                                      _loadCustomers();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Gagal menghapus data customer'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CustomerDetailPage(customer: customer),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const CustomerFormPage(),
                ),
              )
              .then((value) {
            if (value == true) _loadCustomers();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

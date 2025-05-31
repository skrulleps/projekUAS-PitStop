import 'package:flutter/material.dart';
import 'package:pitstop/admin/data_master/customer/service/customer_service.dart';
import 'package:pitstop/admin/data_master/customer/model/customer_model.dart';
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
    if (customers != null) {
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } else {
      setState(() {
        _customers = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Customer'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return ListTile(
                  title: Text(customer.fullName ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phone: ${customer.phone ?? '-'}'),
                      Text('Address: ${customer.address ?? '-'}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditCustomerPage(customer: customer),
                            ),
                          )
                              .then((value) {
                            if (value == true) {
                              _loadCustomers();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final customerId = _customers[index].id;
                          if (customerId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('ID customer tidak valid')),
                            );
                            return;
                          }
                          final success = await CustomerService()
                              .deleteCustomer(customerId);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Data customer berhasil dihapus')),
                            );
                            await _loadCustomers();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Gagal menghapus data customer')),
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const CustomerFormPage(),
                ),
              )
              .then((value) {
            if (value == true) {
              _loadCustomers();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

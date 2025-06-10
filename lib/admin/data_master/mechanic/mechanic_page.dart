import 'package:flutter/material.dart';
import 'package:pitstop/data/api/mechanic/mechanic_service.dart';
import 'package:pitstop/admin/data_master/mechanic/state/mechanic_state.dart';
import 'package:pitstop/admin/data_master/mechanic/pages/edit_mechanic_page.dart';
import 'package:pitstop/admin/data_master/mechanic/pages/mechanic_form.dart';

class MechanicPage extends StatefulWidget {
  const MechanicPage({Key? key}) : super(key: key);

  @override
  State<MechanicPage> createState() => _MechanicPageState();
}

class _MechanicPageState extends State<MechanicPage> {
  MechanicState _state = MechanicState.initial();

  @override
  void initState() {
    super.initState();
    _loadMechanics();
  }

  Future<void> _loadMechanics() async {
    final mechanics = await MechanicService().getMechanics();
    if (mechanics != null) {
      setState(() {
        _state = _state.copyWith(mechanics: mechanics, isLoading: false);
      });
    } else {
      setState(() {
        _state = _state.copyWith(mechanics: [], isLoading: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBar hitam
        title: const Text(
          'Data Mekanik',
          style: TextStyle(color: Colors.amber), // Teks amber
        ),
        iconTheme: const IconThemeData(color: Colors.amber), // Icon amber
        elevation: 2,
      ),
      body: _state.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.amber, // Loader amber
              ),
            )
          : ListView.builder(
              itemCount: _state.mechanics.length,
              itemBuilder: (context, index) {
                final mechanic = _state.mechanics[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.amber.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Info mechanic
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mechanic.fullName ?? 'No Name',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Spesialisasi: ${mechanic.spesialisasi ?? '-'}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Status: ${mechanic.status ?? '-'}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Buttons edit & delete
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditMechanicPage(mechanic: mechanic),
                                  ),
                                )
                                    .then((value) {
                                  if (value == true) {
                                    _loadMechanics();
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    const Icon(Icons.edit, color: Colors.black87),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () async {
                                final mechanicId = _state.mechanics[index].id;
                                if (mechanicId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('ID mekanik tidak valid')),
                                  );
                                  return;
                                }
                                final success = await MechanicService()
                                    .deleteMechanic(mechanicId);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Data mekanik berhasil dihapus')),
                                  );
                                  await _loadMechanics();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Gagal menghapus data mekanik')),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.delete,
                                    color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber, // Amber background
        foregroundColor: Colors.black, // Icon hitam
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const MechanicFormPage(),
                ),
              )
              .then((value) {
            if (value == true) {
              _loadMechanics();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

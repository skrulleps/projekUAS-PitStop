import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pitstop/admin/data_master/mechanic/service/mechanic_service.dart';
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
      appBar: AppBar(
        title: const Text('Data Mekanik'),
      ),
      body: _state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _state.mechanics.length,
              itemBuilder: (context, index) {
                final mechanic = _state.mechanics[index];
                return ListTile(
                  title: Text(mechanic.fullName ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spesialisasi: ${mechanic.spesialisasi ?? '-'}'),
                      Text('Status: ${mechanic.status ?? '-'}'),
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
                                  EditMechanicPage(mechanic: mechanic),
                            ),
                          )
                              .then((value) {
                            if (value == true) {
                              _loadMechanics();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
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
                                  content:
                                      Text('Data mekanik berhasil dihapus')),
                            );
                            await _loadMechanics();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Gagal menghapus data mekanik')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Implement detail or edit mechanic
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
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
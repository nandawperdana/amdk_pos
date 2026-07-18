import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';

typedef Party = ({int id, String name});

/// Pick a customer ([isCustomer] true) or supplier, or add a new one inline.
/// Returns the chosen party, or null if cancelled.
Future<Party?> pickParty(BuildContext context, WidgetRef ref,
    {required bool isCustomer}) {
  return showModalBottomSheet<Party>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _PartyPicker(isCustomer: isCustomer),
    ),
  );
}

class _PartyPicker extends ConsumerStatefulWidget {
  final bool isCustomer;
  const _PartyPicker({required this.isCustomer});

  @override
  ConsumerState<_PartyPicker> createState() => _PartyPickerState();
}

class _PartyPickerState extends ConsumerState<_PartyPicker> {
  final _newName = TextEditingController();

  @override
  void dispose() {
    _newName.dispose();
    super.dispose();
  }

  Future<void> _addNew() async {
    final name = _newName.text.trim();
    if (name.isEmpty) return;
    final party = ref.read(partyServiceProvider);
    final id = widget.isCustomer
        ? await party.addCustomer(name)
        : await party.addSupplier(name);
    if (mounted) Navigator.pop<Party>(context, (id: id, name: name));
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.isCustomer ? 'Pelanggan' : 'Supplier';
    final AsyncValue<List<dynamic>> parties = widget.isCustomer
        ? ref.watch(customersProvider)
        : ref.watch(suppliersProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Pilih $label',
                style: Theme.of(context).textTheme.titleLarge),
          ),
          // Add new inline.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newName,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                        labelText: 'Tambah $label baru',
                        border: const OutlineInputBorder()),
                    onSubmitted: (_) => _addNew(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _addNew, child: const Text('Tambah')),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: parties.when(
              loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator()),
              error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Gagal memuat: $e')),
              data: (list) => list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Belum ada $label. Tambah di atas.'),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (final p in list)
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(p.name as String),
                            onTap: () => Navigator.pop<Party>(
                                context, (id: p.id as int, name: p.name as String)),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

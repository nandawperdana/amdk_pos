import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Owner-only screen: change the store name and the owner PIN. Both writes
/// are local (SharedPreferences) with no old-PIN verification required —
/// the owner has already passed the PIN gate to reach this screen.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final _nameCtrl =
      TextEditingController(text: ref.read(storeNameProvider));
  final _pinCtrl = TextEditingController();
  final _pinConfirmCtrl = TextEditingController();
  String? _nameError;
  String? _pinError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pinCtrl.dispose();
    _pinConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Nama toko tidak boleh kosong');
      return;
    }
    setState(() => _nameError = null);
    await ref.read(storeNameProvider.notifier).setName(name);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Nama toko disimpan')));
  }

  Future<void> _savePin() async {
    final pin = _pinCtrl.text;
    if (pin.length < 4) {
      setState(() => _pinError = 'PIN minimal 4 digit');
      return;
    }
    if (pin != _pinConfirmCtrl.text) {
      setState(() => _pinError = 'Konfirmasi PIN tidak sama');
      return;
    }
    setState(() => _pinError = null);
    await ref.read(pinServiceProvider).setPin(pin);
    _pinCtrl.clear();
    _pinConfirmCtrl.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('PIN baru disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Nama Toko', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nama toko',
              errorText: _nameError,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _saveName,
            child: const Text('SIMPAN NAMA TOKO'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text('Ubah PIN Owner',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _pinCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
                counterText: '', labelText: 'PIN baru'),
          ),
          TextField(
            controller: _pinConfirmCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
                counterText: '', labelText: 'Ulangi PIN baru'),
          ),
          if (_pinError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_pinError!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          FilledButton(
            onPressed: _savePin,
            child: const Text('SIMPAN PIN BARU'),
          ),
        ],
      ),
    );
  }
}

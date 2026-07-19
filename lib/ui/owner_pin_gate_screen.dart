import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Gate shown before the Owner screen: first time ever, set a PIN; every
/// entry after that, verify it. Kasir has no such gate.
class OwnerPinGateScreen extends ConsumerStatefulWidget {
  const OwnerPinGateScreen({super.key});

  @override
  ConsumerState<OwnerPinGateScreen> createState() =>
      _OwnerPinGateScreenState();
}

class _OwnerPinGateScreenState extends ConsumerState<OwnerPinGateScreen> {
  final _pinCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submitSetup() {
    final pin = _pinCtrl.text;
    if (pin.length < 4) {
      setState(() => _error = 'PIN minimal 4 digit');
      return;
    }
    if (pin != _confirmCtrl.text) {
      setState(() => _error = 'Konfirmasi PIN tidak sama');
      return;
    }
    ref.read(pinServiceProvider).setPin(pin);
    ref.read(ownerUnlockedProvider.notifier).state = true;
  }

  void _submitVerify() {
    if (ref.read(pinServiceProvider).verify(_pinCtrl.text)) {
      ref.read(ownerUnlockedProvider.notifier).state = true;
    } else {
      setState(() {
        _error = 'PIN salah';
        _pinCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSetup = !ref.watch(pinServiceProvider).isSet;
    return Scaffold(
      appBar: AppBar(
        title: Text(isSetup ? 'Buat PIN Owner' : 'Masuk Owner'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline,
                  size: 56, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                isSetup
                    ? 'Buat PIN untuk melindungi menu Owner (laporan & keuangan).'
                    : 'Masukkan PIN Owner.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinCtrl,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration:
                    const InputDecoration(counterText: '', labelText: 'PIN'),
              ),
              if (isSetup)
                TextField(
                  controller: _confirmCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: const InputDecoration(
                      counterText: '', labelText: 'Ulangi PIN'),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              const SizedBox(height: 16),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: isSetup ? _submitSetup : _submitVerify,
                  child: Text(isSetup ? 'SIMPAN PIN' : 'MASUK'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.read(roleProvider.notifier).select(null),
                child: const Text('Batal — kembali pilih peran'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

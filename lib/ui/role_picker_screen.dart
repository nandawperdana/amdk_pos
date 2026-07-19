import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class RolePickerScreen extends ConsumerWidget {
  const RolePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(ref.watch(storeNameProvider),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 32),
              SizedBox(
                height: 72,
                child: FilledButton.icon(
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('KASIR', style: TextStyle(fontSize: 22)),
                  onPressed: () =>
                      ref.read(roleProvider.notifier).select(AppRole.cashier),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 72,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('OWNER', style: TextStyle(fontSize: 22)),
                  onPressed: () =>
                      ref.read(roleProvider.notifier).select(AppRole.owner),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

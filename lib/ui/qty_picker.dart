import 'package:flutter/material.dart';

/// Ask for a quantity, in pcs or in a pack unit (dus/lusin/etc) if the
/// product has one. Returns the total in base units (pcs), or null if
/// cancelled. Used by both POS and kulakan — bottol/gelas sold per dus/pack.
Future<int?> pickQuantity(
  BuildContext context, {
  required String productName,
  String? packUnit,
  int packSize = 1,
  int initialQty = 1, // in base units (pcs)
}) {
  final hasPack = packUnit != null && packSize > 1;
  final pu = packUnit; // non-null when hasPack, captured for the closures below
  var unit = 'pcs';
  var amount = initialQty;
  if (hasPack && initialQty > 0 && initialQty % packSize == 0) {
    unit = pu!;
    amount = initialQty ~/ packSize;
  }
  final controller = TextEditingController(text: '$amount');

  return showDialog<int>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: Text('Jumlah — $productName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah'),
            ),
            if (hasPack) ...[
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: [
                  const ButtonSegment(value: 'pcs', label: Text('pcs')),
                  ButtonSegment(
                      value: pu!, label: Text('$pu ($packSize pcs)')),
                ],
                selected: {unit},
                onSelectionChanged: (s) => setLocal(() => unit = s.first),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(controller.text);
              if (n == null || n <= 0) return;
              Navigator.pop(ctx, unit == 'pcs' ? n : n * packSize);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    ),
  );
}

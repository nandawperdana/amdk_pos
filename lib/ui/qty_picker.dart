import 'package:flutter/material.dart';

/// Ask for a quantity, in pcs or in a pack unit (dus/lusin/etc) if the
/// product has one. Returns the total in base units (pcs) plus whether the
/// pack unit was chosen (so the caller can apply the pack price), or null if
/// cancelled. Used by both POS and kulakan — bottol/gelas sold per dus/pack.
///
/// [maxQty] caps the total (pcs) that can be confirmed — used at POS so a
/// sale can't exceed stock on hand; left null for kulakan, where there's no
/// ceiling (a purchase adds stock, it doesn't consume it).
Future<({int qtyBase, bool asPack})?> pickQuantity(
  BuildContext context, {
  required String productName,
  String? packUnit,
  int packSize = 1,
  int initialQty = 1, // in base units (pcs)
  int? maxQty,
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
  String? error; // hoisted outside the builder so setLocal() persists it

  return showDialog<({int qtyBase, bool asPack})>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) {
        return AlertDialog(
          title: Text('Jumlah — $productName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (maxQty != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Stok tersedia: $maxQty pcs',
                      style: Theme.of(ctx).textTheme.bodySmall),
                ),
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
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!,
                    style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
              ],
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                final n = int.tryParse(controller.text);
                if (n == null || n <= 0) {
                  setLocal(() => error = 'Jumlah tidak valid');
                  return;
                }
                final asPack = hasPack && unit != 'pcs';
                final total = asPack ? n * packSize : n;
                if (maxQty != null && total > maxQty) {
                  setLocal(() => error = 'Melebihi stok ($maxQty pcs)');
                  return;
                }
                Navigator.pop(ctx, (qtyBase: total, asPack: asPack));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ),
  );
}

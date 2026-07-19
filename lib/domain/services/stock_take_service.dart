import 'package:drift/drift.dart';

import '../../data/database/database.dart';

/// Stock take (opname): reconcile the physical count with the system balance.
/// Writes a DIFFERENCE row (append-only), NOT an overwrite — same pattern as
/// the cash-difference adjustment in CashierService.
class StockTakeService {
  final AppDatabase db;
  StockTakeService(this.db);

  /// Adjust a product's stock to the physical count. Writes one adjustment row
  /// of (physical − system). No-op if already equal.
  Future<void> adjustStock(int productId, int physical, {String? note}) async {
    final current = await db.stockOf(productId);
    final diff = physical - current;
    if (diff == 0) return;
    await db.into(db.stockMovements).insert(
          StockMovementsCompanion.insert(
            productId: productId,
            type: 'adjustment',
            qtyBase: diff,
            note: Value(note ?? 'Opname: fisik $physical (sistem $current)'),
          ),
        );
  }

  /// Adjust the gallon container balance (full/empty) to the physical count.
  /// One adjustment row with a per-column delta. No-op if both equal.
  Future<void> adjustGallon({
    required int full,
    required int empty,
    String? note,
  }) async {
    final b = await db.gallonBalance();
    final dFull = full - b.full;
    final dEmpty = empty - b.empty;
    if (dFull == 0 && dEmpty == 0) return;
    await db.into(db.gallonLedger).insert(
          GallonLedgerCompanion.insert(
            type: 'adjustment',
            dFull: Value(dFull),
            dEmpty: Value(dEmpty),
            note: Value(note ?? 'Opname galon (isi $full/kosong $empty)'),
          ),
        );
  }
}

import 'package:drift/drift.dart';

import '../../data/database/database.dart';

/// Penyesuaian stok (opname): cocokkan hitungan fisik dengan saldo sistem.
/// Menulis baris SELISIH (append-only), BUKAN overwrite — sama pola dengan
/// penyesuaian selisih kas di CashierService.
class OpnameService {
  final AppDatabase db;
  OpnameService(this.db);

  /// Sesuaikan stok sebuah produk ke hitungan fisik. Menulis 1 baris
  /// penyesuaian sebesar (fisik − sistem). No-op kalau sudah sama.
  Future<void> adjustStock(int productId, int physical, {String? note}) async {
    final current = await db.stockOf(productId);
    final diff = physical - current;
    if (diff == 0) return;
    await db.into(db.stockMovements).insert(
          StockMovementsCompanion.insert(
            productId: productId,
            type: 'penyesuaian',
            qtyBase: diff,
            note: Value(note ?? 'Opname: fisik $physical (sistem $current)'),
          ),
        );
  }

  /// Sesuaikan saldo wadah galon (isi/kosong/beredar) ke hitungan fisik.
  /// Satu baris penyesuaian dengan delta per kolom. No-op kalau semua sama.
  Future<void> adjustGalon({
    required int isi,
    required int kosong,
    required int beredar,
    String? note,
  }) async {
    final b = await db.galonBalance();
    final dFull = isi - b.full;
    final dEmpty = kosong - b.empty;
    final dDeposit = beredar - b.depositOut;
    if (dFull == 0 && dEmpty == 0 && dDeposit == 0) return;
    await db.into(db.galonLedger).insert(
          GalonLedgerCompanion.insert(
            type: 'penyesuaian',
            dFull: Value(dFull),
            dEmpty: Value(dEmpty),
            dDeposit: Value(dDeposit),
            note: Value(note ?? 'Opname galon (isi $isi/kosong $kosong/beredar $beredar)'),
          ),
        );
  }
}

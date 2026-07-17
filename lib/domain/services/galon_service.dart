import 'package:drift/drift.dart';

import '../../data/database/database.dart';

/// Menangani WADAH galon (bukan airnya).
/// Air/omzet tetap dicatat lewat SalesService/PurchaseService.
/// Di sini hanya pergerakan wadah + uang deposit.
class GalonService {
  final AppDatabase db;
  GalonService(this.db);

  /// Jual galon dengan TUKAR: pelanggan membawa galon kosong.
  /// Hanya air yang terjual. Wadah: isi -qty, kosong +qty. Deposit tetap.
  Future<void> recordExchange({
    required int qty,
    int? customerId,
    int? saleId,
  }) async {
    await db.into(db.galonLedger).insert(
          GalonLedgerCompanion.insert(
            type: 'jual_tukar',
            dFull: Value(-qty),
            dEmpty: Value(qty),
            customerId: Value(customerId),
            refType: const Value('sale'),
            refId: Value(saleId),
          ),
        );
  }

  /// Jual galon ke pelanggan BARU (beli air + wadah/deposit).
  /// Wadah: isi -qty, tidak ada kosong masuk, beredar +qty (KEWAJIBAN).
  /// Uang deposit masuk kas dengan kategori 'deposit_galon' (bukan omzet).
  Future<void> recordNewGalonSale({
    required int qty,
    required double depositPerGalon,
    int? customerId,
    int? saleId,
    String account = 'kas',
  }) async {
    await db.transaction(() async {
      await db.into(db.galonLedger).insert(
            GalonLedgerCompanion.insert(
              type: 'jual_baru',
              dFull: Value(-qty),
              dDeposit: Value(qty),
              customerId: Value(customerId),
              refType: const Value('sale'),
              refId: Value(saleId),
            ),
          );

      if (depositPerGalon > 0) {
        await db.into(db.cashEntries).insert(
              CashEntriesCompanion.insert(
                direction: 'masuk',
                amount: depositPerGalon * qty,
                category: 'deposit_galon',
                account: Value(account),
                refType: const Value('sale'),
                refId: Value(saleId),
                note: const Value('Titipan deposit galon (kewajiban)'),
              ),
            );
      }
    });
  }

  /// Pelanggan mengembalikan galon dan menarik deposit.
  /// Wadah: beredar -qty, kosong +qty. Kas KELUAR (refund).
  Future<void> recordDepositReturn({
    required int qty,
    required double depositPerGalon,
    int? customerId,
    String account = 'kas',
  }) async {
    await db.transaction(() async {
      await db.into(db.galonLedger).insert(
            GalonLedgerCompanion.insert(
              type: 'deposit_kembali',
              dEmpty: Value(qty),
              dDeposit: Value(-qty),
              customerId: Value(customerId),
            ),
          );

      if (depositPerGalon > 0) {
        await db.into(db.cashEntries).insert(
              CashEntriesCompanion.insert(
                direction: 'keluar',
                amount: depositPerGalon * qty,
                category: 'deposit_galon',
                account: Value(account),
                note: const Value('Refund deposit galon'),
              ),
            );
      }
    });
  }

  /// Kulakan galon isi dari agen dengan menukar galon kosong.
  /// Wadah: isi +qty, kosong -qty. Biaya air dicatat via PurchaseService.
  Future<void> recordRestockExchange({required int qty}) async {
    await db.into(db.galonLedger).insert(
          GalonLedgerCompanion.insert(
            type: 'kulakan',
            dFull: Value(qty),
            dEmpty: Value(-qty),
          ),
        );
  }
}

import 'package:drift/drift.dart';

import '../../data/database/database.dart';

/// How a gallon line is sold. Domain-level (mapped from the UI at the POS).
///   none        = not a gallon line
///   exchange    = customer brings an empty (container swap, no deposit)
///   newCustomer = new container leaves on deposit (liability)
enum GallonSaleMode { none, exchange, newCustomer }

/// Handles the gallon CONTAINER (not the water).
/// Water/revenue is still recorded via SalesService/PurchaseService.
/// Here we only move containers + deposit money.
class GallonService {
  final AppDatabase db;
  GallonService(this.db);

  /// Sell a gallon with an EXCHANGE: the customer brings back an empty.
  /// Only water is sold. Container: full -qty, empty +qty. Deposit unchanged.
  Future<void> recordExchange({
    required int qty,
    int? customerId,
    int? saleId,
  }) async {
    await db.into(db.gallonLedger).insert(
          GallonLedgerCompanion.insert(
            type: 'sale_exchange',
            dFull: Value(-qty),
            dEmpty: Value(qty),
            customerId: Value(customerId),
            refType: const Value('sale'),
            refId: Value(saleId),
          ),
        );
  }

  /// Sell a gallon to a NEW customer (buys water + container/deposit).
  /// Container: full -qty, no empty in, depositOut +qty (LIABILITY).
  /// Deposit money goes into cash with category 'gallon_deposit' (not revenue).
  Future<void> recordNewGallonSale({
    required int qty,
    required double depositPerGallon,
    int? customerId,
    int? saleId,
    String account = 'cash',
  }) async {
    await db.transaction(() async {
      await db.into(db.gallonLedger).insert(
            GallonLedgerCompanion.insert(
              type: 'sale_new',
              dFull: Value(-qty),
              dDeposit: Value(qty),
              customerId: Value(customerId),
              refType: const Value('sale'),
              refId: Value(saleId),
            ),
          );

      if (depositPerGallon > 0) {
        await db.into(db.cashEntries).insert(
              CashEntriesCompanion.insert(
                direction: 'in',
                amount: depositPerGallon * qty,
                category: 'gallon_deposit',
                account: Value(account),
                refType: const Value('sale'),
                refId: Value(saleId),
                note: const Value('Titipan deposit galon (kewajiban)'),
              ),
            );
      }
    });
  }

  /// Customer returns a gallon and withdraws the deposit.
  /// Container: depositOut -qty, empty +qty. Cash OUT (refund).
  Future<void> recordDepositReturn({
    required int qty,
    required double depositPerGallon,
    int? customerId,
    String account = 'cash',
  }) async {
    await db.transaction(() async {
      await db.into(db.gallonLedger).insert(
            GallonLedgerCompanion.insert(
              type: 'deposit_return',
              dEmpty: Value(qty),
              dDeposit: Value(-qty),
              customerId: Value(customerId),
            ),
          );

      if (depositPerGallon > 0) {
        await db.into(db.cashEntries).insert(
              CashEntriesCompanion.insert(
                direction: 'out',
                amount: depositPerGallon * qty,
                category: 'gallon_deposit',
                account: Value(account),
                note: const Value('Refund deposit galon'),
              ),
            );
      }
    });
  }

  /// Restock filled gallons from the agent by swapping empties.
  /// Container: full +qty, empty -qty. Water cost is recorded via
  /// PurchaseService.
  Future<void> recordRestockExchange({required int qty}) async {
    await db.into(db.gallonLedger).insert(
          GallonLedgerCompanion.insert(
            type: 'restock',
            dFull: Value(qty),
            dEmpty: Value(-qty),
          ),
        );
  }
}

import 'package:drift/drift.dart';

import '../../data/database/database.dart';

/// How a gallon line is sold. Domain-level (mapped from the UI at the POS).
///   none        = not a gallon line
///   exchange    = customer brings an empty back, buys water only (isi ulang)
///   newCustomer = customer buys a brand-new container + water, ONE price,
///                 no deposit — the container leaves the shop's fleet for good
enum GallonSaleMode { none, exchange, newCustomer }

/// Handles the gallon CONTAINER (not the water).
/// Water/revenue is still recorded via SalesService/PurchaseService.
/// Here we only move containers between full/empty.
class GallonService {
  final AppDatabase db;
  GallonService(this.db);

  /// Sell a gallon with an EXCHANGE: the customer brings back an empty.
  /// Only water is sold. Container: full -qty, empty +qty.
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

  /// Sell a brand-new container to a customer, one price (water + container),
  /// no deposit. The container leaves the fleet for good: full -qty only —
  /// it never comes back as empty or triggers a refund.
  Future<void> recordNewGallonSale({
    required int qty,
    int? customerId,
    int? saleId,
  }) async {
    await db.into(db.gallonLedger).insert(
          GallonLedgerCompanion.insert(
            type: 'sale_new',
            dFull: Value(-qty),
            customerId: Value(customerId),
            refType: const Value('sale'),
            refId: Value(saleId),
          ),
        );
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

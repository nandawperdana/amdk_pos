import 'package:drift/drift.dart';

import '../../data/database/database.dart';
import 'product_service.dart';

/// Bulk-import products from CSV text (header + rows), reusing
/// [ProductService.save] so new products go through the normal insert path.
/// Columns: name,brand,category,baseUnit,packUnit,packSize,buyPrice,
/// sellPrice,packBuyPrice,packSellPrice,isGallon,depositPrice,active
class ProductImportService {
  final AppDatabase db;
  final ProductService products;
  ProductImportService(this.db, this.products);

  // ponytail: hand-rolled quoted-field split, not full RFC4180 (no escaped
  // quotes) — enough for a plain product export. Swap to `csv` pkg if a
  // future export needs escaped quotes.
  static List<String> _splitCsvLine(String line) {
    final out = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        out.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    out.add(buf.toString());
    return out;
  }

  /// Returns (inserted, skipped names, error lines).
  Future<(int, List<String>, List<String>)> importCsv(String csvText) async {
    final lines =
        csvText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return (0, <String>[], <String>[]);
    final header = _splitCsvLine(lines.first);
    final existing =
        (await db.select(db.products).get()).map((p) => p.name).toSet();

    var inserted = 0;
    final skipped = <String>[];
    final errors = <String>[];
    for (final line in lines.skip(1)) {
      final row = _splitCsvLine(line);
      final v = Map.fromIterables(header, row);
      final name = v['name'];
      if (name == null || name.trim().isEmpty) continue;
      if (existing.contains(name)) {
        skipped.add(name);
        continue;
      }
      try {
        await products.save(ProductsCompanion.insert(
          name: name,
          brand: Value(v['brand'] ?? ''),
          category: Value(v['category'] ?? 'other'),
          baseUnit: Value(v['baseUnit'] ?? 'pcs'),
          packUnit: Value((v['packUnit'] ?? '').isEmpty ? null : v['packUnit']),
          packSize: Value(int.parse(v['packSize'] ?? '1')),
          buyPrice: Value(double.parse(v['buyPrice']!)),
          sellPrice: Value(double.parse(v['sellPrice']!)),
          packBuyPrice: Value(double.parse(v['packBuyPrice'] ?? '0')),
          packSellPrice: Value(double.parse(v['packSellPrice'] ?? '0')),
          isGallon: Value(v['isGallon'] == 'true'),
          depositPrice: Value(double.parse(v['depositPrice'] ?? '0')),
          active: Value(v['active'] != 'false'),
        ));
        existing.add(name);
        inserted++;
      } catch (e) {
        errors.add('$name: $e');
      }
    }
    return (inserted, skipped, errors);
  }
}

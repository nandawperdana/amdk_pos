// Import master products from a CSV file straight into a local sqlite DB
// file — useful for adb pull/push against a device's DB. The in-app
// "Import CSV" button in Master Produk (owner) covers the normal path;
// this script is for when the app itself isn't reachable.
// Usage: IMPORT_CSV=<csv_path> IMPORT_DB=<db_path> fvm flutter test bin/import_products.dart
import 'dart:io';

import 'package:amdk_pos/data/database/database.dart';
import 'package:amdk_pos/domain/services/product_import_service.dart';
import 'package:amdk_pos/domain/services/product_service.dart';
import 'package:drift/native.dart';

void main() async {
  // flutter test's runner calls main() with no args, so config comes from
  // env vars instead of argv.
  final csvPath = Platform.environment['IMPORT_CSV'];
  final dbPath = Platform.environment['IMPORT_DB'];
  if (csvPath == null || dbPath == null) {
    stderr.writeln('Usage: IMPORT_CSV=<csv_path> IMPORT_DB=<db_path> '
        'fvm flutter test bin/import_products.dart');
    exit(1);
  }

  final db = AppDatabase(NativeDatabase(File(dbPath)));
  final importer = ProductImportService(db, ProductService(db));
  final (inserted, skipped, errors) =
      await importer.importCsv(File(csvPath).readAsStringSync());
  await db.close();

  stdout.writeln('done: $inserted inserted, ${skipped.length} skipped'
      '${skipped.isEmpty ? '' : ' (${skipped.join(', ')})'}');
  if (errors.isNotEmpty) {
    stderr.writeln('errors:\n${errors.join('\n')}');
  }
}

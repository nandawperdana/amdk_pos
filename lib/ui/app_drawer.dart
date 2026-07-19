import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import 'cashier_closing_screen.dart';
import 'credit_screen.dart';
import 'daily_report_screen.dart';
import 'master_product_screen.dart';
import 'purchase_screen.dart';
import 'settings_screen.dart';
import 'stock_take_screen.dart';

/// Shared nav drawer for both roles — keeps the AppBar to title + live-status
/// actions (sync/refresh) only, navigation destinations live here instead.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(roleProvider);
    final isOwner = role == AppRole.owner;
    final storeName = ref.watch(storeNameProvider);

    void go(Widget screen) {
      Navigator.pop(context); // close the drawer first
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(storeName,
                          style: Theme.of(context).textTheme.titleLarge),
                      if (!isProdEnv) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            appEnv.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(isOwner ? 'Owner' : 'Kasir',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  if (isOwner) ...[
                    ListTile(
                      leading: const Icon(Icons.event_note),
                      title: const Text('Laporan'),
                      onTap: () => go(const DailyReportScreen()),
                    ),
                    ListTile(
                      leading: const Icon(Icons.add_shopping_cart_outlined),
                      title: const Text('Kulakan'),
                      onTap: () => go(const PurchaseScreen()),
                    ),
                  ] else ...[
                    ListTile(
                      leading: const Icon(Icons.point_of_sale_outlined),
                      title: const Text('Tutup Kasir'),
                      onTap: () => go(const CashierClosingScreen()),
                    ),
                    ListTile(
                      leading: const Icon(Icons.fact_check_outlined),
                      title: const Text('Opname Stok'),
                      onTap: () => go(const StockTakeScreen()),
                    ),
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet_outlined),
                      title: const Text('Piutang & Utang'),
                      onTap: () => go(const CreditScreen()),
                    ),
                  ],
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: const Text('Master Produk'),
                    onTap: () => go(const MasterProductScreen()),
                  ),
                  if (isOwner)
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Pengaturan'),
                      onTap: () => go(const SettingsScreen()),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.switch_account),
              title: const Text('Ganti Peran'),
              onTap: () {
                Navigator.pop(context);
                ref.read(ownerUnlockedProvider.notifier).state = false;
                ref.read(roleProvider.notifier).select(null);
              },
            ),
          ],
        ),
      ),
    );
  }
}

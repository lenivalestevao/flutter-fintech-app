import 'package:flutter/material.dart';

import 'core/scope.dart';
import 'core/theme.dart';
import 'data/wallet_store.dart';
import 'features/shell.dart';

void main() => runApp(NovaApp(store: WalletStore()));

class NovaApp extends StatelessWidget {
  const NovaApp({super.key, required this.store});

  final WalletStore store;

  @override
  Widget build(BuildContext context) {
    return Scope<WalletStore>(
      store: store,
      child: MaterialApp(
        title: 'Nova',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const AppShell(),
      ),
    );
  }
}

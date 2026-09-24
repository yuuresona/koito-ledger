import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../core/database/app_database.dart';
import '../features/categories/application/category_application_service.dart';
import '../features/categories/data/category_repository.dart';
import '../l10n/app_localizations.dart';
import 'app_shell.dart';
import 'theme/ledger_theme.dart';

class LedgerApp extends StatefulWidget {
  const LedgerApp({super.key, this.database});

  final AppDatabase? database;

  @override
  State<LedgerApp> createState() => _LedgerAppState();
}

class _LedgerAppState extends State<LedgerApp> {
  late AppDatabase _database;
  late bool _ownsDatabase;
  late Future<void> _openDatabase;

  @override
  void initState() {
    super.initState();
    _ownsDatabase = widget.database == null;
    _database = widget.database ?? AppDatabase();
    _openDatabase = _verifyDatabase();
  }

  @override
  void dispose() {
    if (_ownsDatabase) {
      unawaited(_database.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: LedgerTheme.light(lightDynamic),
        darkTheme: LedgerTheme.dark(darkDynamic),
        themeMode: ThemeMode.system,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FutureBuilder<void>(
          future: _openDatabase,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return _DatabaseError(onRetry: _retryDatabase);
            }
            final repository = CategoryRepository(_database);
            return AppShell(
              categoryRepository: repository,
              categoryService: CategoryApplicationService(_database),
            );
          },
        ),
      ),
    );
  }

  Future<void> _verifyDatabase() async {
    await _database.customSelect('SELECT 1').getSingle();
  }

  Future<void> _retryDatabase() async {
    if (_ownsDatabase) {
      await _database.close();
      _database = AppDatabase();
    }
    setState(() => _openDatabase = _verifyDatabase());
  }
}

class _DatabaseError extends StatelessWidget {
  const _DatabaseError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storage_outlined, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.databaseOpenError,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(l10n.databaseOpenErrorHint, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

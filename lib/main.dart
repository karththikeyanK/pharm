import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharm/db/db_helper.dart';
import 'package:pharm/provider/router_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async{
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await DatabaseHelper.instance.database;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // precacheImage(const AssetImage('assets/logo.png'), context);

    return MaterialApp.router(
      title: 'Pharm',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
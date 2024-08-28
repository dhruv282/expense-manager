import 'package:expense_manager/database_manager/database_manager.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import 'bottom_navbar.dart';

void main() {
  var dbManager = DatabaseManager();
  dbManager.connect("localhost", "test_db", "postgres", "postgres",
      const ConnectionSettings(sslMode: SslMode.disable));
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BottomNavBar(),
    );
  }
}

import 'package:expense_manager/components/navbar/bottom_navbar.dart';
import 'package:expense_manager/utils/database_manager/database_manager.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:provider/provider.dart';

void main() async {
  var dbManager = DatabaseManager();
  await dbManager.connect("localhost", "test_db", "postgres", "postgres",
      const ConnectionSettings(sslMode: SslMode.disable));
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => ExpenseProvider()..loadExpenseData())
        ],
        child: MaterialApp(
          title: 'Expense Manager',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const BottomNavBar(),
        ));
  }
}

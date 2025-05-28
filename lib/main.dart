import 'package:expense_manager/components/home/home.dart';
import 'package:expense_manager/providers/dashboard_widgets_provider.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    generateTheme(Brightness b) => ThemeData(
          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: Colors.transparent),
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.cyan, brightness: b),
          useMaterial3: true,
        );
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
          ChangeNotifierProvider(create: (_) => DashboardWidgetsProvider()),
        ],
        child: MaterialApp(
          title: 'Expense Manager',
          theme: generateTheme(Brightness.light),
          darkTheme: generateTheme(Brightness.dark),
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: const Home(),
        ));
  }
}

import 'package:expense_manager/components/home/home.dart';
import 'package:expense_manager/providers/auth_provider.dart';
import 'package:expense_manager/providers/dashboard_widgets_provider.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/providers/theme_provider.dart';
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
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ChangeNotifierProvider(create: (_) => DashboardWidgetsProvider()),
    ], child: MaterialAppWidget());
  }
}

class MaterialAppWidget extends StatelessWidget {
  const MaterialAppWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    generateTheme(Brightness b) => ThemeData(
          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: Colors.transparent),
          colorScheme: ColorScheme.fromSeed(
              seedColor: themeProvider.themeColor, brightness: b),
          useMaterial3: true,
        );
    return MaterialApp(
      title: 'Expense Manager',
      theme: generateTheme(Brightness.light),
      darkTheme: generateTheme(Brightness.dark),
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: authProvider.isAuthenticated
          ? Home()
          : Center(child: CircularProgressIndicator()),
    );
  }
}

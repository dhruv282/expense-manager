import 'package:expense_manager/components/navbar/bottom_navbar.dart';
import 'package:expense_manager/components/settings/database_config_form/database_config_form.dart';
import 'package:expense_manager/components/year_selector/year_selector.dart';
import 'package:expense_manager/pages/add_expense.dart';
import 'package:expense_manager/pages/settings.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/database_config_store/database_config_store.dart';
import 'package:expense_manager/utils/database_manager/database_manager.dart';
import 'package:expense_manager/utils/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = true;

  Future<bool> _isDBConfigComplete() {
    var dbConfigStore = DatabaseConfigStore();
    return dbConfigStore.isConfigComplete();
  }

  Future<bool> _initDBConnection() async {
    var dbManager = DatabaseManager();
    var dbConfigStore = DatabaseConfigStore();
    var config = await dbConfigStore.getDatabaseConfig();
    var result =
        await dbManager.connect(config.endpoint, config.connectionSettings);
    return result != null;
  }

  Future<void> _initializeExpenseProvider(BuildContext context) async {
    await _initDBConnection().then((res) async {
      if (res) {
        if (!context.mounted) return;
        return await Provider.of<ExpenseProvider>(context, listen: false)
            .initialize();
      }
      throw Exception('Failed to initialize database connection');
    }).catchError((error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackBar(
          context,
          'Failed to load expense data',
          SnackBarColor.error,
        );
      });
    });
  }

  void navigateToSettingsPage() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
    checkDBConfigFlow();
  }

  void navigateToDatabaseConfigPage() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const DatabaseConfigForm()));
    checkDBConfigFlow();
  }

  void checkDBConfigFlow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isDBConfigComplete().then((val) {
        if (val) {
          _initializeExpenseProvider(context).whenComplete(() {
            setState(() {
              _isLoading = false;
            });
          });
        } else {
          navigateToDatabaseConfigPage();
          showSnackBar(
            context,
            'Missing DB Config',
            SnackBarColor.error,
          );
        }
      }).catchError((error) {
        navigateToDatabaseConfigPage();
        showSnackBar(
          context,
          'Failed to fetch DB Config',
          SnackBarColor.error,
        );
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    checkDBConfigFlow();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
      appBar: _isLoading
          ? null
          : AppBar(
              leading: IconButton.filledTonal(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Expense',
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddExpensePage()));
                  }),
              title: const YearSelector(),
              centerTitle: true,
              scrolledUnderElevation: 0.0,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  tooltip: 'Refresh Data',
                  onPressed: expenseProvider.initialize,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                    tooltip: 'Database Settings',
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      navigateToSettingsPage();
                    },
                    icon: const Icon(Icons.settings)),
              ],
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : expenseProvider.expenses.isNotEmpty
              ? const BottomNavBar()
              : Center(
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          border: Border.all(
                              width: 2.0,
                              color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Text('No data'))),
    );
  }
}

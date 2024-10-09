import 'package:expense_manager/components/navbar/bottom_navbar.dart';
import 'package:expense_manager/pages/settings.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/database_config_store/database_config_store.dart';
import 'package:expense_manager/utils/database_manager/database_manager.dart';
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
        return await Provider.of<ExpenseProvider>(context, listen: false)
            .initialize();
      }
      throw Exception('Failed to initialize database connection');
    }).catchError((error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load expense data'),
            backgroundColor: Color.fromARGB(255, 95, 0, 0),
          ),
        );
      });
    });
  }

  void navigateToSettingsPage() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
    checkDBConfigFlow();
  }

  void checkDBConfigFlow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isDBConfigComplete().then((val) {
        if (val) {
          _initializeExpenseProvider(context);
        } else {
          navigateToSettingsPage();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Missing DB Config'),
              backgroundColor: Color.fromARGB(255, 95, 0, 0),
            ),
          );
        }
      }).catchError((error) {
        navigateToSettingsPage();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch DB Config'),
            backgroundColor: Color.fromARGB(255, 95, 0, 0),
          ),
        );
      }).whenComplete(() {
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: navigateToSettingsPage,
              icon: const Icon(Icons.settings))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : const BottomNavBar(),
    );
  }
}

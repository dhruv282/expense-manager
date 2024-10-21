import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/utils/database_manager/database_manager.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:flutter/material.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseData> _expenses = [];
  List<String> _ownerOptions = [];
  List<String> _categoryOptions = [];

  List<ExpenseData> get expenses => _expenses;
  List<String> get ownerOptions => _ownerOptions;
  List<String> get categoryOptions => _categoryOptions;

  Future initialize() async {
    return loadExpenseData()
        .then((res) => loadOwnerOptions())
        .then((res) => loadCategoryOptions())
        .catchError((e) => logger.e(e))
        .whenComplete(() => notifyListeners());
  }

  Future loadExpenseData() async {
    var dbManager = DatabaseManager();
    return dbManager.getAllExpenses().then((entries) {
      _expenses = entries;
    });
  }

  Future loadOwnerOptions() async {
    var dbManager = DatabaseManager();
    return dbManager.getOwners().then((options) {
      _ownerOptions = options;
    });
  }

  Future loadCategoryOptions() async {
    var dbManager = DatabaseManager();
    return dbManager.getCategories().then((options) {
      _categoryOptions = options;
    });
  }

  Future updateExpense(ExpenseData e) {
    if (!_ownerOptions.contains(e.person)) {
      return Future.error('Invalid value for person in expense: ${e.person}');
    }

    if (!_categoryOptions.contains(e.category)) {
      return Future.error(
          'Invalid value for category in expense: ${e.category}');
    }

    var dbManager = DatabaseManager();
    return dbManager.updateExpense(e).then((_) {
      var updated = false;
      for (var i = 0; i < _expenses.length; i++) {
        if (_expenses[i].id == e.id) {
          _expenses[i] = e.copy();
          updated = true;
          break;
        }
      }
      if (!updated) {
        throw Exception('Unable to find expense with ID: ${e.id}');
      }
    }).whenComplete(() => notifyListeners());
  }

  Future addExpense(ExpenseData e) {
    if (!_ownerOptions.contains(e.person)) {
      return Future.error('Invalid value for person in expense: ${e.person}');
    }

    if (!_categoryOptions.contains(e.category)) {
      return Future.error(
          'Invalid value for category in expense: ${e.category}');
    }

    var dbManager = DatabaseManager();
    return dbManager.insertExpense(e).then((id) {
      // Populate the ID value of the object.
      e.id = id;
      _expenses.add(e);
    }).whenComplete(() => notifyListeners());
  }

  Future deleteExpense(ExpenseData e) {
    var dbManager = DatabaseManager();
    return dbManager.deleteExpense(e.id).then((_) {
      _expenses.removeWhere((expense) => expense.id == e.id);
    }).whenComplete(() => notifyListeners());
  }

  void sort<T>(
    Comparable<T> Function(ExpenseData d) getField,
    bool ascending,
  ) {
    expenses.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  Future addOwner(String owner) {
    var dbManager = DatabaseManager();
    return dbManager.addOwner(owner).then((res) {
      _ownerOptions.add(owner);
    }).whenComplete(() => notifyListeners());
  }

  Future addCategory(String category) {
    var dbManager = DatabaseManager();
    return dbManager.addCategory(category).then((res) {
      _categoryOptions.add(category);
    }).whenComplete(() => notifyListeners());
  }
}

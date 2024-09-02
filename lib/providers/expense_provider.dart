import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/database_manager/database_manager.dart';
import 'package:flutter/material.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseData> _expenses = [];

  List<ExpenseData> get expenses => _expenses;

  Future loadExpenseData() async {
    var dbManager = DatabaseManager();
    return dbManager.executeFetchAll().then((entries) {
      if (entries != null) {
        _expenses = entries;
      }
    }).whenComplete(() {
      notifyListeners();
    });
  }

  Future updateExpense(ExpenseData e) {
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
    var dbManager = DatabaseManager();
    return dbManager.executeInsert(e).then((_) {
      _expenses.add(e);
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
}

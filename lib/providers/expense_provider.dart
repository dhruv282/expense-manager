import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/data/recurring_schedule.dart';
import 'package:expense_manager/utils/database_manager/database_manager.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:flutter/material.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseData> _expenses = [];
  List<String> _categoryOptions = [];
  List<int> _yearOptions = [];
  int? _selectedYear;
  List<RecurringSchedule> _recurringSchedules = [];

  List<ExpenseData> get expenses => _expenses;
  List<String> get categoryOptions => _categoryOptions;
  List<int> get yearOptions => _yearOptions;
  int? get selectedYear => _selectedYear;
  List<RecurringSchedule> get recurringSchedules => _recurringSchedules;

  Future initialize() async {
    return loadYearOptions()
        .then((res) => loadCategoryOptions())
        .then((res) => loadExpenseData(autoLoadLatestYear: true))
        .then((res) => loadRecurringSchedules())
        .catchError((e) => logger.e(e))
        .whenComplete(() => notifyListeners());
  }

  Future loadExpenseData({int? year, bool autoLoadLatestYear = false}) async {
    var dbManager = DatabaseManager();
    _selectedYear = year;
    if (autoLoadLatestYear && _selectedYear == null && yearOptions.isNotEmpty) {
      _selectedYear = yearOptions.first;
    }
    return dbManager.getExpenses(year: _selectedYear).then((entries) {
      _expenses = entries;
    }).whenComplete(() => notifyListeners());
  }

  Future loadCategoryOptions() async {
    var dbManager = DatabaseManager();
    return dbManager.getCategories().then((options) {
      _categoryOptions = options;
    });
  }

  Future loadYearOptions() async {
    var dbManager = DatabaseManager();
    return dbManager.getYears().then((options) {
      _yearOptions = options;
    });
  }

  Future updateExpense(ExpenseData e) {
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

  Future addCategory(String category) {
    var dbManager = DatabaseManager();
    return dbManager.addCategory(category).then((res) {
      _categoryOptions.add(category);
    }).whenComplete(() => notifyListeners());
  }

  Future loadRecurringSchedules() async {
    var dbManager = DatabaseManager();
    return dbManager.getRecurringSchedules().then((recurring) {
      _recurringSchedules = recurring;
    }).whenComplete(() => notifyListeners());
  }

  Future addRecurringSchedule(RecurringSchedule e) {
    var dbManager = DatabaseManager();
    return dbManager.insertRecurringSchedule(e).then((id) {
      // Populate the ID value of the object.
      e.id = id;
      _recurringSchedules.add(e);
    }).whenComplete(() => notifyListeners());
  }

  Future updateRecurringSchedule(RecurringSchedule e) {
    var dbManager = DatabaseManager();
    return dbManager.updateRecurringSchedule(e).then((_) {
      var updated = false;
      for (var i = 0; i < _recurringSchedules.length; i++) {
        if (_recurringSchedules[i].id == e.id) {
          _recurringSchedules[i] = e.copy();
          updated = true;
          break;
        }
      }
      if (!updated) {
        throw Exception('Unable to find recurring schedule with ID: ${e.id}');
      }
    }).whenComplete(() => notifyListeners());
  }

  Future triggerRecurringScheduleRule(RecurringSchedule e) {
    var updated = e.copy();
    updated.lastExecuted = DateTime.now();
    return updateRecurringSchedule(e);
  }

  Future deleteRecurringSchedule(RecurringSchedule e) {
    var dbManager = DatabaseManager();
    return dbManager.deleteRecurringSchedule(e.id).then((_) {
      _recurringSchedules.removeWhere((expense) => expense.id == e.id);
    }).whenComplete(() => notifyListeners());
  }
}

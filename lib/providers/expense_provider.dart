import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/data/recurring_schedule.dart';
import 'package:expense_manager/utils/database_manager/database_manager.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:rrule/rrule.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseData> _expenses = [];
  List<String> _categoryOptions = [];
  List<int> _yearOptions = [];
  int? _selectedYear;
  List<RecurringSchedule> _recurringSchedules = [];
  Map<RecurringSchedule, List<ExpenseData>> _pendingTransactions = {};

  List<ExpenseData> get expenses => _expenses;
  List<String> get categoryOptions => _categoryOptions;
  List<int> get yearOptions => _yearOptions;
  int? get selectedYear => _selectedYear;
  List<RecurringSchedule> get recurringSchedules => _recurringSchedules;
  Map<RecurringSchedule, List<ExpenseData>> get pendingTransactions =>
      _pendingTransactions;

  late RruleL10n _l10n;

  Future initialize() async {
    RruleL10nEn.create().then((l10n) => _l10n = l10n);
    return loadYearOptions()
        .then((res) => loadCategoryOptions())
        .then((res) => loadExpenseData(autoLoadLatestYear: true))
        .then((res) => loadRecurringSchedules())
        .then((res) => loadPendingTransactions())
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

  bool isIncome(String category) {
    return category.toUpperCase() == 'INCOME';
  }

  Future loadRecurringSchedules() async {
    var dbManager = DatabaseManager();
    return dbManager.getRecurringSchedules().then((recurring) {
      _recurringSchedules = recurring;
    }).whenComplete(() => notifyListeners());
  }

  Future loadPendingTransactions() async {
    Map<RecurringSchedule, List<ExpenseData>> temp = {};
    for (var s in _recurringSchedules) {
      var recurringEntries = getRecurringEntries(s);
      if (recurringEntries.isNotEmpty) {
        temp[s] = getRecurringEntries(s);
      }
    }
    _pendingTransactions = temp;
    return Future.value().whenComplete(() => notifyListeners());
  }

  Future addRecurringSchedule(RecurringSchedule e) {
    var dbManager = DatabaseManager();
    return dbManager
        .insertRecurringSchedule(e)
        .then((id) {
          // Populate the ID value of the object.
          e.id = id;
          _recurringSchedules.add(e);
        })
        .then((_) => loadPendingTransactions())
        .whenComplete(() => notifyListeners());
  }

  Future updateRecurringSchedule(RecurringSchedule s) {
    var dbManager = DatabaseManager();
    return dbManager
        .updateRecurringSchedule(s)
        .then((_) {
          var updated = false;
          for (var i = 0; i < _recurringSchedules.length; i++) {
            if (_recurringSchedules[i].id == s.id) {
              _recurringSchedules[i] = s.copy();
              updated = true;
              break;
            }
          }
          if (!updated) {
            throw Exception(
                'Unable to find recurring schedule with ID: ${s.id}');
          }
        })
        .then((_) => loadPendingTransactions())
        .whenComplete(() => notifyListeners());
  }

  Future triggerRecurringScheduleRule(
      RecurringSchedule s, ExpenseData e, bool skip) async {
    var updated = s.copy();
    updated.lastExecuted = e.date;
    if (!skip) {
      await addExpense(e);
    }
    return updateRecurringSchedule(updated)
        .then((_) => loadPendingTransactions())
        .whenComplete(() => notifyListeners());
  }

  Future deleteRecurringSchedule(RecurringSchedule e) {
    var dbManager = DatabaseManager();
    return dbManager.deleteRecurringSchedule(e.id).then((_) {
      _recurringSchedules.removeWhere((expense) => expense.id == e.id);
    }).whenComplete(() => notifyListeners());
  }

  String recurrenceRuleToText(String rule) {
    return RecurrenceRule.fromString(rule).toText(l10n: _l10n);
  }

  String recurrenceJsonToText(Map<String, dynamic> rule) {
    return RecurrenceRule.fromJson(rule).toText(l10n: _l10n);
  }

  List<ExpenseData> getRecurringEntries(RecurringSchedule schedule) {
    final recurrenceRule = RecurrenceRule.fromString(schedule.recurrenceRule);
    return recurrenceRule
        .getInstances(
          start: schedule.lastExecuted.toUtc(),
          before: DateTime.now().toUtc(),
          includeBefore: true,
          after: schedule.lastExecuted.toUtc(),
          includeAfter: false,
        )
        .map((d) => ExpenseData(
            date: d,
            description: schedule.description,
            cost: schedule.cost,
            category: schedule.category))
        .toList();
  }
}

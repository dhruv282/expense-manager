import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/data/recurring_schedule.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';

/// The `DatabaseManager` class is responsible for managing the connection and operations
/// with the database. It provides methods to establish a connection, execute queries,
/// and perform other database-related tasks.
class DatabaseManager {
  static Connection? connection;

  /// Connects to the database.
  Future<Result?> connect(
      Endpoint endpoint, ConnectionSettings? connectionSettings) async {
    logger.i("Connecting to the database...");

    try {
      connection = await Connection.open(
        endpoint,
        // The postgres server hosted locally doesn't have SSL by default. If you're
        // accessing a postgres server over the Internet, the server should support
        // SSL and you should swap out the mode with `SslMode.verifyFull`.
        settings: connectionSettings,
      );

      return await connection!
          .execute('''
            DO \$\$ BEGIN
              CREATE TYPE CATEGORY_OPTIONS AS ENUM();
            EXCEPTION
              WHEN duplicate_object THEN null;
            END \$\$;
          ''')
          .then((value) =>
              connection!.execute('CREATE TABLE IF NOT EXISTS expenses ('
                  '  id UUID DEFAULT gen_random_uuid() PRIMARY KEY, '
                  '  cost DECIMAL(12,2) NOT NULL,'
                  '  description TEXT NOT NULL,'
                  '  date DATE NOT NULL,'
                  '  category CATEGORY_OPTIONS'
                  ')'))
          .then((value) => connection!
              .execute('CREATE TABLE IF NOT EXISTS recurring_expenses ('
                  '  id UUID DEFAULT gen_random_uuid() PRIMARY KEY, '
                  '  description TEXT NOT NULL,'
                  '  cost DECIMAL(12,2) NOT NULL,'
                  '  category CATEGORY_OPTIONS NOT NULL,'
                  '  auto_confirm BOOLEAN NOT NULL DEFAULT FALSE,'
                  '  recurrence_rule TEXT NOT NULL,'
                  '  last_executed DATE NOT NULL'
                  ')'));
    } catch (e) {
      logger.e("Error connecting to the database: $e");
    }

    return null;
  }

  /// Returns all expenses from the database.
  Future<List<ExpenseData>> getExpenses({int? year}) async {
    // Execute the query
    logger.i("Fetching ${year ?? 'all'} expenses from the database...");

    if (connection == null) {
      return Future.error('No connection to Database');
    }

    List<ExpenseData> expenses = [];

    // Execute the query
    final results = await connection!.execute(
      year == null
          ? Sql.named('SELECT * FROM expenses ORDER BY date DESC')
          : Sql.named(
              'SELECT * FROM expenses  WHERE DATE_PART(\'YEAR\', date)=$year ORDER BY date DESC'),
    );

    for (var result in results) {
      expenses.add(ExpenseData.fromMap(result.toColumnMap()));
    }

    return expenses;
  }

  /// Inserts the given expense in the database and returns the ID.
  Future<String> insertExpense(ExpenseData expense) async {
    logger.i("Inserting an expense into the database...");

    if (connection == null) {
      return Future.error('No connection to Database');
    }

    // Execute the query
    final res = await connection!.execute(
        r'INSERT INTO expenses (cost, description, date, category) VALUES ($1, $2, $3, $4) RETURNING id',
        parameters: [
          expense.cost,
          expense.description,
          DateFormat('MM/dd/yyyy').format(expense.date),
          expense.category,
        ]);
    if (res.isEmpty) {
      throw Exception('Error inserting expense: $expense');
    }
    return res[0][0].toString();
  }

  /// Updates values of the given expense in the database.
  Future<Result?> updateExpense(ExpenseData expense) async {
    logger.i("Updating expense ${expense.id}");

    if (connection == null) {
      return Future.error('No connection to Database');
    }

    return await connection!.execute(
        Sql.named(
            'UPDATE expenses SET cost=@cost, description=@description, date=@date, category=@category WHERE id=@id'),
        parameters: {
          'id': expense.id,
          'description': expense.description,
          'date': DateFormat('MM/dd/yyyy').format(expense.date),
          'category': expense.category,
          'cost': expense.cost,
        });
  }

  /// Deletes the given expense id from the database.
  Future<Result?> deleteExpense(String id) async {
    logger.i("Deleting expense $id");

    if (connection == null) {
      return Future.error('No connection to Database');
    }

    return await connection!
        .execute(Sql.named('DELETE FROM expenses WHERE id=@id'), parameters: {
      'id': id,
    });
  }

  /// Get CATEGORY_OPTIONS values from the database.
  Future<List<String>> getCategories() async {
    logger.i("Getting category options");

    if (connection == null) {
      return Future.error("No connection to Database");
    }

    List<String> categories = [];

    // Execute the query
    final results = await connection!.execute(
      Sql.named('SELECT unnest(enum_range(NULL::CATEGORY_OPTIONS))'),
    );

    for (var result in results) {
      categories.add(result.toColumnMap()["unnest"].asString);
    }

    return categories;
  }

  /// Appends to CATEGORY_OPTIONS enum in the database.
  Future<Result?> addCategory(String category) async {
    logger.i("Adding category option $category");

    if (connection == null) {
      return Future.error("No connection to Database");
    }

    return await connection!
        .execute("ALTER TYPE CATEGORY_OPTIONS ADD VALUE '$category'");
  }

  /// Gets list of years from transaction data.
  Future<List<int>> getYears() async {
    logger.i("Getting years");

    if (connection == null) {
      return Future.error("No connection to Database");
    }

    List<int> years = [];

    // Execute the query
    final results = await connection!.execute(
      Sql.named(
          'SELECT * FROM (SELECT DISTINCT EXTRACT(YEAR FROM date) from expenses) results ORDER BY results DESC;'),
    );

    for (var result in results) {
      years.add(int.parse(result[0] as String));
    }

    return years;
  }

  /// Gets all recurring schedules from the database.
  Future<List<RecurringSchedule>> getRecurringSchedules() async {
    logger.i("Getting recurring schedules");

    if (connection == null) {
      return Future.error("No connection to Database");
    }

    List<RecurringSchedule> expenses = [];

    // Execute the query
    final results = await connection!.execute(
      Sql.named('SELECT * FROM recurring_expenses'),
    );

    for (var result in results) {
      expenses.add(RecurringSchedule.fromMap(result.toColumnMap()));
    }

    return expenses;
  }

  /// Inserts the given recurring schedule in the database and returns the ID.
  Future<String> insertRecurringSchedule(RecurringSchedule schedule) async {
    logger.i("Inserting a recurring schedule into the database...");

    if (connection == null) {
      return Future.error('No connection to Database');
    }

    // Execute the query
    final res = await connection!.execute(
        r'INSERT INTO recurring_expenses (description, cost, category, auto_confirm, recurrence_rule, last_executed) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id',
        parameters: [
          schedule.description,
          schedule.cost,
          schedule.category,
          schedule.autoConfirm,
          schedule.recurrenceRule,
          DateFormat('MM/dd/yyyy').format(schedule.lastExecuted),
        ]);
    if (res.isEmpty) {
      throw Exception('Error inserting recurring schedule: $schedule');
    }
    return res[0][0].toString();
  }

  /// Updates values of the given recurring schedule in the database.
  Future<Result?> updateRecurringSchedule(RecurringSchedule expense) async {
    logger.i("Updating recurring schedule ${expense.id}");

    if (connection == null) {
      return Future.error('No connection to Database');
    }

    return await connection!.execute(
        Sql.named(
            'UPDATE recurring_expenses SET description=@description, cost=@cost, category=@category, auto_confirm=@auto_confirm, recurrence_rule=@recurrence_rule, last_executed=@last_executed WHERE id=@id'),
        parameters: {
          'id': expense.id,
          'description': expense.description,
          'cost': expense.cost,
          'category': expense.category,
          'auto_confirm': expense.autoConfirm,
          'recurrence_rule': expense.recurrenceRule,
          'last_executed':
              DateFormat('MM/dd/yyyy').format(expense.lastExecuted),
        });
  }

  /// Deletes the given recurring schedule id from the database.
  Future<Result?> deleteRecurringSchedule(String id) async {
    logger.i("Deleting recurring schedule $id");

    if (connection == null) {
      return Future.error('No connection to Database');
    }

    return await connection!.execute(
        Sql.named('DELETE FROM recurring_expenses WHERE id=@id'),
        parameters: {'id': id});
  }
}

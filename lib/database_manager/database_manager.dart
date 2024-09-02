import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/logger/logger.dart';
import 'package:postgres/postgres.dart';

/// The `DatabaseManager` class is responsible for managing the connection and operations
/// with the database. It provides methods to establish a connection, execute queries,
/// and perform other database-related tasks.
///
/// Example usage:
/// ```dart
/// var dbManager = DatabaseManager();
/// dbManager.connect();
/// dbManager.executeQuery('SELECT * FROM users');
/// ```
class DatabaseManager {
  static Connection? connection;

  /// Connects to the database.
  Future<Result?> connect(String host, String dbName, String username,
      String password, ConnectionSettings connectionSettings) async {
    logger.i("Connecting to the database...");

    try {
      connection = await Connection.open(
        Endpoint(
          host: host,
          port: 5432,
          database: dbName,
          username: username,
          password: password,
        ),
        // The postgres server hosted locally doesn't have SSL by default. If you're
        // accessing a postgres server over the Internet, the server should support
        // SSL and you should swap out the mode with `SslMode.verifyFull`.
        settings: connectionSettings,
      );

      return await connection!.execute('CREATE TABLE IF NOT EXISTS expenses ('
          '  id UUID DEFAULT gen_random_uuid() PRIMARY KEY, '
          '  cost DECIMAL(12,2) NOT NULL,'
          '  description TEXT NOT NULL,'
          '  date DATE NOT NULL,'
          '  category TEXT NOT NULL,'
          '  person TEXT NOT NULL'
          ')');
    } catch (e) {
      logger.e("Error connecting to the database: $e");
    }

    return null;
  }

  /// Returns all expenses from the database.
  Future<List<ExpenseData>?> getAllExpenses() async {
    // Execute the query
    logger.i("Fetching all expenses from the database...");

    List<ExpenseData> expenses = [];

    // Execute the query
    final results = await connection!.execute(
      Sql.named('SELECT * FROM expenses'),
    );

    for (var result in results) {
      expenses.add(ExpenseData.fromMap(result.toColumnMap()));
    }

    return expenses;
  }

  /// Inserts the given expense in the database and returns the ID.
  Future<String> insertExpense(ExpenseData expense) async {
    logger.i("Inserting an expense into the database...");

    // Execute the query
    final res = await connection!.execute(
        r'INSERT INTO expenses (cost, description, date, category, person) VALUES ($1, $2, $3, $4, $5) RETURNING id',
        parameters: [
          expense.cost,
          expense.description,
          expense.date,
          expense.category,
          expense.person,
        ]);
    if (res.isEmpty) {
      throw Exception('Error inserting expense: $expense');
    }
    return res[0][0].toString();
  }

  /// Updates values of the given expense in the database.
  Future<Result?> updateExpense(ExpenseData expense) async {
    logger.i("Updating expense ${expense.id}");

    return await connection!.execute(
        Sql.named(
            'UPDATE expenses SET cost=@cost, description=@description, date=@date, category=@category, person=@person WHERE id=@id'),
        parameters: {
          'id': expense.id,
          'description': expense.description,
          'date': expense.date,
          'category': expense.category,
          'person': expense.person,
          'cost': expense.cost
        });
  }

  /// Deletes the given expense id from the database.
  Future<Result?> deleteExpense(String id) async {
    logger.i("Deleting expense $id");

    return await connection!
        .execute(Sql.named('DELETE FROM expenses WHERE id=@id'), parameters: {
      'id': id,
    });
  }
}

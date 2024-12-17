import 'package:expense_manager/data/expense_data.dart';
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
          // .execute('CREATE TYPE OWNER_OPTIONS AS ENUM(\'Shared\')')
          .execute('''
            DO \$\$ BEGIN
              CREATE TYPE OWNER_OPTIONS AS ENUM('Shared');
            EXCEPTION
              WHEN duplicate_object THEN null;
            END \$\$;
          ''')
          .then((value) => connection!.execute('''
            DO \$\$ BEGIN
              CREATE TYPE CATEGORY_OPTIONS AS ENUM();
            EXCEPTION
              WHEN duplicate_object THEN null;
            END \$\$;
          '''))
          .then((value) =>
              connection!.execute('CREATE TABLE IF NOT EXISTS expenses ('
                  '  id UUID DEFAULT gen_random_uuid() PRIMARY KEY, '
                  '  cost DECIMAL(12,2) NOT NULL,'
                  '  description TEXT NOT NULL,'
                  '  date DATE NOT NULL,'
                  '  category CATEGORY_OPTIONS,'
                  '  person OWNER_OPTIONS'
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
      year == null ?
      Sql.named('SELECT * FROM expenses ORDER BY date DESC') :
      Sql.named('SELECT * FROM expenses  WHERE DATE_PART(\'YEAR\', date)=$year ORDER BY date DESC'),
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
        r'INSERT INTO expenses (cost, description, date, category, person) VALUES ($1, $2, $3, $4, $5) RETURNING id',
        parameters: [
          expense.cost,
          expense.description,
          DateFormat('MM/dd/yyyy').format(expense.date),
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

    if (connection == null) {
      return Future.error('No connection to Database');
    }

    return await connection!.execute(
        Sql.named(
            'UPDATE expenses SET cost=@cost, description=@description, date=@date, category=@category, person=@person WHERE id=@id'),
        parameters: {
          'id': expense.id,
          'description': expense.description,
          'date': DateFormat('MM/dd/yyyy').format(expense.date),
          'category': expense.category,
          'person': expense.person,
          'cost': expense.cost
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

  /// Get OWNER_OPTIONS values from the database.
  Future<List<String>> getOwners() async {
    logger.i("Getting owner options");

    if (connection == null) {
      return Future.error("No connection to Database");
    }

    List<String> owners = [];

    // Execute the query
    final results = await connection!.execute(
      Sql.named('SELECT unnest(enum_range(NULL::OWNER_OPTIONS))'),
    );

    for (var result in results) {
      owners.add(result.toColumnMap()["unnest"].asString);
    }

    return owners;
  }

  /// Appends to OWNER_OPTIONS enum in the database.
  Future<Result?> addOwner(String owner) async {
    logger.i("Adding owner option $owner");

    if (connection == null) {
      return Future.error("No connection to Database");
    }

    return await connection!
        .execute("ALTER TYPE OWNER_OPTIONS ADD VALUE '$owner'");
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

  /// Appends to OWNER_OPTIONS enum in the database.
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
}

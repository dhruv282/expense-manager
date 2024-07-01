import 'package:postgres/postgres.dart';

import '../logger/logger.dart';

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
  /// Connects to the database.
  void connect(String host, String dbName, String username, String password,
      ConnectionSettings connectionSettings) async {
    logger.i("Connecting to the database...");

    try {
      final connection = await Connection.open(
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

      await connection.execute('CREATE TABLE IF NOT EXISTS expenses ('
          '  id TEXT PRIMARY KEY, '
          '  cost INTEGER NOT NULL DEFAULT 0,'
          '  description TEXT NOT NULL,'
          '  date TEXT NOT NULL,'
          '  category TEXT NOT NULL,'
          '  person TEXT NOT NULL'
          ')');
    } catch (e) {
      logger.e("Error connecting to the database: $e");
    }
  }

  /// Executes the given query and returns the result.
  Future<Result?> executeInsert(String host, String dbName, String username,
      String password, ConnectionSettings connectionSettings) async {
    logger.i("Inserting a row into the database...");

    final connection = await Connection.open(
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

    try {
      // Execute the query
      return await connection.execute(
        r'INSERT INTO expenses (id, cost, description, date, category, person) VALUES ($1, $2, $3, $4, $5, $6)',
        parameters: [
          'example row',
          7,
          'this is the description',
          '01/01/2001',
          'category',
          'me'
        ],
      );
    } catch (e) {
      logger.e("Error executing query: $e");
      return null;
    }
  }

  void executeFetchOne() {
    // Execute the query
  }

  void executeFetchByField() {
    // Execute the query
  }

  void executeFetchAll() {
    // Execute the query
  }
}

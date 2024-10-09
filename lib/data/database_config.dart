import 'package:postgres/postgres.dart';

class DatabaseConfig {
  Endpoint endpoint;
  ConnectionSettings? connectionSettings;

  DatabaseConfig({
    required this.endpoint,
    this.connectionSettings,
  });
}

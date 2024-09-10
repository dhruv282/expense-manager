import 'package:expense_manager/data/database_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:postgres/postgres.dart';

class DatabaseConfigStore {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Define the required fields for your database config
  static const String dbHostKey = 'dbHost';
  static const String dbPortKey = 'dbPort';
  static const String dbNameKey = 'dbName';
  static const String dbUsernameKey = 'dbUsername';
  static const String dbPasswordKey = 'dbPassword';
  static const String sslModeKey = 'sslModeKey';

  // You can define defaults for non-sensitive fields
  final Map<String, String> defaultValues = {
    dbHostKey: 'localhost',
    dbPortKey: '5432',
    dbNameKey: 'expenses_db',
    sslModeKey: 'disable',
  };

  // Fetch a specific config value (or return default if exists)
  Future<String?> getConfigValue(String key) async {
    String? value = await _secureStorage.read(key: key);
    return value ?? defaultValues[key];
  }

  // Save a specific config value securely
  Future<void> setConfigValue(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  // Check if all required values are available
  Future<List<String>> getMissingConfigValues() async {
    List<String> missingValues = [];

    // List of required keys
    List<String> requiredKeys = [
      dbUsernameKey,
      dbPasswordKey,
    ];

    for (String key in requiredKeys) {
      String? value = await getConfigValue(key);
      if (value == null || value.isEmpty) {
        missingValues.add(key);
      }
    }

    return missingValues;
  }

  // Method to check if the config is complete
  Future<bool> isConfigComplete() async {
    List<String> missingValues = await getMissingConfigValues();
    return missingValues.isEmpty;
  }

  // Retrieving the complete database config
  Future<DatabaseConfig> getDatabaseConfig() async {
    if (!await isConfigComplete()) {
      return Future.error('Config is incomplete');
    }

    final Map<String, String> endpointMap = {
      dbHostKey: await getConfigValue(dbHostKey) ?? '',
      dbPortKey: await getConfigValue(dbPortKey) ?? '',
      dbNameKey: await getConfigValue(dbNameKey) ?? '',
      dbUsernameKey: await getConfigValue(dbUsernameKey) ?? '',
      dbPasswordKey: await getConfigValue(dbPasswordKey) ?? '',
    };

    // Throw error if any values are empty
    for (var key in endpointMap.keys) {
      String? value = endpointMap[key];
      if (value == null || value.isEmpty) {
        return Future.error('$key has empty value');
      }
    }

    final endpoint = Endpoint(
      host: endpointMap[dbHostKey] ?? '',
      port: int.tryParse(endpointMap[dbPortKey] ?? '5432') ?? 5432,
      database: endpointMap[dbNameKey] ?? '',
      username: endpointMap[dbUsernameKey],
      password: endpointMap[dbPasswordKey],
    );

    final Map<String, String> connectionSettingsMap = {
      sslModeKey: await getConfigValue(sslModeKey) ?? '',
    };

    ConnectionSettings? connectionSettings;
    SslMode? sslMode;
    String? sslModeValue = connectionSettingsMap[sslModeKey];
    if (sslModeValue != null && sslModeValue.isNotEmpty) {
      for (var s in SslMode.values) {
        if (s.toString() == sslModeValue) {
          sslMode = s;
          break;
        }
      }
    }

    connectionSettings = ConnectionSettings(sslMode: sslMode);

    return DatabaseConfig(
        endpoint: endpoint, connectionSettings: connectionSettings);
  }
}

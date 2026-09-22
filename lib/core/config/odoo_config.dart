/// Configuration class for Odoo JSON-RPC backend connection.
class OdooConfig {
  final String baseUrl;
  final String database;
  final String? defaultUsername;

  const OdooConfig({
    required this.baseUrl,
    required this.database,
    this.defaultUsername,
  });

  /// Reads configuration from compile-time environment variables or defaults to assessment instance.
  factory OdooConfig.fromEnvironment() {
    const baseUrl = String.fromEnvironment(
      'ODOO_BASE_URL',
      defaultValue: 'https://sales-assessment.odoo.com',
    );
    const database = String.fromEnvironment(
      'ODOO_DB',
      defaultValue: 'sales-assessment',
    );
    const username = String.fromEnvironment(
      'ODOO_USERNAME',
    );

    return OdooConfig(
      baseUrl: baseUrl,
      database: database,
      defaultUsername: username.isNotEmpty ? username : null,
    );
  }

  /// Full JSON-RPC URL endpoint
  String get rpcUrl {
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$cleanBase/jsonrpc';
  }
}

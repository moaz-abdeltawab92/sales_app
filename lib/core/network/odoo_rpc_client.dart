import 'dart:convert';
import 'dart:io';
import '../config/odoo_config.dart';
import '../errors/failures.dart';

/// Centralized client for communicating with Odoo via JSON-RPC protocol.
class OdooRpcClient {
  final OdooConfig config;
  final HttpClient _httpClient;

  int _requestId = 0;

  int? _uid;
  String? _username;
  String? _password;

  OdooRpcClient({required this.config, HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  /// Gets current authenticated UID or default 0.
  int? get uid => _uid;

  /// Returns true if an active UID and session credentials are set.
  bool get isAuthenticated => _uid != null && _uid! > 0;

  /// Sets or restores session credentials manually.
  void setSession({
    required int uid,
    required String username,
    required String password,
  }) {
    _uid = uid;
    _username = username;
    _password = password;
  }

  /// Calls Odoo `common.authenticate` to authenticate user against database.
  Future<int> authenticate({
    required String username,
    required String password,
  }) async {
    final payload = {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'service': 'common',
        'method': 'authenticate',
        'args': [config.database, username, password, {}],
      },
      'id': _nextId(),
    };

    final response = await _sendJsonRpcRequest(payload);

    final result = response['result'];

    if (result is int && result > 0) {
      _uid = result;
      _username = username;
      _password = password;
      return result;
    }

    if (result == false || result == null) {
      throw const AuthenticationFailure('Invalid username or password');
    }

    throw const AuthenticationFailure('Authentication failed. Please check credentials.');
  }

  /// Calls Odoo `object.execute_kw` for model methods (e.g. search_read, write, action_confirm).
  Future<dynamic> executeKw({
    required String model,
    required String method,
    required List<dynamic> args,
    Map<String, dynamic>? kwargs,
  }) async {
    final activeUid = _uid;
    final activePassword = _password;

    if (activeUid == null || activePassword == null || activePassword.isEmpty) {
      throw const AuthenticationFailure(
        'User is not authenticated. Please log in to continue.',
      );
    }

    final fullArgs = [
      config.database,
      activeUid,
      activePassword,
      model,
      method,
      args,
    ];

    if (kwargs != null && kwargs.isNotEmpty) {
      fullArgs.add(kwargs);
    }

    final payload = {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'service': 'object',
        'method': 'execute_kw',
        'args': fullArgs,
      },
      'id': _nextId(),
    };

    final response = await _sendJsonRpcRequest(payload);
    return response['result'];
  }

  int _nextId() => ++_requestId;

  /// Internal HTTP executor sending JSON payload and checking response structure.
  Future<Map<String, dynamic>> _sendJsonRpcRequest(
      Map<String, dynamic> payload) async {
    try {
      final uri = Uri.parse(config.rpcUrl);
      final request = await _httpClient.postUrl(uri);

      request.headers.contentType = ContentType.json;
      final bodyBytes = utf8.encode(json.encode(payload));
      request.contentLength = bodyBytes.length;
      request.add(bodyBytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode != HttpStatus.ok) {
        throw ServerFailure(
          'HTTP Server Error (${response.statusCode})',
        );
      }

      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (jsonResponse.containsKey('error')) {
        final errorObj = jsonResponse['error'];
        String errorMessage = 'Odoo RPC Request Failed';

        if (errorObj is Map) {
          final data = errorObj['data'];
          if (data is Map && data['message'] != null) {
            errorMessage = data['message'].toString();
          } else if (errorObj['message'] != null) {
            errorMessage = errorObj['message'].toString();
          }
        }

        // Sanitize sensitive credentials from error message
        errorMessage = _sanitizeMessage(errorMessage);

        throw ServerFailure(errorMessage);
      }

      return jsonResponse;
    } on SocketException {
      throw const NetworkFailure(
        'Unable to connect to Odoo server. Check network connection.',
      );
    } on FormatException {
      throw const ServerFailure('Invalid JSON response received from server.');
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('RPC Error: ${_sanitizeMessage(e.toString())}');
    }
  }

  String _sanitizeMessage(String msg) {
    var clean = msg;
    if (_password != null && _password!.isNotEmpty) {
      clean = clean.replaceAll(_password!, '***');
    }
    return clean;
  }

  // --- Helper parsing utilities for Odoo types ---

  /// Safely converts Odoo field value (which returns `false` if empty) to String.
  static String parseString(dynamic value, [String defaultValue = '']) {
    if (value is String) return value;
    return defaultValue;
  }

  /// Safely converts Odoo field value to int.
  static int parseInt(dynamic value, [int defaultValue = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return defaultValue;
  }

  /// Safely converts Odoo field value to double.
  static double parseDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value is num) return value.toDouble();
    return defaultValue;
  }

  /// Safely converts Odoo field value to bool.
  static bool parseBool(dynamic value, [bool defaultValue = false]) {
    if (value is bool) return value;
    return defaultValue;
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  static final http.Client client = LoggingHttpClient(http.Client());

  static String get baseUrl {
    // if (kIsWeb) return 'http://localhost:8080/api';
    // if (Platform.isAndroid) return 'http://10.0.2.2:8080/api';
    // return 'http://localhost:8080/api'; // iOS Simulator / macOS

    return 'https://book-worms-backend.onrender.com/api';
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;

  LoggingHttpClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();

    debugPrint('┌──────────────────────────────────────────────────────────');
    debugPrint('│ 🚀 API REQUEST: ${request.method}${request.url}');
    debugPrint('│ Headers: ${request.headers}');

    if (request is http.Request && request.body.isNotEmpty) {
      debugPrint('│ Request Body: ${_prettyJson(request.body)}');
    }

    try {
      final streamedResponse = await _inner.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();

      final statusEmoji =
          (response.statusCode >= 200 && response.statusCode < 300) ? '✅' : '⚠️';
      debugPrint(
          '│ $statusEmoji API RESPONSE: ${response.statusCode} (${stopwatch.elapsedMilliseconds} ms) <-- ${request.method}${request.url}');
      if (response.body.isNotEmpty) {
        debugPrint('│ Response Body: ${_prettyJson(response.body)}');
      } else {
        debugPrint('│ Response Body: <empty>');
      }
      debugPrint('└──────────────────────────────────────────────────────────');

      return http.StreamedResponse(
        Stream.value(response.bodyBytes),
        response.statusCode,
        contentLength: response.contentLength,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (e, stackTrace) {
      stopwatch.stop();
      debugPrint(
          '│ API ERROR (${stopwatch.elapsedMilliseconds} ms) <-- ${request.method}${request.url}');
      debugPrint('│ Exception: $e');
      debugPrint('└──────────────────────────────────────────────────────────');
      Error.throwWithStackTrace(e, stackTrace);
    }
  }

  String _prettyJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return raw;
    }
  }
}
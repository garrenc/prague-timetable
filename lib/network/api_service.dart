import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timetable/models/api_result.dart';
import 'package:timetable/network/logger.dart';

class ApiService {
  static const String _baseUrl = 'https://api.golemio.cz/v2';
  static const Duration _requestTimeout = Duration(seconds: 30);

  // Singleton instance
  static ApiService? _instance;

  ApiService._() {
    _initialize();
  }

  static ApiService get instance => _instance ??= ApiService._();

  late final Dio apiClient;
  String? _apiToken;

  void _initialize() {
    apiClient = Dio(BaseOptions(baseUrl: _baseUrl, receiveTimeout: _requestTimeout));

    _apiToken = dotenv.env['GOLEMIO_API_TOKEN'];
    apiClient.options.headers['X-Access-Token'] = _apiToken;
    apiClient.options.headers['accept'] = 'application/json';

    assert(_apiToken != null, 'API token is not set, request wont work');
  }

  Future<ApiResult> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      // Build and log the complete request URL
      final uri = Uri.parse('$_baseUrl$endpoint').replace(queryParameters: queryParameters);
      AppLogger.log('GET ${uri.toString()}');

      final response = await apiClient.get(endpoint, queryParameters: queryParameters);

      AppLogger.log('${response.statusCode} - ${uri.toString()}');
      return response.statusCode == 200 ? ApiResult(data: response.data, responseCode: response.statusCode!) : throw Exception('Failed to load data: ${response.statusCode}');
    } on DioException catch (e, st) {
      AppLogger.error('Dio error: $e', stackTrace: st);
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid API token. Please check your configuration.');
      }

      throw Exception('Network error: ${e.message}');
    } catch (e, st) {
      AppLogger.error('Unexpected error: $e', stackTrace: st);
      rethrow;
    }
  }

  bool get hasValidToken => _apiToken != null && _apiToken!.isNotEmpty;
}

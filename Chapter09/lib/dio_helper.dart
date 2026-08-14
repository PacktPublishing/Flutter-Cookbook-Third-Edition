import 'dart:convert';
import 'pizza.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class DioHelper {
  //use these or add your own wiremock server and change the authority and path

  static const String baseUrl = 'https://YOURCODE.wiremockapi.cloud';
  late final Dio _dio;
  // Replace with your own WireMock API token
  static const String apiToken = 'YOUR_API_TOKEN';

  DioHelper() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add authentication only for WireMock admin endpoints
          if (options.path.startsWith('/__admin')) {
            options.headers[HttpHeaders.authorizationHeader] =
                'Token $apiToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;
          final retryCount = requestOptions.extra['retryCount'] ?? 0;

          final shouldRetry =
              requestOptions.method == 'GET' &&
              retryCount < 2 &&
              (error.type == DioExceptionType.connectionTimeout ||
                  error.type == DioExceptionType.receiveTimeout ||
                  error.type == DioExceptionType.connectionError);

          if (shouldRetry) {
            requestOptions.extra['retryCount'] = retryCount + 1;

            try {
              final response = await _dio.fetch(requestOptions);
              return handler.resolve(response);
            } on DioException catch (e) {
              return handler.next(e);
            }
          }
          handler.next(error);
        },
      ),
    );
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<List<Pizza>> getPizzaList() async {
    try {
      final Response response = await _dio.get('/pizzalist');
      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> pizzaMapList = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        return pizzaMapList
            .map((pizzaJson) => Pizza.fromJson(pizzaJson))
            .toList();
      } else {
        return [];
      }
    } on Exception catch (e) {
      return [];
    }
  }

  Future<String> postPizza(Pizza pizza) async {
    try {
      final Response response = await _dio.post('/pizza', data: pizza.toJson());
      return response.data.toString();
    } on DioException catch (e) {
      return e.message ?? 'Error posting pizza';
    }
  }

  Future<String> putPizza(Pizza pizza) async {
    try {
      final Response response = await _dio.put('/pizza', data: pizza.toJson());
      return response.data.toString();
    } on DioException catch (e) {
      return e.message ?? 'Error updating pizza';
    }
  }

  Future<String> deletePizza(int id) async {
    try {
      final Response response = await _dio.delete(
        '/pizza',
        queryParameters: {'id': id},
      );
      return response.data.toString();
    } on DioException catch (e) {
      return e.message ?? 'Error deleting pizza';
    }
  }

  Future<String> getAdminMappings() async {
    try {
      final Response response = await _dio.get('/__admin/mappings');
      return response.data.toString();
    } on DioException catch (e) {
      return e.message ?? 'Error calling admin endpoint';
    }
  }
}

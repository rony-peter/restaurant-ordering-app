import 'package:dio/dio.dart';

class ApiClient {
  static final String baseUrl =
      'http://localhost:4000/api'; // Replace with local IP for device testing
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // Resolve Table QR Token
  Future<Map<String, dynamic>> resolveQrToken(String token) async {
    final response = await dio.get('/tables/qr/$token');
    return response.data;
  }

  // Fetch Restaurant Menu
  Future<List<dynamic>> fetchMenu(String restaurantId) async {
    final response = await dio.get('/menu/restaurant/$restaurantId');
    return response.data;
  }

  // Submit Order
  Future<Map<String, dynamic>> placeOrder(
    Map<String, dynamic> orderPayload,
  ) async {
    final response = await dio.post('/orders', data: orderPayload);
    return response.data;
  }
}

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

  // Generic POST method
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic body,
  }) async {
    final response = await dio.post(path, data: body);
    return response.data as Map<String, dynamic>;
  }

  // Dedicated Payment Checkout method
  Future<Map<String, dynamic>> createPaymentCheckout({
    required String orderId,
    required String restaurantId,
  }) async {
    final response = await dio.post(
      '/payments/checkout',
      data: {
        'orderId': orderId,
        'restaurantId': restaurantId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

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

  // Fetch Order Receipt
  Future<Map<String, dynamic>> getReceipt(
    String orderId,
    String restaurantId,
  ) async {
    final response = await dio.get(
      '/orders/$orderId/receipt',
      queryParameters: {
        'restaurantId': restaurantId,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
import 'package:flutter/foundation.dart'; // Add this import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  late io.Socket _socket;

  void initCustomerSocket({
    required String orderId,
    required Function(Map<String, dynamic>) onOrderStatusUpdated,
  }) {
    _socket = io.io(
      'http://localhost:4000',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) {
      debugPrint('Connected to Socket Server');
      _socket.emit('joinOrderRoom', orderId);
    });

    _socket.on('orderStatusChanged', (data) {
      if (data != null) {
        onOrderStatusUpdated(Map<String, dynamic>.from(data));
      }
    });

    _socket.onDisconnect((_) => debugPrint('Disconnected from Socket Server'));
  }

  void disconnect() {
    _socket.disconnect();
  }
}

final socketServiceProvider = Provider((ref) => SocketService());

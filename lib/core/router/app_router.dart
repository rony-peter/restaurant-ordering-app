import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/features/customer/views/qr_menu_screen.dart';

final GoRouter appRouter = GoRouter(
  // Default to root so non-QR visitors see a landing page
  initialLocation: '/',
  
  routes: [
    // 1. Primary Entry Point for Table QR Scans
    GoRoute(
      path: '/order',
      builder: (context, state) {
        // Extract 'qr' or 'token' dynamically from query parameters
        final token = state.uri.queryParameters['qr'] ?? state.uri.queryParameters['token'];

        if (token == null || token.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Invalid or Missing QR Code.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          );
        }

        return QrMenuScreen(qrToken: token);
      },
    ),

    // 2. Backward Compatibility Route
    GoRoute(
      path: '/table',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'] ?? state.uri.queryParameters['qr'];

        if (token == null || token.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Invalid or Missing QR Token.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          );
        }

        return QrMenuScreen(qrToken: token);
      },
    ),

    // 3. Root Landing / Fallback Screen
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Please scan a QR code at your table to view the menu.'),
        ),
      ),
    ),
  ],
);
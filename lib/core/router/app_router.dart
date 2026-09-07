import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/features/customer/views/qr_menu_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/table?token=e51270c32f492644620a42fdcf11bcc2',
  routes: [
    // 1. Customer QR Entry Route (PWA)
    GoRoute(
      path: '/table',
      builder: (context, state) {
        // Extract token from URL, e.g., /table?token=abc-123
        final token = state.uri.queryParameters['token'];

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

        // Return the Neo-Brutalist Menu UI
        return QrMenuScreen(qrToken: token);
      },
    ),

    // Default Fallback / Home Route
    GoRoute(
      path: '/',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text('Welcome to QR Restaurant Ordering')),
      ),
    ),
  ],
);

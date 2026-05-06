import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/booking/presentation/home_dashboard_screen.dart';
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/queue/presentation/queue_status_screen.dart';
import '../../features/appointments/presentation/appointment_list_screen.dart';
import '../../features/appointments/presentation/search_filter_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/sync/presentation/offline_sync_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeDashboardScreen(),
      ),
      GoRoute(
        path: '/book',
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: '/queue',
        builder: (context, state) => const QueueStatusScreen(),
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentListScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchFilterScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/sync',
        builder: (context, state) => const OfflineSyncScreen(),
      ),
    ],
  );
});

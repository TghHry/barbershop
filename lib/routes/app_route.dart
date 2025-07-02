import 'package:barbershop2/presentations/admin/auth/login/screens/login_screen.dart'; // Ensure correct path for LoginScreen
import 'package:barbershop2/presentations/admin/auth/register/screens/register_screen.dart'; // Ensure correct path for RegisterScreen
import 'package:barbershop2/presentations/admin/barbershop/home/add_service/screens/add_service_screen.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/history/history_models/history_model.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/history/history_screens/history_screen.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/home_screens/home_screen.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/booking/screens/booking_screen.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/list_service_models/list_service_model.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/list_service_screens/list_screen.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/history/update/screen/update_screen.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/profile/screens/profile_screen.dart';
import 'package:barbershop2/utils/splash.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 1. Define the GoRouter configuration
final GoRouter router = GoRouter(
  initialLocation: '/splash', // Set the initial route to RegisterScreen
  routes: [
    GoRoute(
      path: '/splash',
      builder:
          (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/login',
      builder:
          (context, state) =>
              LoginScreen(), // Assuming LoginScreen takes no arguments
    ),
     GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfileScreen();
      },
    ),
    // You can add more routes here as your app grows, e.g.:
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/service_list', // NEW ROUTE FOR SERVICES
      builder: (context, state) => const ServicesListScreen(),
    ),
    GoRoute(
      path: '/booking_service_detail', // Path tanpa parameter ID di sini
      builder: (context, state) {
        final ServiceItem? service = state.extra as ServiceItem?; // Menerima objek ServiceItem dari 'extra'

        if (service == null) {
          // Tangani jika objek layanan tidak diteruskan (misalnya, jika user mengetik URL langsung)
          debugPrint('BookingDetailScreen: Objek layanan null, navigasi tidak valid.');
          return  Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(
              child: Text(
                'Detail layanan tidak disediakan. Mohon pilih layanan terlebih dahulu.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        // Teruskan objek service yang tidak null ke konstruktor
        return BookingDetailScreen(service: service); // <<< INI SEKARANG BENAR
      },
    ),
     GoRoute(
      path: '/add_booking', // Path yang akan digunakan untuk menavigasi ke AddBooking
      name: 'add_booking', // Nama rute untuk navigasi berdasarkan nama
      builder: (context, state) {
        return  AddBookingScreen(); // Mengembalikan instance dari widget AddBooking
      },
    ),
    GoRoute(
      path: '/my_bookings', // NEW ROUTE FOR BOOKING HISTORY
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(
      path: '/update_booking_detail',
      name: 'update_booking_detail',
      builder: (context, state) {
        final BookingHistoryItem? booking = state.extra as BookingHistoryItem?;

        if (booking == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
              backgroundColor: Colors.redAccent,
            ),
            body: Center(
              child: Text(
                'Detail booking tidak tersedia untuk di-update.',
                style: TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Sekarang ini akan benar karena UpdateBookingScreen menerima 'booking'
        return UpdateBookingScreen(booking: booking);
      },
    ),
  ],
  // Optional: Add error handling for unknown routes
  errorBuilder:
      (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Page not found: ${state.uri.path}')),
      ),
);
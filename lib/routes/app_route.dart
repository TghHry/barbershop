import 'package:barbershop2/presentations/admin/auth/login/screens/login_screen.dart'; // Ensure correct path for LoginScreen
import 'package:barbershop2/presentations/admin/auth/register/screens/register_screen.dart'; // Ensure correct path for RegisterScreen
import 'package:barbershop2/presentations/admin/barbershop/list_service/add_service/screens/add_service_screen.dart';
// import 'package:barbershop2/presentations/admin/barbershop/booking/screens/booking_screen.dart';
import 'package:barbershop2/presentations/admin/barbershop/history/history_models/history_model.dart';
import 'package:barbershop2/presentations/admin/barbershop/history/history_screens/history_screen.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/screens/home_screen.dart';
import 'package:barbershop2/presentations/admin/barbershop/list_service/booking/screens/booking_screen.dart';
import 'package:barbershop2/presentations/admin/barbershop/list_service/list_service_models/list_service_model.dart';
// import 'package:barbershop2/presentations/admin/barbershop/list_service/models/list_service_model.dart';
import 'package:barbershop2/presentations/admin/barbershop/list_service/list_service_screens/list_screen.dart';
import 'package:barbershop2/presentations/admin/barbershop/history/update/screen/update_screen.dart';
import 'package:barbershop2/utils/splash.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 1. Define the GoRouter configuration
final GoRouter router = GoRouter(
  initialLocation: '/splash', // Set the initial route to RegisterScreen
  routes: [
     GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) =>
          LoginScreen(), // Assuming LoginScreen takes no arguments
    ),
    // You can add more routes here as your app grows, e.g.:
    GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    GoRoute(
      path: '/service-list', // NEW ROUTE FOR SERVICES
      builder: (context, state) => const ServicesListScreen(),
    ),
    GoRoute(
      path: '/booking_service_detail', // PATH YANG BENAR UNTUK BOOKING DETAIL SCREEN
      builder: (context, state) {
        // Ketika menavigasi ke '/add_booking', kita MENGHARAPKAN objek ServiceItem
        // yang dilewatkan melalui parameter 'extra' dari rute sebelumnya (misalnya dari ServicesListScreen).
        final ServiceItem? service = state.extra as ServiceItem?;

        // Penting: Lakukan pengecekan null untuk keamanan.
        // Jika 'service' tidak ada (misalnya, jika user langsung mengetik path di URL browser),
        // kita bisa menampilkan pesan error atau mengarahkan kembali.
        if (service == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(
              child: Text(
                'Detail layanan tidak disediakan untuk booking baru. Mohon pilih layanan terlebih dahulu.',
              ),
            ),
          );
        }
        // Jika 'service' ada, kita membangun BookingDetailScreen dan melewatkan objek layanan tersebut.
        return BookingDetailScreen(service: service);
      },
    ),
    GoRoute(
      path: '/add_booking',
      builder: (context, state) {
        // Ekstrak BookingHistoryItem dari state.extra
        final BookingHistoryItem? booking = state.extra as BookingHistoryItem?;
        if (booking == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(
              child: Text('Detail booking tidak disediakan untuk re-book.'),
            ),
          );
        }
        return AddBooking(booking: booking); // Membangun RebookServiceScreen
      },
    ),
    GoRoute(
      path: '/my_bookings', // NEW ROUTE FOR BOOKING HISTORY
      builder: (context, state) => const MyBookingsScreen(),
    ),
    GoRoute(
      path: '/update_booking_detail',
      builder: (context, state) {
        // === PASTIKAN INI MENGHARAPKAN BookingHistoryItem ===
        final BookingHistoryItem? booking = state.extra as BookingHistoryItem?;
        if (booking == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(
              child: Text('Detail booking tidak tersedia untuk update.'),
            ),
          );
        }
        return UpdateBookingScreen(booking: booking);
      },
    ),
    GoRoute(
      path:
          '/rebook_service', // ROUTE BARU UNTUK MEMBUAT BOOKING BARU DARI RIWAYAT
      builder: (context, state) {
        final BookingHistoryItem? booking =
            state.extra as BookingHistoryItem?; // Menerima BookingHistoryItem
        if (booking == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(
              child: Text('Detail booking tidak tersedia untuk re-book.'),
            ),
          );
        }
        return AddBooking(booking: booking); // Membangun RebookServiceScreen
      },
    ),
  ],
  // Optional: Add error handling for unknown routes
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text('Page not found: ${state.uri.path}')),
  ),
);

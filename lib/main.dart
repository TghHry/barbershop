// import 'package:barbershop2/presentations/admin/auth/register/screens/registrasi_screen.dart';
import 'package:flutter/material.dart';
import 'package:barbershop2/routes/app_route.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // Use routerConfig instead of home
      title: 'Barbershop Booking App', // Add a title for your app
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false, // Hide debug banner
    );
  }
}

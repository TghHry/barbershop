import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // For navigation after booking
import 'package:shared_preferences/shared_preferences.dart'; // To get user ID
import 'package:flutter/foundation.dart'; // For debugPrint

// Import your service and models
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/list_service_models/list_service_model.dart'; // ServiceItem model
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/booking/service/booking_service.dart'; // BookingService
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/booking/models/booking_model.dart'; // BookingResponse model

class BookingDetailScreen extends StatefulWidget {
  final ServiceItem service; // This screen receives the selected service

  // <<< KOREKSI DI SINI >>>
  // Hapus 'required int serviceId' dari konstruktor
  const BookingDetailScreen({super.key, required this.service});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingService _bookingService = BookingService();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Optional: Pre-select a default date/time or current date/time
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026), // Allow bookings up to next year
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      debugPrint('BookingDetailScreen: Selected date: $_selectedDate');
    }
  }

  // Function to show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
      debugPrint('BookingDetailScreen: Selected time: $_selectedTime');
    }
  }

  // Function to handle booking submission
  Future<void> _bookService() async {
    if (_selectedDate == null || _selectedTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date and time for your booking.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      debugPrint('BookingDetailScreen: Date or time not selected.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(
        'user_id',
      ); // Get user ID from SharedPreferences

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User ID not found. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
          // Optionally navigate to login
          context.go('/login');
        }
        debugPrint(
          'BookingDetailScreen: User ID is null. Cannot proceed with booking.',
        );
        return;
      }

      // Combine date and time into a single DateTime object
      final DateTime finalBookingTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      debugPrint(
        'BookingDetailScreen: Attempting to book service with ID: ${widget.service.id} for User ID: $userId at $finalBookingTime',
      );

      final BookingResponse response = await _bookingService.createBooking(
  userId: userId,
  serviceId: widget.service.id!, // Aman karena sudah dicheck di atas
  bookingTime: finalBookingTime,
);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint(
          'BookingDetailScreen: Booking successful! Response: ${response.message}',
        );
        // Navigate back to the services list or home after successful booking
        context.pop(); // Go back to the previous screen (ServicesListScreen)
        // Or context.go('/home'); // Go to home screen
      }
    } catch (e) {
      debugPrint('BookingDetailScreen: Error creating booking: $e');
      if (mounted) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      debugPrint('BookingDetailScreen: Loading state set to false.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2233),
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: const Color(0xFF1A2233),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          // <<< KOREKSI: Mengganti Container dengan IconButton
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ), // Ikon panah kembali
          onPressed: () {
            // Navigator.pop(context) akan mengembalikan ke halaman sebelumnya.
            // Jika ini adalah halaman paling atas (root) di stack navigasi,
            // Anda mungkin perlu logika yang berbeda (misalnya, context.go('/home')).
            if (Navigator.of(context).canPop()) {
              // Periksa apakah ada halaman sebelumnya
              Navigator.of(context).pop();
            } else {
              // Contoh: Jika ini halaman pertama setelah login, bisa arahkan ke home atau keluar aplikasi
              // context.go('/home'); // Opsi: kembali ke home screen jika tidak bisa pop
              debugPrint(
                'ProfileScreen: Tidak ada halaman sebelumnya untuk di-pop.',
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: const Color(0xFF2B3A4F),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking: ${widget.service.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Harga: Rp${widget.service.price}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.service.description ??
                      'Tidak ada deskripsi', // Baris 188
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Date Selection
                const Text(
                  'Select Date:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.white54,
                  ),
                  title: Text(
                    _selectedDate == null
                        ? 'No date selected'
                        : 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16, color: Colors.white54),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),

                // Time Selection
                const Text(
                  'Select Time:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.white54),
                  title: Text(
                    _selectedTime == null
                        ? 'No time selected'
                        : 'Time: ${_selectedTime!.format(context)}',
                    style: const TextStyle(fontSize: 16, color: Colors.white54),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                  ),
                  onTap: () => _selectTime(context),
                ),
                const SizedBox(height: 32),

                // Book Button
                SizedBox(
                  width: double.infinity, // Make button full width
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _bookService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Confirm Booking',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

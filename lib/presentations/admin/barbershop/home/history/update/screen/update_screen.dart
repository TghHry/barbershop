import 'package:barbershop2/presentations/admin/barbershop/home/history/update/service/update_service.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/history/history_models/history_model.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/history/update/models/update_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // For navigation after update

import 'package:intl/intl.dart'; // For date formatting

class UpdateBookingScreen extends StatefulWidget {
  final BookingHistoryItem
  booking; // This screen receives the booking to update

  const UpdateBookingScreen({super.key, required this.booking});

  @override
  State<UpdateBookingScreen> createState() => _UpdateBookingScreenState();
}

class _UpdateBookingScreenState extends State<UpdateBookingScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Controllers/Variables for form inputs
  String? _selectedStatus; // For the status dropdown
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with current booking data
    _selectedStatus = widget.booking.status; // Nilai awal
    _selectedDate = widget.booking.bookingTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.booking.bookingTime);

    debugPrint(
      'UpdateBookingScreen: Initializing with booking ID: ${widget.booking.id}',
    );
    debugPrint(
      'UpdateBookingScreen: Current status: ${widget.booking.status}, Time: ${widget.booking.bookingTime}',
    );
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // Allow past dates for reschedule if needed
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 2),
      ), // Allow up to 2 years in future
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      debugPrint('UpdateBookingScreen: New date selected: $_selectedDate');
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
      debugPrint('UpdateBookingScreen: New time selected: $_selectedTime');
    }
  }

  // Function to handle booking update submission
  Future<void> _updateBooking() async {
    if (_selectedStatus == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a status.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      debugPrint('UpdateBookingScreen: Status not selected.');
      return;
    }

    // Combine date and time
    final DateTime? finalBookingTime =
        (_selectedDate != null && _selectedTime != null)
            ? DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            )
            : null; // If either is null, send null or handle as error

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint(
        'UpdateBookingScreen: Attempting to update booking ID: ${widget.booking.id}',
      );
      debugPrint(
        'UpdateBookingScreen: Sending status: $_selectedStatus, new time: $finalBookingTime',
      );

      final UpdateBookingResponse
      response = await _apiService.updateBookingStatus(
        bookingId: widget.booking.id,
        status: _selectedStatus!,
        // bookingTime: finalBookingTime, // Ini masih dikomentari, Anda perlu mengaktifkannya di ApiService jika ingin mengirim waktu juga
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint(
          'UpdateBookingScreen: Booking updated successfully! Response: ${response.message}',
        );
        context.pop(); // Pop back to MyBookingsScreen
      }
    } catch (e) {
      debugPrint('UpdateBookingScreen: Error updating booking: $e');
      if (mounted) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      debugPrint('UpdateBookingScreen: Loading state set to false.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format current booking time for display
    final currentFormattedTime = DateFormat(
      'EEEE, dd MMMM, HH:mm',
    ).format(widget.booking.bookingTime.toLocal());
    final selectedFormattedDate =
        _selectedDate == null
            ? 'No date selected'
            : DateFormat('dd MMMMyyyy').format(_selectedDate!.toLocal());
    final selectedFormattedTime =
        _selectedTime == null
            ? 'No time selected'
            : _selectedTime!.format(context);

    // --- LOGIKA STATUS DINAMIS BERDASARKAN ATURAN TRANSISI BACKEND ---
    List<String> allowedStatuses = [];
    String currentStatusLower = widget.booking.status.toLowerCase();

    debugPrint(
      'UpdateBookingScreen: Current booking status (lowercase): $currentStatusLower',
    );

    // Aturan transisi status yang umum (sesuaikan dengan backend Anda)
    // Menggunakan ejaan 'cancelled' (dua 'l') secara konsisten.
    // Memastikan 'completed' bisa diakses dari 'confirmed'.
    if (currentStatusLower == 'pending') {
      allowedStatuses.addAll([
        'confirmed',
        'cancelled',
      ]); // Menggunakan 'cancelled'
    } else if (currentStatusLower == 'confirmed') {
      allowedStatuses.addAll([
        'completed',
        'cancelled',
      ]); // Menggunakan 'completed' dan 'cancelled'
    } else if (currentStatusLower == 'cancelled' ||
        currentStatusLower == 'completed') {
      // Jika sudah 'cancelled' atau 'completed', biasanya tidak bisa diubah lagi.
      // Hanya tampilkan status saat ini sebagai pilihan (tidak bisa diubah).
      allowedStatuses.add(currentStatusLower);
    } else {
      // Untuk status lain yang tidak terduga, atau status awal yang tidak ada di atas,
      // tambahkan semua status yang mungkin sebagai fallback.
      allowedStatuses.addAll([
        'pending',
        'confirmed',
        'completed',
        'cancelled',
      ]); // Menggunakan 'cancelled'
    }

    // Pastikan status saat ini selalu ada di dropdown (jika belum ada dari logika di atas)
    if (!allowedStatuses.contains(currentStatusLower)) {
      allowedStatuses.add(currentStatusLower);
    }

    // Hapus duplikat dan urutkan untuk tampilan yang lebih baik
    allowedStatuses = allowedStatuses.toSet().toList();
    allowedStatuses.sort();

    debugPrint(
      'UpdateBookingScreen: Final allowed statuses for dropdown: $allowedStatuses',
    );
    debugPrint(
      'UpdateBookingScreen: Currently selected status for dropdown value: $_selectedStatus',
    );

    return Scaffold(
      // backgroundColor: Colors.black, // Jika Anda ingin gradien, ini harus transparan dan menggunakan Stack
      appBar: AppBar(
        title: const Text('Edit Booking'),
        backgroundColor: Colors.black,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          margin: const EdgeInsets.only(top: 10),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Booking Details
                const Text(
                  'Current Booking Details:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service: ${widget.booking.service.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Current Time: $currentFormattedTime',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Current Status: ${widget.booking.status.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                (widget.booking.status.toLowerCase() ==
                                        'pending')
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Status Selection
                const Text(
                  'Change Status:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'New Status',
                  ),
                  items:
                      allowedStatuses.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value.toUpperCase()),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                    debugPrint(
                      'UpdateBookingScreen: New status selected: $_selectedStatus',
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Reschedule Section
                const Text(
                  'Reschedule (Optional):',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    'Date: $selectedFormattedDate',
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(
                    'Time: $selectedFormattedTime',
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _selectTime(context),
                ),
                const SizedBox(height: 32),

                // Confirm Update Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
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
                              'Confirm Update',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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

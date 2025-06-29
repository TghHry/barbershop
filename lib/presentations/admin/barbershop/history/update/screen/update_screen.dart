import 'package:barbershop2/presentations/admin/barbershop/list_service/booking/service/booking_service.dart';
import 'package:barbershop2/presentations/admin/barbershop/history/history_models/history_model.dart';
import 'package:barbershop2/presentations/admin/barbershop/history/update/models/update_models.dart';
// import 'package:barbershop2/presentations/admin/barbershop/booking/models/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // For navigation after update
// import 'package:shared_preferences/shared_preferences.dart'; // To get userId if needed, though bookingId is primary
// import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:intl/intl.dart'; // For date formatting

// // Import your services and models
// import 'package:barbershop2/models/booking_history_models/booking_history_item.dart'; // BookingHistoryItem model
// import 'package:barbershop2/services/booking_service.dart'; // BookingService (for updateBooking method)
// import 'package:barbershop2/models/booking_models/update_booking_response.dart'; // UpdateBookingResponse model

class UpdateBookingScreen extends StatefulWidget {
  final BookingHistoryItem booking; // This screen receives the booking to update

  const UpdateBookingScreen({super.key, required this.booking});

  @override
  State<UpdateBookingScreen> createState() => _UpdateBookingScreenState();
}

class _UpdateBookingScreenState extends State<UpdateBookingScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;

  // Controllers/Variables for form inputs
  String? _selectedStatus; // For the status dropdown
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Initialize form fields with current booking data
    _selectedStatus = widget.booking.status;
    _selectedDate = widget.booking.bookingTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.booking.bookingTime);

    debugPrint('UpdateBookingScreen: Initializing with booking ID: ${widget.booking.id}');
    debugPrint('UpdateBookingScreen: Current status: ${widget.booking.status}, Time: ${widget.booking.bookingTime}');
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past dates for reschedule if needed
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // Allow up to 2 years in future
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
          const SnackBar(content: Text('Please select a status.'), backgroundColor: Colors.orange),
        );
      }
      debugPrint('UpdateBookingScreen: Status not selected.');
      return;
    }

    // Combine date and time
    final DateTime? finalBookingTime = (_selectedDate != null && _selectedTime != null)
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
      debugPrint('UpdateBookingScreen: Attempting to update booking ID: ${widget.booking.id}');
      debugPrint('UpdateBookingScreen: Sending status: $_selectedStatus, new time: $finalBookingTime');

      final UpdateBookingResponse response = await _bookingService.updateBooking(
        bookingId: widget.booking.id,
        status: _selectedStatus,
        bookingTime: finalBookingTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint('UpdateBookingScreen: Booking updated successfully! Response: ${response.message}');
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
    final currentFormattedTime = DateFormat('EEEE, dd MMMM, HH:mm')
        .format(widget.booking.bookingTime.toLocal());
    final selectedFormattedDate = _selectedDate == null
        ? 'No date selected'
        : DateFormat('dd MMMM yyyy').format(_selectedDate!.toLocal());
    final selectedFormattedTime = _selectedTime == null
        ? 'No time selected'
        : _selectedTime!.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Booking'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Service: ${widget.booking.service.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Current Time: $currentFormattedTime', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Current Status: ${widget.booking.status.toUpperCase()}', style: TextStyle(fontSize: 14, color: (widget.booking.status.toLowerCase() == 'pending') ? Colors.orange : Colors.green)),
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
              items: <String>['pending', 'confirmed', 'cancelled', 'completed']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue;
                });
                debugPrint('UpdateBookingScreen: New status selected: $_selectedStatus');
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
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm Update',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
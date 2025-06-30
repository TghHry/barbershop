import 'package:barbershop2/presentations/admin/barbershop/history/delete/models/delete_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:go_router/go_router.dart'; // For potential navigation from this screen (e.g., back)
import 'package:intl/intl.dart'; // For date formatting (add intl: ^0.18.1 to pubspec.yaml)

import 'package:barbershop2/presentations/admin/barbershop/history/delete/delete_service.dart';
import 'package:barbershop2/presentations/admin/barbershop/history/history_service/history_service.dart'; // Adjust path if needed
import 'package:barbershop2/presentations/admin/barbershop/history/history_models/history_model.dart'; // Adjust path if needed

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingHistoryService _bookingHistoryService = BookingHistoryService();
  late Future<BookingHistoryResponse> _bookingHistoryFuture;
  bool _isDeletingBooking = false; // <--- ADD THIS LINE HERE
  final BookingService _bookingService =
      BookingService(); // <--- VERIFY/ADD THIS LINE

  @override
  void initState() {
    super.initState();
    _bookingHistoryFuture =
        _bookingHistoryService
            .getBookingHistory(); // Initiate fetching booking history
    debugPrint(
      'MyBookingsScreen: Initiating booking history fetch in initState...',
    );
  }

  // Function to handle pull-to-refresh action
  Future<void> _refreshBookingHistory() async {
    debugPrint('MyBookingsScreen: Pull-to-refresh triggered.');
    setState(() {
      _bookingHistoryFuture =
          _bookingHistoryService.getBookingHistory(); // Re-initiate fetching
    });
    // Await the future so RefreshIndicator knows when to stop
    await _bookingHistoryFuture;
    debugPrint('MyBookingsScreen: Booking history refreshed successfully!');
  }

  // --- NEW: Function to show Delete Confirmation Dialog ---
  Future<void> _showDeleteConfirmationDialog(BookingHistoryItem booking) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Booking?'),
          content: Text(
            'Are you sure you want to delete the booking for "${booking.service.name}" on ${DateFormat('dd MMMM yyyy HH:mm').format(booking.bookingTime.toLocal())}?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // User cancelled
              },
            ),
            ElevatedButton(
              child:
                  _isDeletingBooking // Show loading if deleting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ), // White text for dark button
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red for delete action
              ),
              onPressed:
                  _isDeletingBooking
                      ? null
                      : () {
                        Navigator.of(dialogContext).pop(true); // User confirmed
                      },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      debugPrint(
        'MyBookingsScreen: User confirmed delete for booking ID: ${booking.id}',
      );
      await _deleteBooking(booking.id); // Proceed with deletion
    } else {
      debugPrint('MyBookingsScreen: Delete action cancelled by user.');
    }
  }

  // --- NEW: Function to handle the actual Delete API call ---
  Future<void> _deleteBooking(int bookingId) async {
    setState(() {
      _isDeletingBooking = true; // Set loading state for the delete action
    });

    try {
      debugPrint('MyBookingsScreen: Calling deleteBooking for ID: $bookingId');
      final DeleteBookingResponse deleteRes = await _bookingService
          .deleteBooking(bookingId: bookingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(deleteRes.message),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint(
          'MyBookingsScreen: Booking ID $bookingId deleted successfully! Message: ${deleteRes.message}',
        );
        _refreshBookingHistory(); // Refresh the list to remove the deleted item
      }
    } catch (e) {
      debugPrint('MyBookingsScreen: Failed to delete booking: $e');
      if (mounted) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isDeletingBooking = false; // Reset loading state
      });
      debugPrint(
        'MyBookingsScreen: Delete booking loading state set to false.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        // Added RefreshIndicator for pull-to-refresh
        onRefresh: _refreshBookingHistory,
        child: FutureBuilder<BookingHistoryResponse>(
          future: _bookingHistoryFuture, // The future we're waiting for
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              debugPrint(
                'MyBookingsScreen: ConnectionState.waiting - showing CircularProgressIndicator.',
              );
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              debugPrint(
                'MyBookingsScreen: snapshot.hasError - ${snapshot.error}',
              );
              // Display an error message and a retry button
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          _refreshBookingHistory(); // Retry fetching when button is pressed
                          debugPrint(
                            'MyBookingsScreen: Retrying fetch on error button tap.',
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final bookings =
                  snapshot.data!.data; // Access the list of booking items
              debugPrint(
                'MyBookingsScreen: Data loaded. Number of bookings: ${bookings.length}',
              );

              if (bookings.isEmpty) {
                // If there are no bookings, ensure RefreshIndicator still works by using a scrollable widget
                return ListView(
                  children: const [
                    SizedBox(
                      height: 100,
                    ), // Add some spacing for visual centering
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'You have no past or upcoming bookings.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Text(
                            'Book a service to see it here!',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Display the list of bookings using ListView.builder
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  // Format booking time for user-friendly display
                  // Ensure 'intl' package is added to pubspec.yaml
                  final formattedTime = DateFormat(
                    'EEEE, dd MMMM yyyy HH:mm',
                  ).format(booking.bookingTime.toLocal());

                  // Determine status color for visual feedback
                  Color statusColor;
                  switch (booking.status.toLowerCase()) {
                    case 'pending':
                      statusColor = Colors.orange[700]!;
                      break;
                    case 'confirmed':
                      statusColor = Colors.green[700]!;
                      break;
                    case 'cancelled':
                      statusColor = Colors.red[700]!;
                      break;
                    case 'completed':
                      statusColor = Colors.blue[700]!;
                      break;
                    default:
                      statusColor = Colors.grey[700]!;
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Service: ${booking.service.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Description: ${booking.service.description}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: Rp${booking.service.price}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.blueGrey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Scheduled: $formattedTime',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: statusColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Status: ${booking.status.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // Optional: Add actions like "Cancel Booking" or "View Details"
                          if (booking.status.toLowerCase() == 'pending')
                            Row(
                              children: [
                                // Align(
                                //   alignment: Alignment.bottomRight,
                                //   child: TextButton(
                                //     onPressed: () {
                                //       // Jika Anda ingin tombol ini untuk RE-BOOK (booking baru berdasarkan yang lama)
                                //       // Kondisi bisa disesuaikan, misalnya hanya untuk booking yang 'completed' atau 'cancelled'
                                //       // Untuk contoh ini, saya akan izinkan untuk booking status 'pending' (sesuai snippet Anda sebelumnya)
                                //       if (booking.status.toLowerCase() ==
                                //           'pending') {
                                //         if (mounted) {
                                //           context.push(
                                //             '/add_booking', // Ini adalah path GoRouter yang baru
                                //             extra:
                                //                 booking, // Melewatkan objek BookingHistoryItem
                                //           );
                                //           debugPrint(
                                //             'MyBookingsScreen: Menavigasi ke /rebook_service dengan booking ID: ${booking.id}',
                                //           );
                                //         }
                                //       } else {
                                //         ScaffoldMessenger.of(
                                //           context,
                                //         ).showSnackBar(
                                //           SnackBar(
                                //             content: Text(
                                //               'Tidak dapat re-book booking berstatus ${booking.status}.',
                                //             ),
                                //             backgroundColor: Colors.orange,
                                //           ),
                                //         );
                                //         debugPrint(
                                //           'MyBookingsScreen: Mencoba re-book non-pending booking. Status: ${booking.status}',
                                //         );
                                //       }
                                //     },
                                //     child: Text(
                                //       'Add Booking', // Mengubah teks tombol agar lebih jelas
                                //       style: TextStyle(
                                //         color:
                                //             (booking.status.toLowerCase() ==
                                //                 'pending')
                                //             ? Colors.red
                                //             : Colors
                                //                   .grey, // Warna tombol disesuaikan
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                // Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Only allow update if status is 'pending' for example
                                      if (booking.status.toLowerCase() ==
                                          'pending') {
                                        // --- Navigate to UpdateBookingScreen, passing the booking item ---
                                        if (mounted) {
                                          context.push(
                                            '/update_booking_detail', // This is the GoRouter path
                                            extra:
                                                booking, // Pass the entire booking item as 'extra'
                                          );
                                          debugPrint(
                                            'MyBookingsScreen: Navigating to /update_booking_detail with booking ID: ${booking.id}',
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Cannot update a ${booking.status} booking.',
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        debugPrint(
                                          'MyBookingsScreen: Attempted to update non-pending booking. Status: ${booking.status}',
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Update Booking',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Typically, delete is allowed for pending or cancelled, but depends on logic
                                      // Let's allow delete for 'pending' or 'cancelled' bookings
                                      if (booking.status.toLowerCase() ==
                                              'pending' ||
                                          booking.status.toLowerCase() ==
                                              'cancelled') {
                                        _showDeleteConfirmationDialog(
                                          booking,
                                        ); // Show confirmation dialog
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Cannot delete a ${booking.status} booking.',
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        debugPrint(
                                          'MyBookingsScreen: Attempted to delete non-eligible booking. Status: ${booking.status}',
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'Cancel Booking',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Text('No data.'),
            ); // Fallback for initial empty state
          },
        ),
      ),
    );
  }
}

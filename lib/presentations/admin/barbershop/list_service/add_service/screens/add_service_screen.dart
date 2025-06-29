import 'package:barbershop2/presentations/admin/barbershop/list_service/booking/models/booking_model.dart';
import 'package:barbershop2/presentations/admin/barbershop/list_service/booking/service/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Untuk navigasi setelah booking
import 'package:shared_preferences/shared_preferences.dart'; // Untuk mendapatkan user ID
import 'package:flutter/foundation.dart'; // Untuk debugPrint
import 'package:intl/intl.dart'; // Untuk format tanggal/waktu

// Impor model dan service yang diperlukan
import 'package:barbershop2/presentations/admin/barbershop/history/history_models/history_model.dart'; // Model BookingHistoryItem
// import 'package:barbershop2/presentations/admin/barbershop/history/service/history_service.dart'; // BookingService (untuk createBooking)
// import 'package:barbershop2/presentations/admin/barbershop/history/add_service/models/add_service_models.dart'; // BookingResponse model

class AddBooking extends StatefulWidget {
  final BookingHistoryItem booking; // Layar ini menerima item booking dari riwayat

  const AddBooking({super.key, required this.booking});

  @override
  State<AddBooking> createState() => _AddBookingState();
}

class _AddBookingState extends State<AddBooking> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;

  // Variabel untuk menyimpan tanggal dan waktu booking yang baru
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Inisialisasi dengan tanggal/waktu saat ini sebagai default untuk booking baru
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();

    debugPrint('AddBooking: Memulai re-booking untuk layanan: ${widget.booking.service.name}');
  }

  // Fungsi untuk menampilkan date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Hanya izinkan tanggal dari hari ini ke depan
      lastDate: DateTime(2026), // Batasi hingga tahun 2026
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      debugPrint('AddBooking: Tanggal baru dipilih: $_selectedDate');
    }
  }

  // Fungsi untuk menampilkan time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
      debugPrint('AddBooking: Waktu baru dipilih: $_selectedTime');
    }
  }

  // Fungsi untuk mengirim permintaan booking baru
  Future<void> _createRebooking() async {
    if (_selectedDate == null || _selectedTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon pilih tanggal dan waktu untuk booking baru Anda.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      debugPrint('AddBooking: Tanggal atau waktu booking baru belum dipilih.');
      return;
    }

    setState(() {
      _isLoading = true; // Set status loading
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id'); // Dapatkan ID pengguna yang login

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('ID pengguna tidak ditemukan. Mohon login ulang.'),
                backgroundColor: Colors.red),
          );
          context.go('/login'); // Arahkan ke halaman login
        }
        debugPrint('AddBooking: User ID null. Tidak dapat melanjutkan re-booking.');
        return;
      }

      // Gabungkan tanggal dan waktu yang dipilih menjadi satu objek DateTime
      final DateTime finalNewBookingTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      debugPrint('AddBooking: Mencoba membuat booking baru untuk layanan ID: ${widget.booking.service.id} untuk User ID: $userId pada $finalNewBookingTime');

      // Panggil metode createBooking dari BookingService
      final BookingResponse response = await _bookingService.createBooking(
        userId: userId,
        serviceId: widget.booking.service.id, // Gunakan ID layanan dari booking lama
        bookingTime: finalNewBookingTime, // Gunakan waktu booking yang baru
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint('AddBooking: Re-booking berhasil! Respons: ${response.message}');
        context.pop(); // Kembali ke MyBookingsScreen
        // Atau context.go('/my_bookings'); // Kembali ke daftar booking dan refresh (jika tidak otomatis refresh)
      }
    } catch (e) {
      debugPrint('AddBooking: Error saat membuat re-booking: $e');
      if (mounted) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Re-booking gagal: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // Nonaktifkan status loading
      });
      debugPrint('AddBooking: Status loading disetel ke false.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal/waktu yang dipilih untuk tampilan UI
    final selectedFormattedDate = _selectedDate == null
        ? 'Belum ada tanggal dipilih'
        : DateFormat('dd MMMM yyyy').format(_selectedDate!.toLocal());
    final selectedFormattedTime = _selectedTime == null
        ? 'Belum ada waktu dipilih'
        : _selectedTime!.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Booking'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detail Layanan yang akan di-re-book
            const Text(
              'Re-booking Service:',
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
                    Text(
                      'Nama Layanan: ${widget.booking.service.name}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Deskripsi: ${widget.booking.service.description}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Harga: Rp${widget.booking.service.price}',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bagian Pemilihan Tanggal Booking Baru
            const Text(
              'Pilih Tanggal Baru:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                'Tanggal: $selectedFormattedDate',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),

            // Bagian Pemilihan Waktu Booking Baru
            const Text(
              'Pilih Waktu Baru:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                'Waktu: $selectedFormattedTime',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 32),

            // Tombol Konfirmasi Re-booking
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createRebooking, // Panggil fungsi re-booking
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
                        'Konfirmasi Re-book',
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
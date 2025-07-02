import 'package:barbershop2/presentations/admin/barbershop/home/history/update/service/update_service.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/history/history_models/history_model.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/history/update/models/update_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Untuk navigasi setelah update

import 'package:intl/intl.dart'; // Untuk pemformatan tanggal

class UpdateBookingScreen extends StatefulWidget {
  final BookingHistoryItem
  booking; // Layar ini menerima data booking untuk diperbarui

  const UpdateBookingScreen({super.key, required this.booking});

  @override
  State<UpdateBookingScreen> createState() => _UpdateBookingScreenState();
}

class _UpdateBookingScreenState extends State<UpdateBookingScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // Controllers/Variabel untuk input formulir
  String? _selectedStatus; // Untuk dropdown status
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Inisialisasi field formulir dengan data booking saat ini
    _selectedStatus = widget.booking.status; // Nilai awal
    _selectedDate = widget.booking.bookingTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.booking.bookingTime);

    debugPrint(
      'UpdateBookingScreen: Menginisialisasi dengan ID booking: ${widget.booking.id}',
    );
    debugPrint(
      'UpdateBookingScreen: Status saat ini: ${widget.booking.status}, Waktu: ${widget.booking.bookingTime}',
    );
  }

  // Fungsi untuk menampilkan pemilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // Izinkan tanggal lalu untuk penjadwalan ulang jika diperlukan
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 2),
      ), // Izinkan hingga 2 tahun ke depan
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      debugPrint('UpdateBookingScreen: Tanggal baru dipilih: $_selectedDate');
    }
  }

  // Fungsi untuk menampilkan pemilih waktu
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
      debugPrint('UpdateBookingScreen: Waktu baru dipilih: $_selectedTime');
    }
  }

  // Fungsi untuk menangani pengiriman pembaruan booking
  Future<void> _updateBooking() async {
    if (_selectedStatus == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mohon pilih status.'), // Diubah
            backgroundColor: Colors.orange,
          ),
        );
      }
      debugPrint('UpdateBookingScreen: Status tidak dipilih.'); // Diubah
      return;
    }

    // Gabungkan tanggal dan waktu
    final DateTime? finalBookingTime =
        (_selectedDate != null && _selectedTime != null)
            ? DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            )
            : null; // Jika salah satu null, kirim null atau tangani sebagai error

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint(
        'UpdateBookingScreen: Mencoba memperbarui booking ID: ${widget.booking.id}', // Diubah
      );
      debugPrint(
        'UpdateBookingScreen: Mengirim status: $_selectedStatus, waktu baru: $finalBookingTime', // Diubah
      );

      // PENTING: Jika API Anda memungkinkan pengiriman bookingTime null, pastikan parameter di ApiService.updateBookingStatus juga nullable (DateTime?)
      final UpdateBookingResponse
      response = await _apiService.updateBookingStatus(
        bookingId: widget.booking.id,
        status: _selectedStatus!,
        // bookingTime: finalBookingTime, // Pastikan ini diaktifkan di ApiService jika ingin mengirim waktu juga
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint(
          'UpdateBookingScreen: Booking berhasil diperbarui! Respons: ${response.message}', // Diubah
        );
        context.pop(); // Pop kembali ke MyBookingsScreen
      }
    } catch (e) {
      debugPrint(
        'UpdateBookingScreen: Error memperbarui booking: $e',
      ); // Diubah
      if (mounted) {
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pembaruan gagal: $errorMessage'), // Diubah
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      debugPrint(
        'UpdateBookingScreen: Status loading diatur ke false.',
      ); // Diubah
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format waktu booking saat ini untuk tampilan
    final currentFormattedTime = DateFormat(
      'EEEE, dd MMMM yyyy, HH:mm', // Ditambah tahun untuk kejelasan
    ).format(widget.booking.bookingTime.toLocal());
    final selectedFormattedDate =
        _selectedDate == null
            ? 'Belum ada tanggal dipilih' // Diubah
            : DateFormat(
              'dd MMMM yyyy',
            ).format(_selectedDate!.toLocal()); // Diubah
    final selectedFormattedTime =
        _selectedTime == null
            ? 'Belum ada waktu dipilih' // Diubah
            : _selectedTime!.format(context);

    // --- LOGIKA STATUS DINAMIS BERDASARKAN ATURAN TRANSISI BACKEND ---
    List<String> allowedStatuses = [];
    String currentStatusLower = widget.booking.status.toLowerCase();

    debugPrint(
      'UpdateBookingScreen: Status booking saat ini (huruf kecil): $currentStatusLower', // Diubah
    );

    // Aturan transisi status yang umum (sesuaikan dengan backend Anda)
    // Menggunakan ejaan 'cancelled' (dua 'l') secara konsisten.
    // Memastikan 'completed' bisa diakses dari 'confirmed'.
    if (currentStatusLower == 'pending') {
      allowedStatuses.addAll(['confirmed', 'cancelled']);
    } else if (currentStatusLower == 'confirmed') {
      allowedStatuses.addAll(['completed', 'cancelled']);
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
      ]);
    }

    // Pastikan status saat ini selalu ada di dropdown (jika belum ada dari logika di atas)
    if (!allowedStatuses.contains(currentStatusLower)) {
      allowedStatuses.add(currentStatusLower);
    }

    // Hapus duplikat dan urutkan untuk tampilan yang lebih baik
    allowedStatuses = allowedStatuses.toSet().toList();
    allowedStatuses.sort();

    debugPrint(
      'UpdateBookingScreen: Status yang diizinkan untuk dropdown: $allowedStatuses', // Diubah
    );
    debugPrint(
      'UpdateBookingScreen: Status yang saat ini dipilih untuk nilai dropdown: $_selectedStatus', // Diubah
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1A2233),
      appBar: AppBar(
        title: const Text('Edit Booking'), // Diubah
        backgroundColor: const Color(0xFF1A2233),
        centerTitle: true,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              // Menggunakan context.canPop() dari go_router
              context.pop(); // Menggunakan context.pop() dari go_router
            } else {
              debugPrint(
                'UpdateBookingScreen: Tidak ada halaman sebelumnya untuk di-pop.', // Diubah
              );
              // Contoh: Jika ini halaman pertama, arahkan ke home atau login
              // context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: const Color(0xFF2B3A4F),
          margin: const EdgeInsets.only(top: 10),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Detail Booking Saat Ini
                const Text(
                  'Detail Booking Saat Ini:', // Diubah
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: const Color(0xFF2B3A4F),
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
                          'Layanan: ${widget.booking.service.name}', // Diubah
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Waktu Saat Ini: $currentFormattedTime', // Diubah
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status Saat Ini: ${widget.booking.status.toUpperCase()}', // Diubah
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

                // Pemilihan Status
                const Text(
                  'Ubah Status:', // Diubah
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Colors.grey.shade600,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Colors.lightBlueAccent,
                        width: 2.0,
                      ),
                    ),
                    labelText: 'Status Baru', // Diubah
                    labelStyle: const TextStyle(color: Colors.white70),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  dropdownColor: const Color(0xFF2B3A4F),
                  icon: const Icon(Icons.arrow_drop_down),
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  items:
                      allowedStatuses.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.toUpperCase(),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                    debugPrint(
                      'UpdateBookingScreen: Status baru dipilih: $_selectedStatus', // Diubah
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Bagian Penjadwalan Ulang
                const Text(
                  'Jadwal Ulang (Opsional):', // Diubah
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.grey),
                  title: Text(
                    'Tanggal: $selectedFormattedDate', // Diubah
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                  ),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.grey),
                  title: Text(
                    'Waktu: $selectedFormattedTime', // Diubah
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                  ),
                  onTap: () => _selectTime(context),
                ),
                const SizedBox(height: 32),

                // Tombol Konfirmasi Pembaruan
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
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
                              'Konfirmasi Pembaruan', // Diubah
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

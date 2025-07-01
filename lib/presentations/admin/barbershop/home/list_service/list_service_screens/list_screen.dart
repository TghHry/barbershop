import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/list_service_service/list_service.dart'; // Adjust path
import 'package:barbershop2/presentations/admin/barbershop/home/list_service/list_service_models/list_service_model.dart'; // Adjust path
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  final ServiceService _serviceService = ServiceService();
  late Future<ServiceListResponse> _servicesFuture;

  // Formatter for currency
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _servicesFuture = _serviceService.getServices();
    debugPrint('ServicesListScreen: Initiating service fetch in initState...');
  }

  // Helper function to safely parse the price
  num _parsePrice(dynamic price) {
    if (price == null) {
      return 0;
    }
    if (price is num) {
      return price;
    }
    if (price is String) {
      // Try to parse the string to a number
      return num.tryParse(price) ?? 0;
    }
    // Default to 0 if the type is unknown
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Layanan Kami'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<ServiceListResponse>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            debugPrint(
              'ServicesListScreen: ConnectionState.waiting - showing CircularProgressIndicator.',
            );
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint(
              'ServicesListScreen: snapshot.hasError - ${snapshot.error}',
            );
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
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _servicesFuture = _serviceService.getServices();
                          debugPrint(
                            'ServicesListScreen: Retrying service fetch on button tap...',
                          );
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final services = snapshot.data!.data;
            debugPrint(
              'ServicesListScreen: Data loaded. Number of services: ${services.length}',
            );

            if (services.isEmpty) {
              return const Center(
                child: Text(
                  'No services available at the moment.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];

                // Safely parse the price before formatting
                final num priceValue = _parsePrice(service.price);

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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Image (if available)
                        if (service.servicePhotoUrl != null &&
                            service.servicePhotoUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              service.servicePhotoUrl, // <-- Hapus '!' di sini
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                  'ServicesListScreen: Image load error for ${service.name}: $error',
                                );
                                return const Icon(
                                  Icons.broken_image,
                                  size: 80,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          )
                        else
                          const Icon(
                            Icons.cut,
                            size: 80,
                            color: Colors.blueGrey,
                          ),

                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // Use the formatter created in initState
                                _currencyFormatter.format(priceValue),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Barber: ${service.employeeName}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                service.description,
                                style: const TextStyle(fontSize: 14),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    debugPrint(
                                      'ServicesListScreen: "Book This Service" tapped for ${service.name}.',
                                    );
                                    if (mounted) {
                                      context.push(
                                        '/booking_service_detail',
                                        extra: service,
                                      );
                                      debugPrint(
                                        'ServicesListScreen: Navigating to /book_service_detail with service: ${service.name}',
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Book This Service'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          // Fallback for when data is null, not an error, and not waiting (e.g., initial state)
          return const Center(
            child: Text('No data.', style: TextStyle(color: Colors.white)),
          );
        },
      ),
    );
  }
}

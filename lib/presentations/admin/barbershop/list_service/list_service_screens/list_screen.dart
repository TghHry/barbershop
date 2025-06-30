import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
// Import your ServiceService and ServiceListResponse models
import 'package:barbershop2/presentations/admin/barbershop/list_service/list_service_service/list_service.dart'; // Adjust path if needed
import 'package:barbershop2/presentations/admin/barbershop/list_service/list_service_models/list_service_model.dart';
import 'package:go_router/go_router.dart'; // Adjust path if needed

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  final ServiceService _serviceService = ServiceService();
  late Future<ServiceListResponse> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture =
        _serviceService.getServices(); // Initiate fetching services
    debugPrint('ServicesListScreen: Initiating service fetch in initState...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Our Services',
          // style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<ServiceListResponse>(
        future: _servicesFuture, // The future we're waiting for
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
                        setState(() {
                          _servicesFuture =
                              _serviceService.getServices(); // Retry fetching
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
            // Data has been successfully loaded
            final services = snapshot.data!.data; // Access the list of services
            debugPrint(
              'ServicesListScreen: Data loaded. Number of services: ${services.length}',
            );

            if (services.isEmpty) {
              return const Center(
                child: Text('No services available at the moment.'),
              );
            }

            // Display the list of services using ListView.builder
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
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
                        if (service.servicePhotoUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              service.servicePhotoUrl,
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
                                ); // Placeholder on error
                              },
                            ),
                          )
                        else
                          const Icon(
                            Icons.cut,
                            size: 80,
                            color: Colors.blueGrey,
                          ), // Placeholder if no URL

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
                                'Price: Rp${service.price}', // Display price
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Barber: ${service.employeeName}', // Display barber name
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                service.description, // Display description
                                style: const TextStyle(fontSize: 14),
                              ),
                              // ... (inside _ServicesListScreenState's build method, within ListView.builder's itemBuilder)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    debugPrint(
                                      'ServicesListScreen: "Book This Service" tapped for ${service.name}.',
                                    );
                                    // --- Navigate to BookingDetailScreen, passing the service object ---
                                    if (mounted) {
                                      context.push(
                                        '/booking_service_detail', // This is the GoRouter path
                                        extra:
                                            service, // Pass the entire service object as 'extra'
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
                              // ...
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
          return const Center(
            child: Text('No data.'),
          ); // Fallback for initial state or empty data
        },
      ),
    );
  }
}

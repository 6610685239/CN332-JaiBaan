import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/reservation_model.dart';
import 'reservation_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Reservation>> _future;

  @override
  void initState() {
    super.initState();
    _future = _apiService.getMyBookings(1);
  }

  void _refresh() {
    setState(() {
      _future = _apiService.getMyBookings(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E9),
      appBar: AppBar(
        title: const Text('ประวัติการจอง',
            style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Reservation>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(
              child: Text('ยังไม่มีประวัติการจอง',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final startLocal = b.startTime.toLocal();
              final endLocal = b.endTime.toLocal();
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReservationDetailPage(reservation: b),
                    ),
                  ).then((_) => _refresh());
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              b.facility?.name ?? 'Unknown Facility',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: b.status == 'CONFIRMED'
                                    ? const Color(0xFFD4EDDA)
                                    : const Color(0xFFFFF3CD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(b.status,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('ID: ${b.bookingCode}',
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 13)),
                        Text(
                          'Date: ${DateFormat('d MMM yyyy').format(startLocal)}',
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13),
                        ),
                        Text(
                          'Time: ${DateFormat('H:mm').format(startLocal)} - ${DateFormat('H:mm').format(endLocal)}',
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13),
                        ),
                        Text('PAX: ${b.pax}',
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 13)),
                        const SizedBox(height: 6),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text('Tap for details →',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black38)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

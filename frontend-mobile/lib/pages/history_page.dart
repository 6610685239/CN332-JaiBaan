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
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: -250,
            left: -250,
            child: Image.asset('assets/images/lpr_bg1.png', width: 700),
          ),
          Positioned(
            bottom: 0,
            left: -100,
            right: -160,
            child: Image.asset('assets/images/lpr_bg2.png', width: double.infinity, height: 220, fit: BoxFit.fill),
          ),
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text(
                  'Booking History',
                  style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 18),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF424242)),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              body: FutureBuilder<List<Reservation>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFF7043), strokeWidth: 2.5),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('เกิดข้อผิดพลาด', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                        ],
                      ),
                    );
                  }
                  final bookings = snapshot.data ?? [];
                  if (bookings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0EE),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(Icons.calendar_today_rounded, size: 36, color: Color(0xFFFF9A8B)),
                          ),
                          const SizedBox(height: 16),
                          const Text('No bookings yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 6),
                          Text('Your reservations will appear here', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: const Color(0xFFFF7043),
                    onRefresh: () async => _refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final b = bookings[index];
                        return _buildCard(context, b);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Reservation b) {
    final startLocal = b.startTime.toLocal();
    final endLocal = b.endTime.toLocal();
    final isConfirmed = b.status == 'CONFIRMED';
    final isCancelled = b.status == 'CANCELLED';

    final statusColor = isConfirmed
        ? const Color(0xFF22C55E)
        : isCancelled
            ? const Color(0xFFEF4444)
            : const Color(0xFF94A3B8);

    final statusBg = isConfirmed
        ? const Color(0xFFDCFCE7)
        : isCancelled
            ? const Color(0xFFFEE2E2)
            : const Color(0xFFF1F5F9);

    final statusIcon = isConfirmed
        ? Icons.check_circle_rounded
        : isCancelled
            ? Icons.cancel_rounded
            : Icons.hourglass_top_rounded;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ReservationDetailPage(reservation: b)),
        ).then((_) => _refresh());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
          ],
          border: Border(
            left: BorderSide(color: statusColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      b.facility?.name ?? 'Unknown Facility',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          b.status,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _infoRow(Icons.confirmation_number_rounded, b.bookingCode),
              const SizedBox(height: 4),
              _infoRow(Icons.calendar_today_rounded, DateFormat('d MMM yyyy').format(startLocal)),
              const SizedBox(height: 4),
              _infoRow(
                Icons.access_time_rounded,
                '${DateFormat('H:mm').format(startLocal)} – ${DateFormat('H:mm').format(endLocal)}',
              ),
              const SizedBox(height: 4),
              _infoRow(Icons.people_alt_rounded, '${b.pax} guests'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('View details', style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFFFF9A8B)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
      ],
    );
  }
}

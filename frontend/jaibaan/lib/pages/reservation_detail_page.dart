import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reservation_model.dart';
import '../services/api_service.dart';

class ReservationDetailPage extends StatefulWidget {
  final Reservation reservation;

  const ReservationDetailPage({super.key, required this.reservation});

  @override
  State<ReservationDetailPage> createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  late Reservation _reservation;
  bool _cancelling = false;
  bool _deleting = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _reservation = widget.reservation;
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Reservation',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Permanently delete this cancelled reservation from your history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await _apiService.deleteBooking(_reservation.id);
      if (!mounted) return;
      Navigator.pop(context); // back to history, which will refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Reservation',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to cancel this reservation? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep', style: TextStyle(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel Reservation',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await _apiService.cancelBooking(_reservation.id);
      if (!mounted) return;
      setState(() {
        _reservation = Reservation(
          id: _reservation.id,
          bookingCode: _reservation.bookingCode,
          residentId: _reservation.residentId,
          facilityId: _reservation.facilityId,
          startTime: _reservation.startTime,
          endTime: _reservation.endTime,
          pax: _reservation.pax,
          status: 'CANCELLED',
          note: _reservation.note,
          createdAt: _reservation.createdAt,
          facility: _reservation.facility,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation cancelled.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel: $e')),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startLocal = _reservation.startTime.toLocal();
    final endLocal = _reservation.endTime.toLocal();
    final formattedDate = DateFormat('d MMMM yyyy').format(startLocal);
    final period =
        '${DateFormat('H:mm').format(startLocal)} - ${DateFormat('H:mm').format(endLocal)}';
    final facilityName = _reservation.facility?.name ?? 'Unknown Facility';
    final isCancelled = _reservation.status == 'CANCELLED';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$formattedDate, $period',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Booking ID',
                      style: TextStyle(fontSize: 16, color: Colors.black54)),
                  Text(_reservation.bookingCode,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8FB),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(facilityName,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                    ),
                    const SizedBox(height: 24),
                    _row('Facility', facilityName),
                    _divider(),
                    _row('Date', formattedDate),
                    _divider(),
                    _row('Time', period),
                    _divider(),
                    _row('PAX', _reservation.pax.toString()),
                    _divider(),
                    _row('Status', _reservation.status),
                    _divider(),
                    _row('Note', _reservation.note ?? 'None'),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'Present the QR to staff to check in facilities',
                style: TextStyle(
                    fontStyle: FontStyle.italic, color: Colors.black54),
              ),
              const SizedBox(height: 16),

              Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=JaiBaanBooking${_reservation.bookingCode}',
                width: 200,
                height: 200,
                errorBuilder: (_, __, ___) => Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                      child:
                          Icon(Icons.qr_code, size: 100, color: Colors.grey)),
                ),
              ),

              const SizedBox(height: 32),

              // Cancel button — hidden once already cancelled
              if (!isCancelled)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _cancelling ? null : _confirmCancel,
                    child: _cancelling
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Cancel Reservation',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),

              // Delete button — only shown when cancelled
              if (isCancelled)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _deleting ? null : _confirmDelete,
                    child: _deleting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Delete from History',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32D74B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Back to Facilities',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, color: Colors.black87)),
        Text(value,
            style: const TextStyle(fontSize: 16, color: Colors.black87)),
      ],
    );
  }

  Widget _divider() =>
      const Divider(color: Colors.white, thickness: 2, height: 24);
}

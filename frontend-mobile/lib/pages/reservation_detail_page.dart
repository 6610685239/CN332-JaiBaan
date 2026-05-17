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

    final isConfirmed = _reservation.status == 'CONFIRMED';
    final statusColor = isConfirmed
        ? const Color(0xFF22C55E)
        : isCancelled
            ? const Color(0xFFEF4444)
            : const Color(0xFF94A3B8);

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
            top: -250, left: -250,
            child: Image.asset('assets/images/lpr_bg1.png', width: 700),
          ),
          Positioned(
            bottom: 0, left: -100, right: -160,
            child: Image.asset('assets/images/lpr_bg2.png', width: double.infinity, height: 220, fit: BoxFit.fill),
          ),
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF424242)),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Reservation Detail',
                  style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Status + booking code
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                        border: Border(left: BorderSide(color: statusColor, width: 4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(facilityName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(_reservation.status,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
                              ),
                              const SizedBox(width: 10),
                              Text(_reservation.bookingCode,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info rows
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          _infoRow(Icons.calendar_today_rounded, 'Date', formattedDate),
                          _divider(),
                          _infoRow(Icons.access_time_rounded, 'Time', period),
                          _divider(),
                          _infoRow(Icons.people_alt_rounded, 'Guests', '${_reservation.pax} people'),
                          _divider(),
                          _infoRow(Icons.sticky_note_2_rounded, 'Note', _reservation.note?.isNotEmpty == true ? _reservation.note! : 'None'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // QR code
                    Text(
                      'Present this QR code to staff at the facility',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Image.network(
                        'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=JaiBaanBooking${_reservation.bookingCode}',
                        width: 180, height: 180,
                        errorBuilder: (_, _, _) => Container(
                          width: 180, height: 180,
                          color: Colors.grey.shade100,
                          child: const Center(child: Icon(Icons.qr_code, size: 80, color: Colors.grey)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Cancel button
                    if (!isCancelled)
                      _actionButton(
                        label: 'Cancel Reservation',
                        icon: Icons.cancel_outlined,
                        color: const Color(0xFFEF4444),
                        loading: _cancelling,
                        onTap: _confirmCancel,
                      ),

                    // Delete button
                    if (isCancelled) ...[
                      _actionButton(
                        label: 'Delete from History',
                        icon: Icons.delete_outline_rounded,
                        color: const Color(0xFF64748B),
                        loading: _deleting,
                        onTap: _confirmDelete,
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (!isCancelled) const SizedBox(height: 12),
                    _actionButton(
                      label: 'Back to Facilities',
                      icon: Icons.home_rounded,
                      color: const Color(0xFFFF7043),
                      loading: false,
                      onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFF9A8B)),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 1, color: Colors.grey.shade100);

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: loading ? null : onTap,
        child: loading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}

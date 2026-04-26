import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/facility_model.dart';

class BookingPage extends StatefulWidget {
  final Facility facility;

  const BookingPage({super.key, required this.facility});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final ApiService apiService = ApiService();
  DateTime _selectedDate = DateTime.now();
  String? _selectedPeriod;
  bool isLoading = false;
  int _pax = 1;
  Set<String> _bookedPeriods = {};
  bool _loadingAvailability = false;

  static const List<String> _periods = [
    "9:00 - 11:00",
    "11:00 - 13:00",
    "13:00 - 15:00",
    "15:00 - 17:00",
  ];

  static const Map<int, String> _hourToPeriod = {
    9: "9:00 - 11:00",
    11: "11:00 - 13:00",
    13: "13:00 - 15:00",
    15: "15:00 - 17:00",
  };

  @override
  void initState() {
    super.initState();
    _loadAvailability(_selectedDate);
  }

  Future<void> _loadAvailability(DateTime date) async {
    setState(() => _loadingAvailability = true);
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final bookings =
          await apiService.getFacilityBookings(widget.facility.id, dateStr);
      final Set<String> booked = {};
      for (final b in bookings) {
        final startTime = DateTime.parse(b['startTime']).toLocal();
        final period = _hourToPeriod[startTime.hour];
        if (period != null) booked.add(period);
      }
      if (mounted) setState(() => _bookedPeriods = booked);
    } catch (_) {
      // fail silently — availability check is best-effort
    } finally {
      if (mounted) setState(() => _loadingAvailability = false);
    }
  }

  Future<void> _bookFacility() async {
    if (_selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a period')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final parts = _selectedPeriod!.split(' - ');
      final startHour = int.parse(parts[0].split(':')[0]);
      final endHour = int.parse(parts[1].split(':')[0]);

      final startDateTime = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, startHour,
      );
      final endDateTime = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, endHour,
      );

      await apiService.bookFacility({
        'residentId': 1,
        'facilityId': widget.facility.id,
        'startTime': startDateTime.toIso8601String(),
        'endTime': endDateTime.toIso8601String(),
        'pax': _pax,
      });

      if (!mounted) return;
      _showSuccessDialog();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(
            child: Text("Booking Confirmed",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          content: const Text(
            "Reservation has been successfully made.\nView it in your booking history.",
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // close dialog
                  Navigator.of(context).pop(); // back to facility list
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int get _minPax => widget.facility.capacityMin ?? 1;
  int get _maxPax => widget.facility.capacityMax ?? 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Facilities",
            style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text("Reservation",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87)),
              const SizedBox(height: 8),
              Text("Facilities: ${widget.facility.name}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
              const SizedBox(height: 24),

              // ── Calendar ──
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Select a date:",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5))
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: CalendarDatePicker(
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateChanged: (DateTime newDate) {
                    setState(() {
                      _selectedDate = newDate;
                      _selectedPeriod = null;
                      _bookedPeriods = {};
                    });
                    _loadAvailability(newDate);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // ── Time slots ──
              Row(
                children: [
                  const Text("Select a period:",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87)),
                  if (_loadingAvailability) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ]
                ],
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10)
                  ],
                ),
                child: Column(
                  children: _periods.map((period) {
                    final isBooked = _bookedPeriods.contains(period);
                    final isSelected = _selectedPeriod == period;
                    return InkWell(
                      onTap: isBooked
                          ? null
                          : () => setState(() => _selectedPeriod = period),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isBooked
                              ? Colors.grey.shade200
                              : isSelected
                                  ? const Color(0xFFFDC5A2)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              period,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isBooked
                                    ? Colors.grey
                                    : isSelected
                                        ? Colors.white
                                        : Colors.black87,
                              ),
                            ),
                            if (isBooked) ...[
                              const SizedBox(width: 8),
                              const Text("Unavailable",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ]
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // ── PAX selector ──
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Number of guests (PAX):",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87)),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10)
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 32),
                      color: _pax > _minPax ? Colors.black87 : Colors.grey,
                      onPressed: _pax > _minPax
                          ? () => setState(() => _pax--)
                          : null,
                    ),
                    const SizedBox(width: 24),
                    Text('$_pax',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 24),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 32),
                      color: _pax < _maxPax ? Colors.black87 : Colors.grey,
                      onPressed: _pax < _maxPax
                          ? () => setState(() => _pax++)
                          : null,
                    ),
                  ],
                ),
              ),
              Text(
                'Max capacity: $_maxPax',
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
              const SizedBox(height: 32),

              // ── Confirm button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAFDCE6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                  onPressed: isLoading ? null : _bookFacility,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.blueGrey),
                        )
                      : const Text("Confirm Reservation",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

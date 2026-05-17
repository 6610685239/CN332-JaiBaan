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
      // fail silently
    } finally {
      if (mounted) setState(() => _loadingAvailability = false);
    }
  }

  Future<void> _bookFacility() async {
    if (_selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time period')),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF9A8B), Color(0xFFFF6B6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your reservation has been made.\nCheck your booking history for details.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int get _minPax => widget.facility.capacityMin ?? 1;
  int get _maxPax => widget.facility.capacityMax ?? 20;

  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFFF7043)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
      ],
    );
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
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF424242)),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Facilities',
                    style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700, fontSize: 18)),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Reservation',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.facility.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFFFF7043)),
                    ),
                    const SizedBox(height: 24),

                    // ── Calendar ──
                    _sectionLabel('Select a date', Icons.calendar_month_rounded),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
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
                        Icon(Icons.access_time_rounded, size: 16, color: const Color(0xFFFF7043)),
                        const SizedBox(width: 6),
                        const Text('Select a period',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                        if (_loadingAvailability) ...[
                          const SizedBox(width: 10),
                          const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF7043)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: _periods.asMap().entries.map((entry) {
                          final i = entry.key;
                          final period = entry.value;
                          final isBooked = _bookedPeriods.contains(period);
                          final isSelected = _selectedPeriod == period;
                          final isLast = i == _periods.length - 1;
                          return Column(
                            children: [
                              InkWell(
                                onTap: isBooked ? null : () => setState(() => _selectedPeriod = period),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: isBooked
                                        ? const Color(0xFFF5F5F5)
                                        : isSelected
                                            ? const Color(0xFFFF7043)
                                            : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                            size: 18,
                                            color: isBooked
                                                ? Colors.grey.shade400
                                                : isSelected
                                                    ? Colors.white
                                                    : const Color(0xFFFF7043),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            period,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                              color: isBooked
                                                  ? Colors.grey.shade400
                                                  : isSelected
                                                      ? Colors.white
                                                      : const Color(0xFF1A1A1A),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isBooked)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text('Full', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!isLast) Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── PAX selector ──
                    _sectionLabel('Number of guests', Icons.people_alt_rounded),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded, size: 32),
                            color: _pax > _minPax ? const Color(0xFFFF7043) : Colors.grey.shade300,
                            onPressed: _pax > _minPax ? () => setState(() => _pax--) : null,
                          ),
                          const SizedBox(width: 20),
                          Column(
                            children: [
                              Text('$_pax', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
                              Text('Max $_maxPax', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                            ],
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 32),
                            color: _pax < _maxPax ? const Color(0xFFFF7043) : Colors.grey.shade300,
                            onPressed: _pax < _maxPax ? () => setState(() => _pax++) : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Confirm button ──
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9A8B), Color(0xFFFF6B6B)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B6B).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: isLoading ? null : _bookFacility,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Confirm Reservation',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                        ),
                      ),
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
}

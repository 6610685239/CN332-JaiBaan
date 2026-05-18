import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ── Colours ──────────────────────────────────────────────────────────────────
const _coral      = Color(0xFFFF7B7B);
const _coralLight = Color(0xFFFFD6D0);
const _awaiting   = Color(0xFFEF4444);
const _received   = Color(0xFF22C55E);
const _returned   = Color(0xFF94A3B8);

class ParcelPage extends StatefulWidget {
  const ParcelPage({super.key});

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> {
  List<Map<String, dynamic>> _parcels = [];
  bool   _isLoading    = true;
  String? _errorMessage;
  String? _token;

  // Tab  ─── 'ARRIVED' | 'PICKED_UP' | 'RETURNED'
  String  _selectedTab    = 'ARRIVED';
  // Filter
  String?  _filterCarrier;
  DateTime? _filterFrom;
  DateTime? _filterTo;

  String get _baseUrl {
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return 'http://localhost:3000/api';
    }
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

  // ── Derived ───────────────────────────────────────────────────────────────
  List<String> get _uniqueCarriers => _parcels
      .map((p) => p['carrier'] as String? ?? '')
      .where((c) => c.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  bool get _hasFilter =>
      _filterCarrier != null || _filterFrom != null || _filterTo != null;

  int _countByStatus(String s) =>
      _parcels.where((p) => p['status'] == s).length;

  List<Map<String, dynamic>> get _filtered {
    return _parcels.where((p) {
      if (p['status'] != _selectedTab) return false;
      if (_filterCarrier != null && p['carrier'] != _filterCarrier) return false;
      if (_filterFrom != null || _filterTo != null) {
        final raw = p['arrivedAt'];
        if (raw == null) return false;
        try {
          final dt = DateTime.parse(raw.toString()).toLocal();
          if (_filterFrom != null && dt.isBefore(_filterFrom!)) return false;
          if (_filterTo != null &&
              dt.isAfter(_filterTo!.add(const Duration(days: 1)))) return false;
        } catch (_) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadParcels();
  }

  Future<void> _loadParcels() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      if (_token == null) {
        setState(() { _errorMessage = 'กรุณาเข้าสู่ระบบก่อน'; _isLoading = false; });
        return;
      }
      final resp = await http.get(
        Uri.parse('$_baseUrl/parcels/my'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          _parcels   = List<Map<String, dynamic>>.from(body['data'] as List? ?? []);
          _isLoading = false;
        });
      } else {
        setState(() { _errorMessage = 'โหลดข้อมูลไม่สำเร็จ (${resp.statusCode})'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: $e'; _isLoading = false; });
    }
  }

  // ── Photo lightbox ────────────────────────────────────────────────────────
  void _showPhotoFullScreen(String url) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (_, _, _) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.network(url, fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                          Icons.broken_image_outlined, color: Colors.white54, size: 60)),
                  ),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> _notAccept(int parcelId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ไม่รับพัสดุ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('ยืนยันว่าคุณต้องการปฏิเสธพัสดุนี้?\nพัสดุจะถูกส่งคืนผู้ส่ง'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ไม่รับพัสดุ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _patchParcel(parcelId, 'return', 'บันทึกการปฏิเสธพัสดุแล้ว');
  }

  Future<void> _confirmPickup(int parcelId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ยืนยันการรับพัสดุ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('ยืนยันว่าคุณได้รับพัสดุนี้แล้วใช่ไหม?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _coral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ยืนยัน', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _patchParcel(parcelId, 'pickup', 'ยืนยันการรับพัสดุสำเร็จ',
        successColor: const Color(0xFF15803D));
  }

  Future<void> _patchParcel(int parcelId, String action, String successMsg,
      {Color successColor = Colors.grey}) async {
    try {
      final resp = await http.patch(
        Uri.parse('$_baseUrl/parcels/$parcelId/$action'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      if (!mounted) return;
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(successMsg), backgroundColor: successColor));
        _loadParcels();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่'),
                backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ไม่สามารถเชื่อมต่อได้: $e'), backgroundColor: Colors.red));
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F6),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _BlobBgPainter())),
          Column(
            children: [
              _buildTabRow(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: _coral))
                    : _errorMessage != null
                        ? _buildError()
                        : RefreshIndicator(
                            onRefresh: _loadParcels,
                            color: _coral,
                            child: _filtered.isEmpty ? _buildEmpty() : _buildList(),
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF424242)),
      onPressed: () => Navigator.of(context).maybePop(),
    ),
    title: const Text(
      'Package Checking',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.history_rounded, color: Color(0xFF424242), size: 24),
        onPressed: _loadParcels,
        tooltip: 'รีเฟรช',
      ),
      const SizedBox(width: 4),
    ],
  );

  // ── Tab row ───────────────────────────────────────────────────────────────
  Widget _buildTabRow() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                _segTab('ARRIVED',   'Awaiting', _awaiting),
                _segTab('PICKED_UP', 'Received', _received),
                _segTab('RETURNED',  'Returned', _returned),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _filterBtn(),
      ],
    ),
  );

  Widget _segTab(String key, String label, Color activeColor) {
    final isActive = _selectedTab == key;
    final count    = _countByStatus(key);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : const Color(0xFF9E9E9E),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white.withValues(alpha: 0.28) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterBtn() => GestureDetector(
    onTap: _showFilterSheet,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: _hasFilter ? _coral : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Icon(Icons.tune_rounded,
          color: _hasFilter ? Colors.white : const Color(0xFF757575), size: 22),
    ),
  );

  // ── Filter sheet ──────────────────────────────────────────────────────────
  void _showFilterSheet() {
    String?   tmpCarrier = _filterCarrier;
    DateTime? tmpFrom    = _filterFrom;
    DateTime? tmpTo      = _filterTo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSS) => Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(ctx).padding.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
              )),
              Row(
                children: [
                  const Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setSS(() { tmpCarrier = null; tmpFrom = null; tmpTo = null; }),
                    child: const Text('Clear all', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Carrier', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF424242))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _chip(null, 'All', tmpCarrier, (v) => setSS(() => tmpCarrier = v)),
                  ..._uniqueCarriers.map((c) => _chip(c, c, tmpCarrier, (v) => setSS(() => tmpCarrier = v))),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Date Range', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF424242))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _datePick(ctx, 'From', tmpFrom, (d) => setSS(() => tmpFrom = d))),
                  const SizedBox(width: 10),
                  Expanded(child: _datePick(ctx, 'To',   tmpTo,   (d) => setSS(() => tmpTo   = d))),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() { _filterCarrier = tmpCarrier; _filterFrom = tmpFrom; _filterTo = tmpTo; });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _coral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Apply Filter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String? value, String label, String? current, void Function(String?) onTap) {
    final sel = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? _coral : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: sel ? Colors.white : const Color(0xFF424242))),
      ),
    );
  }

  Widget _datePick(BuildContext ctx, String hint, DateTime? current, void Function(DateTime?) onPick) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: ctx,
          initialDate: current ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (ctx, child) =>
              Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: _coral)), child: child!),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                current != null
                    ? '${current.day} ${_monthShort(current.month)} ${current.year}'
                    : hint,
                style: TextStyle(fontSize: 12, color: current != null ? const Color(0xFF2D3436) : Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (current != null)
              GestureDetector(
                onTap: () => onPick(null),
                child: const Icon(Icons.close, size: 14, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────
  Widget _buildList() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
    itemCount: _filtered.length,
    itemBuilder: (_, i) => _buildCard(_filtered[i]),
  );

  // ── Parcel card ───────────────────────────────────────────────────────────
  Widget _buildCard(Map<String, dynamic> parcel) {
    final status        = parcel['status']        as String;
    final photoUrl      = parcel['photoUrl']       as String?;
    final hasPhoto      = photoUrl != null && photoUrl.isNotEmpty;
    final unitNumber    = parcel['unitNumber']     as String? ?? '';
    final recipientName = parcel['recipientName']  as String?;
    final carrier       = parcel['carrier']        as String? ?? '';
    final tracking      = parcel['trackingNumber'] as String? ?? '';

    final (badgeLabel, badgeColor) = switch (status) {
      'ARRIVED'   => ('Awaiting', _awaiting),
      'PICKED_UP' => ('Received', _received),
      _           => ('Returned', _returned),
    };

    final datePrefix = switch (status) {
      'PICKED_UP' => 'Received',
      'RETURNED'  => 'Returned',
      _           => 'Arrived',
    };
    final dateRaw = status == 'PICKED_UP'
        ? (parcel['pickedUpAt'] ?? parcel['arrivedAt'])
        : parcel['arrivedAt'];

    return GestureDetector(
      onTap: () => _showParcelDetail(parcel),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 78, height: 90,
                  child: hasPhoto
                      ? Image.network(photoUrl, fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholderThumb())
                      : _placeholderThumb(),
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unit + badge row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (unitNumber.isNotEmpty)
                                Text('บ้านเลขที่ $unitNumber',
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
                              if (recipientName != null && recipientName.isNotEmpty)
                                Text(recipientName,
                                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF424242)),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(badgeLabel,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Tracking number
                    Text(tracking,
                        style: const TextStyle(
                            fontSize: 12.5, color: Color(0xFF757575), letterSpacing: 0.3),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    // Carrier + date
                    Row(
                      children: [
                        const Icon(Icons.local_shipping_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(carrier,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF757575)),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Text('$datePrefix: ${_shortDate(dateRaw)}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderThumb() => Container(
    color: const Color(0xFFFDF2F0),
    child: const Center(child: Icon(Icons.inventory_2_outlined, color: _coralLight, size: 28)),
  );

  // ── Detail bottom sheet ───────────────────────────────────────────────────
  void _showParcelDetail(Map<String, dynamic> parcel) {
    final status     = parcel['status']        as String;
    final isArrived  = status == 'ARRIVED';
    final photoUrl   = parcel['photoUrl']      as String?;
    final hasPhoto   = photoUrl != null && photoUrl.isNotEmpty;
    final parcelId   = (parcel['id'] as num).toInt();
    final notes      = parcel['notes']         as String?;
    final storage    = parcel['storageLocation'] as String?;
    final recipientName = parcel['recipientName'] as String?;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasPhoto)
                      GestureDetector(
                        onTap: () => _showPhotoFullScreen(photoUrl),
                        child: Stack(
                          children: [
                            Image.network(photoUrl, height: 220, width: double.infinity, fit: BoxFit.cover,
                              loadingBuilder: (_, child, prog) => prog == null ? child
                                  : Container(height: 220, color: const Color(0xFFFDF2F0),
                                      child: const Center(child: CircularProgressIndicator(color: _coral, strokeWidth: 2))),
                              errorBuilder: (_, _, _) => Container(height: 100, color: const Color(0xFFFDF2F0),
                                  child: const Center(child: Icon(Icons.broken_image_outlined, color: _coralLight, size: 36)))),
                            Positioned(bottom: 8, right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.zoom_in, color: Colors.white, size: 13),
                                  SizedBox(width: 3),
                                  Text('ดูรูป', style: TextStyle(color: Colors.white, fontSize: 11)),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _statusBadge(status),
                              const Spacer(),
                              Text(parcel['carrier'] as String? ?? '',
                                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _detailRow(Icons.qr_code_outlined,       'Tracking',  parcel['trackingNumber'] as String? ?? '—'),
                          if (recipientName != null && recipientName.isNotEmpty)
                            _detailRow(Icons.person_outline,        'ผู้รับ',    recipientName),
                          _detailRow(Icons.home_outlined,           'ห้อง',     parcel['unitNumber']     as String? ?? '—'),
                          _detailRow(Icons.access_time_outlined,    'วันที่รับ', _shortDate(parcel['arrivedAt'])),
                          if (storage != null && storage.isNotEmpty)
                            _detailRow(Icons.location_on_outlined,  'ที่เก็บ',  storage),
                          if (notes != null && notes.isNotEmpty)
                            _detailRow(Icons.notes_outlined,        'หมายเหตุ', notes),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (isArrived) ...[
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(ctx).padding.bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () { Navigator.pop(ctx); _notAccept(parcelId); },
                        icon: const Icon(Icons.cancel_outlined, size: 20),
                        label: const Text('ไม่รับ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () { Navigator.pop(ctx); _confirmPickup(parcelId); },
                        icon: const Icon(Icons.check_circle_outline, size: 22),
                        label: const Text('ยืนยันรับพัสดุ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _coral,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: _coral),
        const SizedBox(width: 8),
        SizedBox(width: 62, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
        Expanded(child: Text(value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF2D3436), fontWeight: FontWeight.w500))),
      ],
    ),
  );

  Widget _statusBadge(String status) {
    const cfg = {
      'ARRIVED':   ('รอรับ',   Color(0xFFFFF3CD), Color(0xFFB45309)),
      'PICKED_UP': ('รับแล้ว', Color(0xFFDCFCE7), Color(0xFF15803D)),
      'RETURNED':  ('คืนแล้ว', Color(0xFFF1F5F9), Color(0xFF94A3B8)),
    };
    final (lbl, bg, fg) = cfg[status] ?? ('—', Color(0xFFF1F5F9), Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(lbl, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  // ── Empty / Error ─────────────────────────────────────────────────────────
  Widget _buildEmpty() => ListView(children: [
    const SizedBox(height: 80),
    Center(
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: const Color(0xFFFFD6D0), borderRadius: BorderRadius.circular(22)),
            child: const Icon(Icons.inventory_2_outlined, size: 38, color: _coral),
          ),
          const SizedBox(height: 16),
          const Text('ไม่มีรายการพัสดุ',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
          const SizedBox(height: 6),
          const Text('พัสดุของคุณจะแสดงที่นี่เมื่อมาถึง',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    ),
  ]);

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: _coral),
          const SizedBox(height: 12),
          Text(_errorMessage!, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadParcels,
            style: ElevatedButton.styleFrom(backgroundColor: _coral),
            child: const Text('ลองใหม่', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _shortDate(dynamic raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final h  = dt.hour.toString().padLeft(2, '0');
      final m  = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${_monthShort(dt.month)}, $h:$m';
    } catch (_) { return '—'; }
  }

  String _monthShort(int m) =>
      const ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];
}

// ── Background blob painter ───────────────────────────────────────────────────
class _BlobBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = const Color(0xFFFF9966).withValues(alpha: 0.28)..style = PaintingStyle.fill;
    final path1 = Path()
      ..moveTo(0, size.height * 0.62)
      ..cubicTo(size.width * 0.18, size.height * 0.52,
                size.width * 0.38, size.height * 0.60,
                size.width * 0.42, size.height * 0.78)
      ..cubicTo(size.width * 0.46, size.height * 0.92,
                size.width * 0.22, size.height,
                0, size.height)
      ..close();
    canvas.drawPath(path1, p1);

    final p2 = Paint()..color = const Color(0xFFFFAA88).withValues(alpha: 0.15)..style = PaintingStyle.fill;
    final path2 = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(size.width * 0.22, size.height * 0.70,
                size.width * 0.48, size.height * 0.76,
                size.width * 0.52, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, p2);

    final p3 = Paint()..color = const Color(0xFFFF9966).withValues(alpha: 0.10)..style = PaintingStyle.fill;
    final path3 = Path()
      ..moveTo(size.width, 0)
      ..cubicTo(size.width * 0.80, size.height * 0.05,
                size.width * 0.90, size.height * 0.18,
                size.width, size.height * 0.14)
      ..close();
    canvas.drawPath(path3, p3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

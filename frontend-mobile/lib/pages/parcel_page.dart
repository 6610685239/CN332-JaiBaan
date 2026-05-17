import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ParcelPage extends StatefulWidget {
  const ParcelPage({super.key});

  @override
  State<ParcelPage> createState() => _ParcelPageState();
}

class _ParcelPageState extends State<ParcelPage> {
  List<Map<String, dynamic>> _parcels = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _token;
  String _selectedTab = 'ALL';

  static const _coral      = Color(0xFFFF7B7B);
  static const _coralLight = Color(0xFFFFD6D0);

  String get _baseUrl {
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return 'http://localhost:3000/api';
    }
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

  List<Map<String, dynamic>> get _filteredParcels {
    if (_selectedTab == 'ALL') {
      final arrived = _parcels.where((p) => p['status'] == 'ARRIVED').toList();
      final others  = _parcels.where((p) => p['status'] != 'ARRIVED').toList();
      return [...arrived, ...others];
    }
    return _parcels.where((p) => p['status'] == _selectedTab).toList();
  }

  int _countByStatus(String status) =>
      _parcels.where((p) => p['status'] == status).length;

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
      final response = await http.get(
        Uri.parse('$_baseUrl/parcels/my'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _parcels = List<Map<String, dynamic>>.from(body['data'] as List? ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: $e';
        _isLoading = false;
      });
    }
  }

  // ── Photo lightbox ────────────────────────────────────────────────────────
  void _showPhotoFullScreen(String url) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined, color: Colors.white54, size: 60),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12, right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> _notAccept(int parcelId) async {
    final confirmed = await showDialog<bool>(
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
    if (confirmed != true) return;
    await _patchParcel(parcelId, 'return', 'บันทึกการปฏิเสธพัสดุแล้ว');
  }

  Future<void> _confirmPickup(int parcelId) async {
    final confirmed = await showDialog<bool>(
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
    if (confirmed != true) return;
    await _patchParcel(parcelId, 'pickup', 'ยืนยันการรับพัสดุสำเร็จ',
        successColor: const Color(0xFF15803D));
  }

  Future<void> _patchParcel(int parcelId, String action, String successMsg,
      {Color successColor = Colors.grey}) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/parcels/$parcelId/$action'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMsg), backgroundColor: successColor),
        );
        _loadParcels();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเชื่อมต่อได้: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pendingCount = _countByStatus('ARRIVED');
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DiagonalBgPainter())),
          Column(
            children: [
              _buildTabs(),
              if (!_isLoading && pendingCount > 0) _buildPendingBanner(pendingCount),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: _coral))
                    : _errorMessage != null
                        ? _buildError()
                        : RefreshIndicator(
                            onRefresh: _loadParcels,
                            color: _coral,
                            child: _filteredParcels.isEmpty
                                ? _buildEmpty()
                                : _buildList(),
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: Color(0xFF424242)),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'พัสดุของฉัน',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
          letterSpacing: 0.2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: _coral),
          onPressed: _loadParcels,
          tooltip: 'รีเฟรช',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Pending banner ────────────────────────────────────────────────────────
  Widget _buildPendingBanner(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 253, 227, 182),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color.fromARGB(255, 255, 164, 142), width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_outlined, color: _coral, size: 16),
            const SizedBox(width: 15),
            Text(
              'มีพัสดุรอรับ $count ชิ้น',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB45309),
              ),
            ),
          ],  
        ),
      ),
    );
  }

  // ── Filter tabs (chip style like announcement) ────────────────────────────
  Widget _buildTabs() {
    final tabs = [
      {'key': 'ALL',       'label': 'ทั้งหมด',  'count': _parcels.length},
      {'key': 'ARRIVED',   'label': 'รอรับ',    'count': _countByStatus('ARRIVED')},
      {'key': 'PICKED_UP', 'label': 'รับแล้ว',  'count': _countByStatus('PICKED_UP')},
      {'key': 'RETURNED',  'label': 'คืนแล้ว',  'count': _countByStatus('RETURNED')},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.map((tab) {
            final isActive = _selectedTab == tab['key'];
            final count    = tab['count'] as int;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = tab['key'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: isActive ? _coral : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isActive ? _coral : const Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
                    boxShadow: isActive
                        ? [BoxShadow(
                            color: _coral.withOpacity(0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tab['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : const Color(0xFF757575),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withOpacity(0.25)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────
  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _filteredParcels.length,
      itemBuilder: (context, index) => _buildParcelCard(_filteredParcels[index]),
    );
  }

  // ── Parcel card (compact) ────────────────────────────────────────────────
  Widget _buildParcelCard(Map<String, dynamic> parcel) {
    final status   = parcel['status'] as String;
    final photoUrl = parcel['photoUrl'] as String?;
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    final statusBarColor = switch (status) {
      'ARRIVED'   => const Color(0xFFF59E0B),
      'PICKED_UP' => const Color(0xFF10B981),
      _           => const Color(0xFFCBD5E1),
    };

    return GestureDetector(
      onTap: () => _showParcelDetail(parcel),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFECEA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              // Left status bar
              Container(width: 4, height: 72, color: statusBarColor),
              // Thumbnail
              SizedBox(
                width: 68,
                height: 68,
                child: hasPhoto
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFFDF2F0),
                          child: const Icon(Icons.inventory_2_outlined,
                              color: _coralLight, size: 24),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFFDF2F0),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: _coralLight, size: 24),
                      ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStatusBadge(status),
                          const Spacer(),
                          Text(
                            parcel['carrier'] as String? ?? '',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        parcel['trackingNumber'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDate(parcel['arrivedAt']),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFE0E0E0), size: 18),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Parcel detail bottom sheet ────────────────────────────────────────────
  void _showParcelDetail(Map<String, dynamic> parcel) {
    final status    = parcel['status'] as String;
    final isArrived = status == 'ARRIVED';
    final photoUrl  = parcel['photoUrl'] as String?;
    final hasPhoto  = photoUrl != null && photoUrl.isNotEmpty;
    final parcelId  = (parcel['id'] as num).toInt();
    final notes     = parcel['notes'] as String?;
    final hasNotes  = notes != null && notes.isNotEmpty;
    final storage   = parcel['storageLocation'] as String?;
    final hasStorage = storage != null && storage.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo full-width
                    if (hasPhoto)
                      GestureDetector(
                        onTap: () => _showPhotoFullScreen(photoUrl),
                        child: Stack(
                          children: [
                            Image.network(
                              photoUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) => progress == null
                                  ? child
                                  : Container(
                                      height: 220,
                                      color: const Color(0xFFFDF2F0),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                            color: _coral, strokeWidth: 2),
                                      ),
                                    ),
                              errorBuilder: (_, __, ___) => Container(
                                height: 100,
                                color: const Color(0xFFFDF2F0),
                                child: const Center(
                                  child: Icon(Icons.broken_image_outlined,
                                      color: _coralLight, size: 36),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8, right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.zoom_in,
                                        color: Colors.white, size: 13),
                                    SizedBox(width: 3),
                                    Text('ดูรูป',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Details
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildStatusBadge(status),
                              const Spacer(),
                              Text(
                                parcel['carrier'] as String? ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.qr_code_outlined, 'Tracking',
                              parcel['trackingNumber'] as String? ?? '—'),
                          _buildDetailRow(Icons.access_time_outlined, 'วันที่รับ',
                              _formatDate(parcel['arrivedAt'])),
                          if (hasStorage)
                            _buildDetailRow(
                                Icons.location_on_outlined, 'ที่เก็บ', storage),
                          if (hasNotes)
                            _buildDetailRow(
                                Icons.notes_outlined, 'หมายเหตุ', notes),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Action buttons (ARRIVED only)
            if (isArrived) ...[
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, 12 + MediaQuery.of(ctx).padding.bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _notAccept(parcelId);
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 25),
                        label: const Text('ไม่รับ',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _confirmPickup(parcelId);
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 36),
                        label: const Text('ยืนยันรับพัสดุ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _coral,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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

  // ── Detail row ────────────────────────────────────────────────────────────
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: _coral),
          const SizedBox(width: 8),
          SizedBox(
            width: 62,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2D3436),
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ── Status badge ──────────────────────────────────────────────────────────
  Widget _buildStatusBadge(String status) {
    const config = {
      'ARRIVED':   {'label': 'รอรับ',   'bg': Color(0xFFFFF3CD), 'fg': Color(0xFFB45309)},
      'PICKED_UP': {'label': 'รับแล้ว', 'bg': Color(0xFFDCFCE7), 'fg': Color(0xFF15803D)},
      'RETURNED':  {'label': 'คืนแล้ว', 'bg': Color(0xFFF1F5F9), 'fg': Color(0xFF94A3B8)},
    };
    final c   = config[status];
    final bg  = c?['bg']    as Color?  ?? const Color(0xFFF1F5F9);
    final fg  = c?['fg']    as Color?  ?? Colors.grey;
    final lbl = c?['label'] as String? ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(lbl,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  // ── Empty / Error ─────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6D0),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.inventory_2_outlined, size: 38, color: _coral),
              ),
              const SizedBox(height: 16),
              const Text('ไม่มีรายการพัสดุ',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
              const SizedBox(height: 6),
              const Text('พัสดุของคุณจะแสดงที่นี่เมื่อมาถึง',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: _coral),
            const SizedBox(height: 12),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
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
  }

  // ── Date formatter ────────────────────────────────────────────────────────
  String _formatDate(dynamic raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      const months = ['', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
                      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'];
      return '${dt.day} ${months[dt.month]} ${dt.year + 543}';
    } catch (_) {
      return '—';
    }
  }
}

// ── Diagonal background painter (same style as announcement page) ─────────
class _DiagonalBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF7B7B).withOpacity(0.09)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.45, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.35)
      ..lineTo(size.width * 0.1, size.height * 0.16)
      ..close();

    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = const Color(0xFFFF7B7B).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(size.width * 0.6, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.20)
      ..lineTo(size.width * 0.25, size.height * 0.07)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

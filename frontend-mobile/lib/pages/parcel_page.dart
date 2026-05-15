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

  String get _baseUrl {
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return 'http://localhost:3000/api';
    }
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

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
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          _parcels = List<Map<String, dynamic>>.from(body['data'] as List? ?? []);
          _isLoading = false;
        });
      } else {
        setState(() { _errorMessage = 'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์: $e'; _isLoading = false; });
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
                          Icons.broken_image_outlined,
                          color: Colors.white54,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
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

  // ── Action: not accept (return) ───────────────────────────────────────────
  Future<void> _notAccept(int parcelId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ไม่รับพัสดุ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('ยืนยันว่าคุณต้องการปฏิเสธพัสดุนี้?\nพัสดุจะถูกส่งคืนผู้ส่ง'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
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

  // ── Action: confirm pickup ────────────────────────────────────────────────
  Future<void> _confirmPickup(int parcelId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ยืนยันการรับพัสดุ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('ยืนยันว่าคุณได้รับพัสดุนี้แล้วใช่ไหม?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7B7B),
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

  // ── Shared PATCH helper ───────────────────────────────────────────────────
  Future<void> _patchParcel(int parcelId, String action, String successMsg,
      {Color successColor = Colors.grey}) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/parcels/$parcelId/$action'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMsg), backgroundColor: successColor),
        );
        _loadParcels();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เกิดข้อผิดพลาด กรุณาลองใหม่'), backgroundColor: Colors.red),
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF0E7),
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('My Parcels', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7B7B)))
          : _errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadParcels,
                  color: const Color(0xFFFF7B7B),
                  child: _parcels.isEmpty ? _buildEmpty() : _buildList(),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFFF7B7B)),
            const SizedBox(height: 12),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadParcels,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7B7B)),
              child: const Text('ลองใหม่', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Center(
          child: Column(
            children: [
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6D0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.inventory_2_outlined, size: 44, color: Color(0xFFFF7B7B)),
              ),
              const SizedBox(height: 16),
              const Text('ยังไม่มีพัสดุ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
              const SizedBox(height: 6),
              const Text('พัสดุของคุณจะแสดงที่นี่เมื่อมาถึง',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    final arrived = _parcels.where((p) => p['status'] == 'ARRIVED').toList();
    final others  = _parcels.where((p) => p['status'] != 'ARRIVED').toList();
    final sorted  = [...arrived, ...others];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) => _buildParcelCard(sorted[index]),
    );
  }

  Widget _buildParcelCard(Map<String, dynamic> parcel) {
    final status    = parcel['status'] as String;
    final isArrived = status == 'ARRIVED';
    final photoUrl  = parcel['photoUrl'] as String?;
    final hasPhoto  = photoUrl != null && photoUrl.isNotEmpty;
    // Bug fix: explicit int cast to avoid dynamic type error at PATCH call
    final parcelId  = (parcel['id'] as num).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isArrived
            ? Border.all(color: const Color(0xFFFF7B7B), width: 1.5)
            : Border.all(color: const Color(0xFFFFECEA)),
        boxShadow: [
          BoxShadow(
            color: isArrived
                ? const Color(0x14FF7B7B)
                : const Color(0x0A000000),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Photo ──────────────────────────────────────────────────────
          if (hasPhoto)
            GestureDetector(
              onTap: () => _showPhotoFullScreen(photoUrl!),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      photoUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              height: 160,
                              color: const Color(0xFFFDF2F0),
                              child: const Center(child: CircularProgressIndicator(
                                color: Color(0xFFFF7B7B), strokeWidth: 2)),
                            ),
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  // "tap to expand" hint
                  Positioned(
                    bottom: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('ดูรูป', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge + carrier
                Row(
                  children: [
                    _buildStatusBadge(status),
                    const Spacer(),
                    Text(
                      parcel['carrier'] as String? ?? '',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Tracking number
                Text(
                  parcel['trackingNumber'] as String? ?? '',
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436), letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),

                // Storage location
                if (parcel['storageLocation'] != null &&
                    (parcel['storageLocation'] as String).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          parcel['storageLocation'] as String,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                // Arrived date
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(parcel['arrivedAt']),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),

                // ── Action buttons (ARRIVED only) ─────────────────────
                if (isArrived) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _notAccept(parcelId),
                          icon: const Icon(Icons.cancel_outlined, size: 17),
                          label: const Text('ไม่รับพัสดุ',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmPickup(parcelId),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('ยืนยันรับพัสดุ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7B7B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    const config = {
      'ARRIVED':   {'label': 'รอรับ',   'bg': Color(0xFFFFF3CD), 'fg': Color(0xFFB45309)},
      'PICKED_UP': {'label': 'รับแล้ว', 'bg': Color(0xFFDCFCE7), 'fg': Color(0xFF15803D)},
      'RETURNED':  {'label': 'คืนแล้ว', 'bg': Color(0xFFF1F5F9), 'fg': Color(0xFF94A3B8)},
    };
    final c = config[status];
    final bg  = c?['bg']    as Color?  ?? const Color(0xFFF1F5F9);
    final fg  = c?['fg']    as Color?  ?? Colors.grey;
    final lbl = c?['label'] as String? ?? status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(lbl, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }

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

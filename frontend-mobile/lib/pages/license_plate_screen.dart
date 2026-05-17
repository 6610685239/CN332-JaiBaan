import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'lpr_scanner_screen.dart';

const String _baseUrl = 'http://10.0.2.2:3000/api/vehicles';

const List<String> _thaiProvinces = [
  'กรุงเทพมหานคร', 'กระบี่', 'กาญจนบุรี', 'กาฬสินธุ์', 'กำแพงเพชร',
  'ขอนแก่น', 'จันทบุรี', 'ฉะเชิงเทรา', 'ชลบุรี', 'ชัยนาท',
  'ชัยภูมิ', 'ชุมพร', 'เชียงราย', 'เชียงใหม่', 'ตรัง',
  'ตราด', 'ตาก', 'นครนายก', 'นครปฐม', 'นครพนม',
  'นครราชสีมา', 'นครศรีธรรมราช', 'นครสวรรค์', 'นนทบุรี', 'นราธิวาส',
  'น่าน', 'บึงกาฬ', 'บุรีรัมย์', 'ปทุมธานี', 'ประจวบคีรีขันธ์',
  'ปราจีนบุรี', 'ปัตตานี', 'พระนครศรีอยุธยา', 'พะเยา', 'พังงา',
  'พัทลุง', 'พิจิตร', 'พิษณุโลก', 'เพชรบุรี', 'เพชรบูรณ์',
  'แพร่', 'ภูเก็ต', 'มหาสารคาม', 'มุกดาหาร', 'แม่ฮ่องสอน',
  'ยโสธร', 'ยะลา', 'ร้อยเอ็ด', 'ระนอง', 'ระยอง',
  'ราชบุรี', 'ลพบุรี', 'ลำปาง', 'ลำพูน', 'เลย',
  'ศรีสะเกษ', 'สกลนคร', 'สงขลา', 'สตูล', 'สมุทรปราการ',
  'สมุทรสงคราม', 'สมุทรสาคร', 'สระแก้ว', 'สระบุรี', 'สิงห์บุรี',
  'สุโขทัย', 'สุพรรณบุรี', 'สุราษฎร์ธานี', 'สุรินทร์', 'หนองคาย',
  'หนองบัวลำภู', 'อ่างทอง', 'อำนาจเจริญ', 'อุดรธานี', 'อุตรดิตถ์',
  'อุทัยธานี', 'อุบลราชธานี',
];

Future<String?> showProvincePicker(BuildContext context) {
  final searchCtrl = TextEditingController();
  List<String> filtered = List.from(_thaiProvinces);

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.92,
            minChildSize: 0.4,
            builder: (_, scrollCtrl) => Column(
              children: [
                // handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Select Province', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search province...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFE8845C)),
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE8845C), width: 1.5),
                      ),
                    ),
                    onChanged: (q) {
                      setModalState(() {
                        filtered = _thaiProvinces
                            .where((p) => p.contains(q))
                            .toList();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => ListTile(
                      title: Text(filtered[i]),
                      onTap: () => Navigator.pop(ctx, filtered[i]),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// ── Shared shimmer animation ─────────────────────────────────────────────────
class _ShimmerScope extends InheritedWidget {
  final Animation<double> animation;
  const _ShimmerScope({required this.animation, required super.child});

  static Animation<double> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ShimmerScope>()!.animation;

  @override
  bool updateShouldNotify(_ShimmerScope old) => false;
}

class _Shimmer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _Shimmer({required this.width, required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    final anim = _ShimmerScope.of(context);
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(anim.value),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}


// ── Main screen ─────────────────────────────────────────────────────────────
class LicensePlateScreen extends StatefulWidget {
  const LicensePlateScreen({super.key});

  @override
  State<LicensePlateScreen> createState() => _LicensePlateScreenState();
}

class _LicensePlateScreenState extends State<LicensePlateScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _visitorPasses = [];
  bool _loading = true;

  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  final _residentPlateCtrl = TextEditingController();
  final _visitorPlateCtrl = TextEditingController();
  String? _residentProvince;
  String? _visitorProvince;

  int _currentNavIndex = 0;
  int _registerTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _shimmerAnim = Tween(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _residentPlateCtrl.dispose();
    _visitorPlateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$_baseUrl?residentId=1')),
        http.get(Uri.parse('$_baseUrl/visitor-passes?residentId=1')),
      ]);
      final vDecoded = json.decode(results[0].body);
      final pDecoded = json.decode(results[1].body);
      if (mounted) {
        setState(() {
          _vehicles = vDecoded is List ? List<Map<String, dynamic>>.from(vDecoded) : [];
          _visitorPasses = pDecoded is List ? List<Map<String, dynamic>>.from(pDecoded) : [];
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveVehicle(String plate, String province, String type) async {
    try {
      final url = type == 'visitor'
          ? Uri.parse('$_baseUrl/visitor-passes')
          : Uri.parse(_baseUrl);
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'plate': plate, 'province': province, 'residentId': 1}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _showSnack('Vehicle registered successfully!');
        await Future.delayed(const Duration(seconds: 2));
        await _loadData();
      } else {
        _showSnack('Failed to register vehicle', isError: true);
      }
    } catch (_) {
      _showSnack('Network error', isError: true);
    }
  }

  Future<void> _deleteVehicle(Map<String, dynamic> vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8845C).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: Color(0xFFE8845C), size: 36),
              ),
              const SizedBox(height: 16),
              const Text(
                'Remove Vehicle?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to remove',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8845C).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      vehicle['plate'] ?? '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: Color(0xFFE8845C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle['province'] ?? '',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE8845C)),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFFE8845C), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE8845C),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      final res = await http.delete(Uri.parse('$_baseUrl/${vehicle['id']}'));
      if (res.statusCode == 200) {
        _showSnack('Vehicle removed');
        await Future.delayed(const Duration(seconds: 1));
        await _loadData();
      } else {
        _showSnack('Failed to delete', isError: true);
      }
    } catch (_) {
      _showSnack('Network error', isError: true);
    }
  }

  Future<void> _deleteVisitorPass(Map<String, dynamic> pass) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8845C).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline, color: Color(0xFFE8845C), size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Remove Visitor Pass?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              Text('Are you sure you want to remove', style: TextStyle(fontSize: 13, color: Colors.grey.shade500), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8845C).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(pass['plate'] ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 3, color: Color(0xFFE8845C))),
                    const SizedBox(height: 2),
                    Text(pass['province'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE8845C)),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFFE8845C), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE8845C),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      final res = await http.delete(Uri.parse('$_baseUrl/visitor-passes/${pass['id']}'));
      if (res.statusCode == 200) {
        _showSnack('Visitor pass removed');
        await Future.delayed(const Duration(seconds: 1));
        await _loadData();
      } else {
        _showSnack('Failed to delete', isError: true);
      }
    } catch (_) {
      _showSnack('Network error', isError: true);
    }
  }

  Future<void> _togglePass(String id, bool isActive) async {
    try {
      final res = await http.patch(
        Uri.parse('$_baseUrl/visitor-passes/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isActive': isActive}),
      );
      if (res.statusCode == 200) {
        await _loadData();
      } else {
        _showSnack('Failed to update pass', isError: true);
      }
    } catch (_) {
      _showSnack('Network error', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF4CAF50),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  String _expiryText(dynamic expiresAt) {
    try {
      final expiry = DateTime.parse(expiresAt.toString()).toLocal();
      final diff = expiry.difference(DateTime.now());
      if (diff.isNegative) return 'Expired';
      if (diff.inHours >= 1) return 'Expires in ${diff.inHours}h ${diff.inMinutes % 60}m';
      return 'Expires in ${diff.inMinutes}m';
    } catch (_) {
      return 'Expires in 48 hours';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // base background
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
            ),
          ),
          // lpr_bg1 top left
          Positioned(
            top: -250,
            left: -250,
            child: Image.asset('assets/images/lpr_bg1.png', width: 700),
          ),
          // lpr_bg2 bottom
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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'License Plate Management',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.history, color: Colors.black87),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (i) => setState(() => _currentNavIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFE8845C),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Facilities'),
            BottomNavigationBarItem(icon: Icon(Icons.phone_rounded), label: 'Call JumNC'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
          ],
        ),
        body: RefreshIndicator(
          color: const Color(0xFFE8845C),
          onRefresh: _loadData,
          child: _loading
              ? _ShimmerScope(
                  animation: _shimmerAnim,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: _buildSkeleton(),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: _buildContent(),
                ),
        ),
      ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSkeleton() {
    return [
      const SizedBox(height: 16),
      // section 1 header
      _skeletonSectionHeader(),
      const SizedBox(height: 12),
      _skeletonVehicleCard(),
      _skeletonVehicleCard(),
      const SizedBox(height: 28),
      // section 2 header
      _skeletonSectionHeader(),
      const SizedBox(height: 12),
      _skeletonVisitorCardFull(),
      _skeletonVisitorCardFull(),
      const SizedBox(height: 28),
      // register form skeleton
      _skeletonRegisterForm(),
    ];
  }

  Widget _skeletonSectionHeader() {
    return Row(
      children: [
        _Shimmer(width: 32, height: 32, radius: 8),
        const SizedBox(width: 10),
        _Shimmer(width: 180, height: 14),
        const Spacer(),
        _Shimmer(width: 32, height: 24, radius: 20),
      ],
    );
  }

  Widget _skeletonVehicleCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          _Shimmer(width: 26, height: 26, radius: 4),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Shimmer(width: 110, height: 14),
                const SizedBox(height: 6),
                _Shimmer(width: 75, height: 11),
              ],
            ),
          ),
          _Shimmer(width: 54, height: 26, radius: 20),
          const SizedBox(width: 10),
          _Shimmer(width: 22, height: 22, radius: 4),
        ],
      ),
    );
  }

  Widget _skeletonVisitorCardFull() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Shimmer(width: 130, height: 14),
                const SizedBox(height: 6),
                _Shimmer(width: 90, height: 11),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Shimmer(width: 80, height: 14),
              const SizedBox(height: 6),
              _Shimmer(width: 55, height: 11),
            ],
          ),
          const SizedBox(width: 6),
          _Shimmer(width: 44, height: 26, radius: 13),
          const SizedBox(width: 8),
          _Shimmer(width: 22, height: 22, radius: 4),
        ],
      ),
    );
  }

  Widget _skeletonRegisterForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // tab switcher skeleton
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(child: _Shimmer(width: double.infinity, height: 38, radius: 10)),
                const SizedBox(width: 6),
                Expanded(child: _Shimmer(width: double.infinity, height: 38, radius: 10)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Shimmer(width: double.infinity, height: 52, radius: 10),
          const SizedBox(height: 10),
          _Shimmer(width: double.infinity, height: 52, radius: 10),
          const SizedBox(height: 14),
          _Shimmer(width: double.infinity, height: 48, radius: 10),
        ],
      ),
    );
  }

  List<Widget> _buildContent() {
    return [
      const SizedBox(height: 8),
      _sectionHeader(icon: Icons.directions_car, title: 'Your Registered Vehicles', count: _vehicles.length, iconColor: const Color(0xFF5B8BDF)),
      const SizedBox(height: 8),
      _vehicles.isEmpty
          ? _emptyState('No registered vehicles yet')
          : Column(children: _vehicles.map(_buildVehicleCard).toList()),
      const SizedBox(height: 24),
      _sectionHeader(icon: Icons.badge_rounded, title: 'Visitor Pass', count: _visitorPasses.length),
      const SizedBox(height: 8),
      _visitorPasses.isEmpty
          ? _emptyState('No visitor passes yet')
          : Column(children: _visitorPasses.map(_buildVisitorPassCard).toList()),
      const SizedBox(height: 24),
      // tab switcher
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            // tab bar
            Padding(
              padding: const EdgeInsets.all(6),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _registerTab(0, Icons.person_rounded, 'Resident'),
                    _registerTab(1, Icons.group_rounded, 'Visitor'),
                  ],
                ),
              ),
            ),
            // form content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _registerTabIndex == 0
                    ? _registerForm(
                        key: const ValueKey('resident'),
                        plateCtrl: _residentPlateCtrl,
                        selectedProvince: _residentProvince,
                        onProvinceSelected: (p) => setState(() => _residentProvince = p),
                        type: 'resident',
                      )
                    : _registerForm(
                        key: const ValueKey('visitor'),
                        plateCtrl: _visitorPlateCtrl,
                        selectedProvince: _visitorProvince,
                        onProvinceSelected: (p) => setState(() => _visitorProvince = p),
                        type: 'visitor',
                      ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _sectionHeader({required IconData icon, required String title, required int count, Color? iconColor}) {
    final color = iconColor ?? const Color(0xFFE8845C);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8845C).withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$count', style: const TextStyle(color: Color(0xFFE8845C), fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }

  Widget _emptyState(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text(message, style: const TextStyle(color: Colors.grey))),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: const Icon(Icons.directions_car, color: Color(0xFF5B8BDF)),
        title: Text(v['plate'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(v['province'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Active', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _deleteVehicle(v),
              child: const Icon(Icons.delete_outline, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorPassCard(Map<String, dynamic> p) {
    final isActive = p['isActive'] == true || p['isActive'].toString() == 'true';
    final expiry = _expiryText(p['expiresAt']);
    final isExpired = expiry == 'Expired';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Active Visitor Pass', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            isExpired ? Icons.timer_off_outlined : Icons.timer_outlined,
                            size: 11,
                            color: isExpired ? Colors.red : Colors.grey,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            expiry,
                            style: TextStyle(
                              color: isExpired ? Colors.red : Colors.grey,
                              fontSize: 12,
                              fontWeight: isExpired ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(p['plate'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(p['province'] ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: isActive,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF4CAF50),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade200,
                    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    onChanged: isExpired ? null : (val) => _togglePass(p['id'].toString(), val),
                  ),
                ),
                GestureDetector(
                  onTap: () => _deleteVisitorPass(p),
                  child: const Icon(Icons.delete_outline, color: Colors.grey),
                ),
              ],
            ),
      ),
    );
  }

  Widget _registerTab(int index, IconData icon, String label) {
    final selected = _registerTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _registerTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8845C) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? Colors.white : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _registerForm({
    Key? key,
    required TextEditingController plateCtrl,
    required String? selectedProvince,
    required ValueChanged<String> onProvinceSelected,
    required String type,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: plateCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'License plate number',
                      prefixIcon: const Icon(Icons.directions_car_outlined, color: Color(0xFFE8845C)),
                      suffixIcon: const Icon(Icons.edit, color: Colors.grey, size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE8845C), width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(builder: (_) => const LprScannerScreen()),
                    );
                    if (result != null) plateCtrl.text = result;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8845C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final picked = await showProvincePicker(context);
                if (picked != null) onProvinceSelected(picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(10),
                  border: selectedProvince != null
                      ? Border.all(color: const Color(0xFFE8845C), width: 1.5)
                      : null,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Color(0xFFE8845C), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedProvince ?? 'Select province',
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedProvince != null ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE8845C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Register', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                onPressed: () {
                  if (plateCtrl.text.isNotEmpty && selectedProvince != null) {
                    _saveVehicle(plateCtrl.text.trim(), selectedProvince, type);
                    plateCtrl.clear();
                    if (type == 'resident') setState(() => _residentProvince = null);
                    if (type == 'visitor') setState(() => _visitorProvince = null);
                  } else {
                    _showSnack('Please fill in all fields', isError: true);
                  }
                },
              ),
            ),
      ],
    );
  }
}

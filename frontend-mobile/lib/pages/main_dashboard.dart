import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'jaibaan_background.dart';
import 'login_page.dart';
import 'user_settings_page.dart';
import 'facility_page.dart';
import 'parcel_page.dart';
import 'announcement_list_page.dart';
import 'financial_list_page.dart';
import 'license_plate_screen.dart';

class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({super.key});

  @override
  State<MainDashboardPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainDashboardPage> {
  int _currentAd = 0;
  int _currentNav = 0;
  Timer? _adTimer;

  // ── เปลี่ยนเป็น path รูปแทน ──────────────────────────────────────────────
  final List<String> _adImages = [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'image': 'assets/images/repair.png',
      'label': 'Repair Request',
      'sub': 'Under development',
      'route': 'repair',
    },
    {
      'image': 'assets/images/package.png',
      'label': 'Package Checking',
      'sub': 'Check status of your package',
      'route': 'parcel',
    },
    {
      'image': 'assets/images/annouce.png',
      'label': 'Announcement',
      'sub': 'Announcement from juristic',
      'route': 'announcement',
    },
    {
      'image': 'assets/images/finance.png',
      'label': 'Financial',
      'sub': 'Financial Transparency',
      'route': 'financial',
    },
  ];

  final List<Map<String, dynamic>> _bookings = [
    {
      'name': 'Swimming Pool',
      'time': 'Today, 5:00 PM – 6:00 PM',
      'color': Color(0xFF4A90D9),
      'icon': Icons.pool_rounded,
    },
    {
      'name': 'Sauna',
      'time': 'Jan 31, 10:00 AM – 11:30 AM',
      'color': Color(0xFFC0714F),
      'icon': Icons.hot_tub_rounded,
    },
    {
      'name': 'Tennis Court',
      'time': 'Feb 3, 8:00 AM – 9:00 AM',
      'color': Color(0xFF4A9D6F),
      'icon': Icons.sports_tennis_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAdTimer();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  Future<String?> _getUserToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      return null;
    }
  }

  void _navigateByRoute(String route) async {
    final token = await _getUserToken();
    if (!mounted) return;
    switch (route) {
      case 'repair':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repair Request is under development'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'parcel':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ParcelPage()));
        break;
      case 'announcement':
        Navigator.push(context, MaterialPageRoute(builder: (_) => AnnouncementListPage(token: token)));
        break;
      case 'financial':
        Navigator.push(context, MaterialPageRoute(builder: (_) => FinancialListPage(token: token)));
        break;
    }
  }

  void _navigateToSettings() async {
    final token = await _getUserToken();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildSettingsSheet(ctx, token),
    );
  }

  Widget _buildSettingsSheet(BuildContext ctx, String? token) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 16),
          // Account Settings
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: const Color(0xFFFFF5F3),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF4D2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.manage_accounts_rounded, color: Colors.white, size: 22),
            ),
            title: const Text('Account Settings',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
            subtitle: const Text('Profile, password & preferences',
                style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFAAAAAA)),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserSettingsPage(token: token)),
              );
            },
          ),
          const SizedBox(height: 12),
          // Logout
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            tileColor: const Color(0xFFFFF0F0),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDDDD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFFF4D2E), size: 22),
            ),
            title: const Text('Logout',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFFF4D2E))),
            subtitle: const Text('Sign out of your account',
                style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
            onTap: () {
              Navigator.pop(ctx);
              _handleLogout();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _startAdTimer() {
    _adTimer?.cancel();
    _adTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() => _currentAd = (_currentAd + 1) % _adImages.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return JaiBaanBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildAdBanner(),
                    const SizedBox(height: 14),
                    _buildLicensePlateCard(),
                    const SizedBox(height: 14),
                    _buildMenuGrid(),
                    const SizedBox(height: 20),
                    // _buildMyBooking(),
                    // const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.notifications_outlined, size: 20, color: Color(0xFF555555)),
          ),
          Image.asset(
            'assets/images/logo.png',
            height: 42,
            fit: BoxFit.fitHeight,
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF4D2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF4D2E).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ── Ad Banner ────────────────────────────────────────────────────────────
  Widget _buildAdBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Banner image with swipe gesture
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                setState(() => _currentAd = (_currentAd + 1) % _adImages.length);
              } else if (details.primaryVelocity! > 0) {
                setState(() => _currentAd = (_currentAd - 1 + _adImages.length) % _adImages.length);
              }
              _startAdTimer();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: Image.asset(
                  _adImages[_currentAd],
                  key: ValueKey(_currentAd),
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _adImages.length,
              (i) => GestureDetector(
                onTap: () => setState(() => _currentAd = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentAd == i ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _currentAd == i
                        ? const Color(0xFFFF4D2E)
                        : Colors.grey.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── License Plate Card ───────────────────────────────────────────────────
  Widget _buildLicensePlateCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(3, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Left: text + gradient button ────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'License Plate Recognition',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Add your car / visitors',
                    style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Note : Visitors valid for 3 days only',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color.fromARGB(255, 100, 100, 100),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ── Gradient button with white dots ──────────────────
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LicensePlateScreen()),
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9966), Color(0xFFFF5E62)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                           color: const Color.fromARGB(255, 82, 82, 82).withOpacity(0.6),
                           blurRadius: 0,    
                           offset: const Offset(3, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            ..._buildButtonDots(),
                            const Center(
                              child: Text(
                                'Add your car',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
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
            ),
            const SizedBox(width: 12),
            // ── Right: LPR icon ──────────────────────────────────────────
            Container(
              width: 160,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0EE),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/LPR_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── White dots ───────────────────────────────
  List<Widget> _buildButtonDots() {
    // [left, top, size, opacity]
    final dots = [
      [6.0,   5.0,  9.0,  0.7],
      [20.0,  30.0, 5.0,  0.5],
      [36.0,  12.0, 4.0,  0.6],
      [52.0,  38.0, 11.0, 0.45],
      [70.0,  7.0,  6.0,  0.6],
      [85.0,  32.0, 4.0,  0.55],
      [100.0, 16.0, 8.0,  0.5],
      [116.0, 40.0, 5.0,  0.6],
      [132.0, 4.0,  10.0, 0.45],
      [148.0, 26.0, 4.0,  0.65],
      [162.0, 42.0, 6.0,  0.5],
      [178.0, 10.0, 5.0,  0.6],
      [192.0, 34.0, 9.0,  0.45],
      [208.0, 6.0,  4.0,  0.65],
      [222.0, 40.0, 7.0,  0.55],
      [236.0, 20.0, 5.0,  0.6],
    ];

    return dots.map((d) => Positioned(
      left: d[0], top: d[1],
      child: Container(
        width: d[2], height: d[2],
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(d[3]),
          shape: BoxShape.circle,
        ),
      ),
    )).toList();
  }

  // ── Menu Grid ────────────────────────────────────────────────────────────
  Widget _buildMenuGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
        children: _menuItems.map((item) => _buildMenuCard(item)).toList(),
      ),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _navigateByRoute(item['route'] as String),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              item['image'] as String,
              width: 65,
              height: 65,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 6),
            // ── Label ─────────────────────────────────────────────────
            Text(
              item['label'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                item['sub'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── My Booking ───────────────────────────────────────────────────────────
  // Widget _buildMyBooking() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 16),
  //         child: Text(
  //           'My Booking',
  //           style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       SizedBox(
  //         height: 160,
  //         child: ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           padding: const EdgeInsets.symmetric(horizontal: 16),
  //           physics: const BouncingScrollPhysics(),
  //           itemCount: _bookings.length,
  //           itemBuilder: (context, i) {
  //             final b = _bookings[i];
  //             return Container(
  //               width: 140,
  //               margin: const EdgeInsets.only(right: 12),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(18),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.08),
  //                     blurRadius: 16,
  //                     offset: const Offset(0, 4),
  //                   ),
  //                 ],
  //               ),
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(18),
  //                 child: Column(
  //                   children: [
  //                     Expanded(
  //                       flex: 5,
  //                       child: Container(
  //                         decoration: BoxDecoration(
  //                           gradient: LinearGradient(
  //                             colors: [
  //                               (b['color'] as Color).withOpacity(0.7),
  //                               b['color'] as Color,
  //                             ],
  //                             begin: Alignment.topLeft,
  //                             end: Alignment.bottomRight,
  //                           ),
  //                         ),
  //                         child: Center(
  //                           child: Icon(b['icon'] as IconData, size: 44, color: Colors.white),
  //                         ),
  //                       ),
  //                     ),
  //                     Expanded(
  //                       flex: 4,
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(10),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //                             Text(
  //                               b['name'] as String,
  //                               style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
  //                             ),
  //                             const SizedBox(height: 3),
  //                             Text(
  //                               b['time'] as String,
  //                               style: const TextStyle(fontSize: 9.5, color: Color(0xFFAAAAAA)),
  //                               maxLines: 2,
  //                               overflow: TextOverflow.ellipsis,
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //       const SizedBox(height: 14),
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         child: GestureDetector(
  //           onTap: () {},
  //           child: Container(
  //             padding: const EdgeInsets.symmetric(vertical: 13),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(14),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.05),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: const Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text('View All',
  //                     style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
  //                 SizedBox(width: 4),
  //                 Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF555555)),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ── Bottom Navigation ────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.apartment_rounded, 'label': 'Facilities'},
      {'icon': Icons.phone_rounded, 'label': 'Call Juristic'},
      {'icon': Icons.settings_rounded, 'label': 'Setting'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (i) {
              final isActive = _currentNav == i;
              return GestureDetector(
                onTap: () {
                  if (i == 1) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => FacilityListScreen()));
                  } else if (i == 3) {
                    _navigateToSettings();
                  } else {
                    setState(() => _currentNav = i);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        navItems[i]['icon'] as IconData,
                        size: 22,
                        color: isActive ? const Color(0xFFFF4D2E) : const Color(0xFFAAAAAA),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        navItems[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? const Color(0xFFFF4D2E) : const Color(0xFFAAAAAA),
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: isActive ? 4 : 0,
                        height: isActive ? 4 : 0,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4D2E),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
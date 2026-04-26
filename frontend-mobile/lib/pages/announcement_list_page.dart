// lib/pages/announcement_list_page.dart
import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../utils/category_colors.dart';
import '../widgets/announcement_item_card.dart';
import '../shared/bottom_nav_bar.dart';
import 'announcement_detail_page.dart';

class AnnouncementListPage extends StatefulWidget {
  final String? token;

  const AnnouncementListPage({
    Key? key,
    this.token,
  }) : super(key: key);

  @override
  State<AnnouncementListPage> createState() => _AnnouncementListPageState();
}

class _AnnouncementListPageState extends State<AnnouncementListPage> {
  late AnnouncementService _service;
  late TextEditingController _searchController;

  List<Announcement> _announcements = [];
  Set<String> _readIds = {};

  String _selectedCategory = 'ALL';
  int _currentPage = 1;
  int _totalPages = 1;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _navIndex = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _service = AnnouncementService();
    _searchController = TextEditingController();
    _scrollController.addListener(_handleScroll);
    _loadReadStatus();
    _loadAnnouncements();
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreAnnouncements();
    }
  }

  Future<void> _loadReadStatus() async {
    try {
      final readIds = await _service.getAllReadIds();
      setState(() => _readIds = readIds);
    } catch (_) {}
  }

  Future<void> _loadAnnouncements({bool isRefresh = false}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (isRefresh) {
        _currentPage = 1;
        _announcements = [];
      }
    });

    try {
      final response = await _service.getAnnouncements(
        category: _selectedCategory == 'ALL' ? null : _selectedCategory,
        search: _searchController.text.trim(),
        page: _currentPage,
        limit: 5,
        token: widget.token,
      );
      setState(() {
        if (isRefresh) {
          _announcements = response.data;
        } else {
          _announcements.addAll(response.data);
        }
        _totalPages = response.pagination.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreAnnouncements() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    try {
      final response = await _service.getAnnouncements(
        category: _selectedCategory == 'ALL' ? null : _selectedCategory,
        search: _searchController.text.trim(),
        page: _currentPage,
        limit: 10,
        token: widget.token,
      );
      setState(() {
        _announcements.addAll(response.data);
        _totalPages = response.pagination.totalPages;
        _isLoadingMore = false;
      });
    } catch (_) {
      setState(() {
        _currentPage--;
        _isLoadingMore = false;
      });
    }
  }

  void _handleCategoryFilter(String category) {
    if (_selectedCategory == category) return;
    setState(() => _selectedCategory = category);
    _loadAnnouncements(isRefresh: true);
  }

  void _handleReadStatusChanged(String id, bool isRead) async {
    if (isRead) {
      await _service.markAsRead(id);
      setState(() => _readIds.add(id));
    }
  }

  void _navigateToDetail(Announcement announcement) {
    Navigator.of(context)
        .push(MaterialPageRoute(
          builder: (_) => AnnouncementDetailPage(
            announcement: announcement,
            token: widget.token,
          ),
        ))
        .then((_) => _loadReadStatus());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      extendBody: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Background diagonal decoration
          _buildBackground(),

          // Content
          RefreshIndicator(
            color: const Color(0xFFFF7043),
            onRefresh: () => _loadAnnouncements(isRefresh: true),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Search bar
                SliverToBoxAdapter(child: _buildSearchBar()),

                // Category filter chips
                SliverToBoxAdapter(child: _buildCategoryFilter()),

                // Error
                if (_errorMessage != null)
                  SliverToBoxAdapter(child: _buildError()),

                // Loading first page
                if (_isLoading && _announcements.isEmpty)
                  SliverToBoxAdapter(child: _buildInitialLoader()),

                // Empty state
                if (!_isLoading && _announcements.isEmpty && _errorMessage == null)
                  SliverToBoxAdapter(child: _buildEmpty()),

                // List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _announcements[index];
                      final isRead = _readIds.contains(item.id);
                      return AnnouncementItemCard(
                        announcement: item,
                        isRead: isRead,
                        onTap: () => _navigateToDetail(item),
                        onReadStatusChanged: (r) =>
                            _handleReadStatusChanged(item.id, r),
                      );
                    },
                    childCount: _announcements.length,
                  ),
                ),

                // Pagination loader
                if (_isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFFFF7043),
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ),

                // Bottom spacing for nav bar
                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: JaiBaanBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Sub-widgets
  // ─────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: Color(0xFF424242)),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Announcement',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _DiagonalBgPainter(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _searchController.text == value) {
                _loadAnnouncements(isRefresh: true);
              }
            });
          },
          style: const TextStyle(fontSize: 14, color: Color(0xFF424242)),
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFFBDBDBD),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFFBDBDBD),
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded,
                        color: Color(0xFFBDBDBD), size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _loadAnnouncements(isRefresh: true);
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = CategoryColors.getAllCategories();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            final color = cat == 'ALL'
                ? const Color(0xFF9E9E9E)
                : CategoryColors.getColor(cat);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _handleCategoryFilter(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? color : const Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cat != 'ALL') ...[
                        Icon(
                          CategoryColors.getIcon(cat),
                          size: 14,
                          color: isSelected ? Colors.white : color,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        CategoryColors.getCategoryLabel(cat),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF757575),
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

  Widget _buildInitialLoader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF7043),
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 14),
          Text(
            'ไม่มีประกาศ',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFE53935), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage ?? '',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFFE53935)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Background painter — diagonal peach shape
// ─────────────────────────────────────────────

class _DiagonalBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF7043).withOpacity(0.10)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.45, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.38)
      ..lineTo(size.width * 0.1, size.height * 0.18)
      ..close();

    canvas.drawPath(path, paint);

    // Second lighter layer
    final paint2 = Paint()
      ..color = const Color(0xFFFF7043).withOpacity(0.06)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(size.width * 0.6, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.22)
      ..lineTo(size.width * 0.25, size.height * 0.08)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

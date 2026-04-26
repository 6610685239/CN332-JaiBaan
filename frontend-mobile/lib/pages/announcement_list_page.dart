// lib/pages/announcement_list_page.dart
import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../utils/category_colors.dart';
import '../widgets/announcement_item_card.dart';
import 'announcement_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  final ScrollController _scrollController = ScrollController();
  bool _showFilterOnScroll = true;

  @override
  void initState() {
    super.initState();
    _service = AnnouncementService();
    _searchController = TextEditingController();
    
    _scrollController.addListener(_handleScroll);
    
    // Load read status and initial data
    _loadReadStatus();
    _loadAnnouncements();
  }

  void _handleScroll() {
    // Check if user scrolled past filter box to hide it
    if (_scrollController.offset > 100 && _showFilterOnScroll) {
      setState(() => _showFilterOnScroll = false);
    } else if (_scrollController.offset <= 100 && !_showFilterOnScroll) {
      setState(() => _showFilterOnScroll = true);
    }
  }

  Future<void> _loadReadStatus() async {
    try {
      final readIds = await _service.getAllReadIds();
      setState(() {
        _readIds = readIds;
      });
    } catch (e) {
      print('Error loading read status: $e');
    }
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
        limit: 10,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage ?? 'Error loading announcements')),
      );
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
    } catch (e) {
      setState(() {
        _currentPage--; // Revert page number on error
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more: ${e.toString()}')),
      );
    }
  }

  void _handleCategoryFilter(String category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
      _loadAnnouncements(isRefresh: true);
    }
  }

  void _handleSearch(String query) {
    _loadAnnouncements(isRefresh: true);
  }

  void _handleReadStatusChanged(String announcementId, bool isRead) async {
    if (isRead) {
      await _service.markAsRead(announcementId);
      setState(() {
        _readIds.add(announcementId);
      });
    }
  }

  void _navigateToDetail(Announcement announcement) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailPage(
          announcement: announcement,
          token: widget.token,
        ),
      ),
    ).then((_) {
      // Refresh read status when returning
      _loadReadStatus();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ประกาศ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadAnnouncements(isRefresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Search bar - always visible
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    // Debounce search
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        _handleSearch(value);
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'ค้นหาประกาศ...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _handleSearch('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),

            // Category filter - shown/hidden based on scroll
            if (_showFilterOnScroll)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: _buildCategoryFilter(),
                ),
              ),

            // Announcements list
            if (_isLoading && _announcements.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (_announcements.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ไม่มีประกาศ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final announcement = _announcements[index];
                    final isRead = _readIds.contains(announcement.id);

                    // Load more when reaching near the end
                    if (index == _announcements.length - 3) {
                      _loadMoreAnnouncements();
                    }

                    return AnnouncementItemCard(
                      announcement: announcement,
                      isRead: isRead,
                      onTap: () => _navigateToDetail(announcement),
                      onReadStatusChanged: (isRead) {
                        _handleReadStatusChanged(announcement.id, isRead);
                      },
                    );
                  },
                  childCount: _announcements.length,
                ),
              ),

            // Loading indicator for pagination
            if (_isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),

            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: _currentPage >= _totalPages ? 32 : 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = CategoryColors.getAllCategories();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ประเภท',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = _selectedCategory == category;
              final categoryColor = category == 'ALL'
                  ? Colors.grey
                  : CategoryColors.getCategory(category).color;

              return FilterChip(
                label: Text(CategoryColors.getCategoryLabel(category)),
                selected: isSelected,
                onSelected: (_) => _handleCategoryFilter(category),
                backgroundColor: Colors.white,
                selectedColor: categoryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? categoryColor : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: isSelected ? categoryColor : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

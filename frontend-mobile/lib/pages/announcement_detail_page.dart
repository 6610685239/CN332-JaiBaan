// lib/pages/announcement_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // เพิ่ม import นี้
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../utils/category_colors.dart';
import 'dart:io';

class AnnouncementDetailPage extends StatefulWidget {
  final Announcement announcement;
  final String? token;

  const AnnouncementDetailPage({
    Key? key,
    required this.announcement,
    this.token,
  }) : super(key: key);

  @override
  State<AnnouncementDetailPage> createState() => _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  late AnnouncementService _service;
  late Announcement _announcement;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service = AnnouncementService();
    _announcement = widget.announcement;

    // Mark as read when detail page is opened
    _service.markAsRead(_announcement.id);

    // Load full detail if needed
    _loadFullDetail();
  }

  Future<void> _loadFullDetail() async {
    setState(() => _isLoading = true);

    try {
      final detail = await _service.getAnnouncementDetail(
        _announcement.id,
        token: widget.token,
      );
      setState(() {
        _announcement = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading announcement: $e')),
        );
      }
    }
  }

  // ฟังก์ชันแปลงวันที่ให้อยู่ในรูปแบบ "26 เม.ย. 2026"
  String _formatThaiDate(DateTime date) {
    final thaiMonths = [
      '',
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    return '${date.day} ${thaiMonths[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final categoryDef = CategoryColors.getCategory(_announcement.category);
    // กำหนดสีหลักที่ใช้ในหน้านี้ (ดึงจากหมวดหมู่ หรือจะใช้สีน้ำตาลเทาตามรูปก็ได้)
    final Color mainThemeColor = categoryDef.color;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // เปลี่ยน AppBar ตรงนี้ครับ 👇
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF424242),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Announcement Detail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // ขอบโค้งมนตามรูป
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // แถบสีเล็กๆ ด้านบนสุดของการ์ด
                      Container(
                        height: 6,
                        color: mainThemeColor.withOpacity(0.8),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Header: Badge หมวดหมู่ และ วันที่
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Badge แคปซูล
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: mainThemeColor.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    CategoryColors.getCategoryLabel(
                                      _announcement.category,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                // วันที่ (ขวาบน)
                                Text(
                                  _formatThaiDate(_announcement.createdAt),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: mainThemeColor.withOpacity(
                                      0.6,
                                    ), // สีข้อความวันที่กลืนไปกับธีม
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // 2. Title
                            Text(
                              _announcement.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C2C2C),
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 3. Rich Text Content (HTML)
                            Html(
                              data: _announcement.content,
                              style: {
                                "body": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                  fontSize: FontSize(15.0),
                                  color: const Color(0xFF555555),
                                  lineHeight: LineHeight(1.6),
                                ),
                                "li": Style(lineHeight: LineHeight(1.6)),
                              },
                            ),

                            // 4. Attachments (ถ้ามี) - ซ่อนไว้ใต้เนื้อหา
                            if (_announcement.attachments.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildAttachments(),
                            ],

                            // 5. วันหมดอายุ (ส่วนท้ายสุด)
                            if (_announcement.expiryDate != null) ...[
                              const SizedBox(height: 24),
                              Divider(color: Colors.grey[200], thickness: 1),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_filled,
                                    size: 16,
                                    color: mainThemeColor.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'หมดอายุ: ${_formatThaiDate(_announcement.expiryDate!)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: mainThemeColor.withOpacity(0.6),
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
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------
  // ส่วนแสดงไฟล์แนบ (คงระบบเดิมไว้แต่ปรับ Padding นิดหน่อย)
  // ---------------------------------------------------------
  Widget _buildAttachments() {
    final imageAttachments = _announcement.attachments
        .where((a) => a.isImage())
        .toList();

    final otherAttachments = _announcement.attachments
        .where((a) => !a.isImage())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageAttachments.isNotEmpty || otherAttachments.isNotEmpty)
          const Text(
            'Attachments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 12),

        if (imageAttachments.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: imageAttachments.length,
            itemBuilder: (context, index) {
              final attachment = imageAttachments[index];
              return GestureDetector(
                onTap: () => _showImageFullscreen(attachment),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                    color: Colors.grey[100],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          attachment.getFullUrl(_getBaseUrl()),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],

        if (otherAttachments.isNotEmpty) ...[
          if (imageAttachments.isNotEmpty) const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: otherAttachments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final attachment = otherAttachments[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFileIcon(attachment.mimeType),
                      size: 24,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attachment.originalName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _formatFileSize(attachment.size),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.download, color: Colors.grey[400], size: 20),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  void _showImageFullscreen(Attachment attachment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                attachment.getFullUrl(_getBaseUrl()),
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String mimeType) {
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (mimeType.contains('word')) return Icons.description_rounded;
    if (mimeType.contains('sheet')) return Icons.table_chart_rounded;
    if (mimeType.contains('presentation')) return Icons.slideshow_rounded;
    return Icons.attach_file_rounded;
  }

  String _getBaseUrl() {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    if (Platform.isIOS) return 'http://localhost:3000';
    return 'http://localhost:3000';
  }
}

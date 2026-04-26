// lib/pages/announcement_detail_page.dart
import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';
import '../utils/category_colors.dart';
import '../widgets/category_badge.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading announcement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = CategoryColors.getCategory(_announcement.category);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียด'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with category badge
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        CategoryBadge(
                          category: _announcement.category,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        
                        // Title
                        Text(
                          _announcement.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Category label and date
                        Row(
                          children: [
                            CategoryBadgeWithLabel(category: _announcement.category),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(_announcement.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HTML content (simple rendering)
                        _buildContent(_announcement.content),
                        
                        // Attachments section
                        if (_announcement.attachments.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'ไฟล์ที่แนบมา',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAttachments(),
                        ],
                        
                        // Published date info
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ข้อมูลเพิ่มเติม',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'ประเภท',
                                CategoryColors.getLabel(_announcement.category),
                              ),
                              _buildInfoRow(
                                'วันที่มีผล',
                                _formatDate(_announcement.effectiveDate),
                              ),
                              if (_announcement.expiryDate != null)
                                _buildInfoRow(
                                  'วันหมดอายุ',
                                  _formatDate(_announcement.expiryDate!),
                                ),
                              _buildInfoRow(
                                'เผยแพร่เมื่อ',
                                _formatDateTime(_announcement.createdAt),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildContent(String htmlContent) {
    // Simple HTML rendering - remove tags and decode entities
    String plainText = htmlContent.replaceAll(RegExp(r'<[^>]*>'), '');
    plainText = plainText
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\n\s*\n'), '\n'); // Remove multiple newlines

    return SelectableText(
      plainText,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[800],
        height: 1.6,
      ),
    );
  }

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
        // Images gallery
        if (imageAttachments.isNotEmpty) ...[
          Text(
            'รูปภาพ (${imageAttachments.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
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
                onTap: () {
                  _showImageFullscreen(attachment);
                },
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
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      // Tap indicator
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
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
        
        // Other attachments
        if (otherAttachments.isNotEmpty) ...[
          if (imageAttachments.isNotEmpty) const SizedBox(height: 16),
          Text(
            'ไฟล์อื่นๆ (${otherAttachments.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: otherAttachments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final attachment = otherAttachments[index];
              return _buildAttachmentTile(attachment);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAttachmentTile(Attachment attachment) {
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
          Icon(
            Icons.download,
            color: Colors.grey[400],
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
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
                  return Center(
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
    // Get the API base URL
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      return 'http://localhost:3000';
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://localhost:3000';
    }
    // Default fallback
    return 'http://localhost:3000';
  }
}

// Helper widget for category badge with label (reused from utils)
class CategoryBadgeWithLabel extends StatelessWidget {
  final String category;

  const CategoryBadgeWithLabel({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = CategoryColors.getCategory(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: categoryColor.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: categoryColor.color.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryColor.icon,
            color: categoryColor.color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            categoryColor.label,
            style: TextStyle(
              color: categoryColor.color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

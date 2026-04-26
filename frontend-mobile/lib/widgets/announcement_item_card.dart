// lib/widgets/announcement_item_card.dart
import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../utils/category_colors.dart';
import 'category_badge.dart';

class AnnouncementItemCard extends StatelessWidget {
  final Announcement announcement;
  final bool isRead;
  final VoidCallback onTap;
  final Function(bool) onReadStatusChanged;

  const AnnouncementItemCard({
    Key? key,
    required this.announcement,
    required this.isRead,
    required this.onTap,
    required this.onReadStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = CategoryColors.getCategory(announcement.category);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isRead ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey[300]! : categoryColor.color.withOpacity(0.5),
          width: isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Mark as read when tapped
            if (!isRead) {
              onReadStatusChanged(true);
            }
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Category badge + Title + Unread indicator
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    CategoryBadge(category: announcement.category, size: 40),
                    const SizedBox(width: 12),
                    
                    // Title and excerpt
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with unread indicator
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  announcement.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                    color: isRead ? Colors.grey[700] : Colors.black87,
                                  ),
                                ),
                              ),
                              // Unread indicator dot
                              if (!isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: BoxDecoration(
                                    color: categoryColor.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          
                          // Excerpt
                          Text(
                            announcement.getExcerpt(length: 80),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Bottom row: Date + Category label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(announcement.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    
                    // Category label
                    CategoryBadgeWithLabel(category: announcement.category),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'ที่แล้ว';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else {
      // Format as date: d/M/yyyy H:mm
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

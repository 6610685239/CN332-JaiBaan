// lib/widgets/announcement_item_card.dart
import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../utils/category_colors.dart';

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
    final category = CategoryColors.getCategory(announcement.category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            elevation: 0,
            child: InkWell(
              onTap: () {
                if (!isRead) onReadStatusChanged(true);
                onTap();
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Category icon circle
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            announcement.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isRead ? FontWeight.w500 : FontWeight.w700,
                              color: isRead
                                  ? const Color(0xFF757575)
                                  : const Color(0xFF1A1A1A),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Excerpt
                          Text(
                            announcement.getExcerpt(length: 70),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Date
                          Text(
                            _formatDate(announcement.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Unread dot — top right corner of card
          if (!isRead)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month]} ${date.year}, $hour:$minute AM';
  }
}

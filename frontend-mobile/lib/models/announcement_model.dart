// lib/models/announcement_model.dart
import 'dart:convert';

class Announcement {
  final String id;
  final String title;
  final String category; // GENERAL, MAINTENANCE, EVENT, FINANCE, URGENT
  final String content; // HTML content
  final String status; // DRAFT, SCHEDULED, PUBLISHED, ARCHIVED
  final DateTime effectiveDate;
  final DateTime? expiryDate;
  final String targetType; // ALL, ZONE, UNIT
  final List<String> targetZones;
  final List<String> targetUnits;
  final List<Attachment> attachments;
  final bool notifSent;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.status,
    required this.effectiveDate,
    this.expiryDate,
    required this.targetType,
    this.targetZones = const [],
    this.targetUnits = const [],
    this.attachments = const [],
    this.notifSent = false,
    this.scheduledAt,
    this.publishedAt,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'GENERAL',
      content: json['content'] ?? '',
      status: json['status'] ?? 'DRAFT',
      effectiveDate: DateTime.parse(json['effectiveDate'] ?? DateTime.now().toIso8601String()),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      targetType: json['targetType'] ?? 'ALL',
      targetZones: List<String>.from(json['targetZones'] ?? []),
      targetUnits: List<String>.from(json['targetUnits'] ?? []),
      attachments: (json['attachments'] as List?)?.map((e) => Attachment.fromJson(e)).toList() ?? [],
      notifSent: json['notifSent'] ?? false,
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : null,
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'status': status,
      'effectiveDate': effectiveDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'targetType': targetType,
      'targetZones': targetZones,
      'targetUnits': targetUnits,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'notifSent': notifSent,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get excerpt (first 100 characters of content, stripped of HTML)
  String getExcerpt({int length = 100}) {
    // Simple HTML tag removal
    String text = content.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode HTML entities
    text = _decodeHtmlEntities(text);
    if (text.length > length) {
      return '${text.substring(0, length)}...';
    }
    return text;
  }

  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }
}

class Attachment {
  final String id;
  final String filename;
  final String originalName;
  final String url;
  final String mimeType;
  final int size;
  final String announcementId;
  final DateTime createdAt;

  Attachment({
    required this.id,
    required this.filename,
    required this.originalName,
    required this.url,
    required this.mimeType,
    required this.size,
    required this.announcementId,
    required this.createdAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      originalName: json['originalName'] ?? '',
      url: json['url'] ?? '',
      mimeType: json['mimeType'] ?? '',
      size: json['size'] ?? 0,
      announcementId: json['announcementId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'originalName': originalName,
      'url': url,
      'mimeType': mimeType,
      'size': size,
      'announcementId': announcementId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Check if attachment is an image
  bool isImage() {
    return mimeType.startsWith('image/');
  }

  // Get full URL for image
  String getFullUrl(String baseUrl) {
    if (url.startsWith('http')) {
      return url;
    }
    return '$baseUrl$url';
  }
}

class AnnouncementListResponse {
  final List<Announcement> data;
  final PaginationInfo pagination;

  AnnouncementListResponse({
    required this.data,
    required this.pagination,
  });

  factory AnnouncementListResponse.fromJson(Map<String, dynamic> json) {
    return AnnouncementListResponse(
      data: (json['data'] as List?)?.map((e) => Announcement.fromJson(e)).toList() ?? [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PaginationInfo {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

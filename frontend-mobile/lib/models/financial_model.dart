class FinancialAttachment {
  final String id;
  final String filename;
  final String originalName;
  final String url;
  final String mimeType;
  final int size;
  final String transactionId;
  final DateTime createdAt;

  FinancialAttachment({
    required this.id,
    required this.filename,
    required this.originalName,
    required this.url,
    required this.mimeType,
    required this.size,
    required this.transactionId,
    required this.createdAt,
  });

  factory FinancialAttachment.fromJson(Map<String, dynamic> json) {
    return FinancialAttachment(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      originalName: json['originalName'] ?? '',
      url: json['url'] ?? '',
      mimeType: json['mimeType'] ?? 'application/octet-stream',
      size: json['size'] ?? 0,
      transactionId: json['transactionId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool isImage() {
    return mimeType.toLowerCase().startsWith('image/');
  }

  String getFullUrl(String baseUrl) {
    if (url.startsWith('http')) return url;
    return '$baseUrl$url';
  }
}

class FinancialTransaction {
  final String id;
  final String type;
  final String category;
  final double amount;
  final String description;
  final DateTime transactionDate;
  final int year;
  final int month;
  final List<FinancialAttachment> attachments;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialTransaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.transactionDate,
    required this.year,
    required this.month,
    this.attachments = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    final amountValue = json['amount'];
    double amount = 0;
    if (amountValue is num) {
      amount = amountValue.toDouble();
    } else if (amountValue is String) {
      amount = double.tryParse(amountValue) ?? 0;
    }

    return FinancialTransaction(
      id: json['id'] ?? '',
      type: json['type'] ?? 'EXPENSE',
      category: json['category'] ?? '',
      amount: amount,
      description: json['description'] ?? '',
      transactionDate: DateTime.parse(json['transactionDate'] ?? DateTime.now().toIso8601String()),
      year: json['year'] ?? DateTime.now().year,
      month: json['month'] ?? DateTime.now().month,
      attachments: (json['attachments'] as List?)
              ?.map((e) => FinancialAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static const Map<String, String> categoryLabels = {
    'COMMON_FEE': 'ค่าส่วนกลาง',
    'RENTAL': 'ค่าเช่าพื้นที่',
    'OTHER_INCOME': 'รายรับอื่นๆ',
    'ELECTRICITY': 'ค่าไฟฟ้าส่วนกลาง',
    'WATER': 'ค่าน้ำ',
    'MAINTENANCE': 'ซ่อมบำรุง',
    'OTHER_EXPENSE': 'รายจ่ายอื่นๆ',
  };

  static const Map<String, String> typeLabels = {
    'INCOME': 'รายรับ',
    'EXPENSE': 'รายจ่าย',
  };

  String get categoryLabel => categoryLabels[category] ?? category;
  String get typeLabel => typeLabels[type] ?? type;

  String get amountLabel {
    final formatted = amount.toStringAsFixed(2);
    return type == 'INCOME' ? '+฿$formatted' : '-฿$formatted';
  }

  String getExcerpt({int length = 80}) {
    final text = description.trim();
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }
}

class FinancialListResponse {
  final List<FinancialTransaction> data;
  final PaginationInfo pagination;

  FinancialListResponse({
    required this.data,
    required this.pagination,
  });

  factory FinancialListResponse.fromJson(Map<String, dynamic> json) {
    return FinancialListResponse(
      data: (json['data'] as List?)
              ?.map((e) => FinancialTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

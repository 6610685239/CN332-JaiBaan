import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../models/financial_model.dart';
import '../services/financial_service.dart';

class FinancialDetailPage extends StatefulWidget {
  final FinancialTransaction transaction;
  final String? token;

  const FinancialDetailPage({
    Key? key,
    required this.transaction,
    this.token,
  }) : super(key: key);

  @override
  State<FinancialDetailPage> createState() => _FinancialDetailPageState();
}

class _FinancialDetailPageState extends State<FinancialDetailPage> {
  late FinancialService _service;
  late FinancialTransaction _transaction;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service = FinancialService();
    _transaction = widget.transaction;
    _loadTransactionDetail();
  }

  Future<void> _loadTransactionDetail() async {
    setState(() => _isLoading = true);
    try {
      final detail = await _service.getTransactionById(
        _transaction.id,
        token: widget.token,
      );
      setState(() {
        _transaction = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transaction: $e')),
        );
      }
    }
  }

  String _formatThaiDate(DateTime date) {
    const thaiMonths = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    return '${date.day} ${thaiMonths[date.month]} ${date.year}';
  }

  Color get _accentColor {
    switch (_transaction.category?.toUpperCase()) {
      case 'COMMON_FEE':   return const Color(0xFF26A69A);
      case 'RENTAL':       return const Color(0xFF42A5F5);
      case 'OTHER_INCOME': return const Color(0xFF66BB6A);
      case 'ELECTRICITY':  return const Color(0xFFFFB300);
      case 'WATER':        return const Color(0xFF29B6F6);
      case 'MAINTENANCE':  return const Color(0xFFFF7043);
      case 'OTHER_EXPENSE':return const Color(0xFF8D6E63);
      default:             return const Color(0xFF9E9E9E);
    }
  }

  IconData get _typeIcon {
    switch (_transaction.category?.toUpperCase()) {
      case 'COMMON_FEE':   return Icons.apartment_rounded;
      case 'RENTAL':       return Icons.key_rounded;
      case 'OTHER_INCOME': return Icons.account_balance_wallet_rounded;
      case 'ELECTRICITY':  return Icons.bolt_rounded;
      case 'WATER':        return Icons.water_drop_rounded;
      case 'MAINTENANCE':  return Icons.build_rounded;
      case 'OTHER_EXPENSE':return Icons.receipt_long_rounded;
      default:             return Icons.attach_money_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
          'Transaction Detail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7043)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 6,
                            color: _accentColor.withOpacity(0.9),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _accentColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(_typeIcon, size: 16, color: _accentColor),
                                          const SizedBox(width: 8),
                                          Text(
                                            _transaction.typeLabel,
                                            style: TextStyle(
                                              color: _accentColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      _formatThaiDate(_transaction.transactionDate),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _accentColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  _transaction.categoryLabel,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _transaction.amountLabel,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: _accentColor,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                const Text(
                                  'รายละเอียด',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _transaction.description.isNotEmpty
                                      ? _transaction.description
                                      : '-',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF4D4D4D),
                                    height: 1.6,
                                  ),
                                ),
                                if (_transaction.attachments.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  const Text(
                                    'ไฟล์แนบ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildAttachments(),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAttachments() {
    final imageAttachments = _transaction.attachments.where((a) => a.isImage()).toList();
    final otherAttachments = _transaction.attachments.where((a) => !a.isImage()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageAttachments.isNotEmpty) ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemCount: imageAttachments.length,
            itemBuilder: (context, index) {
              final attachment = imageAttachments[index];
              return GestureDetector(
                onTap: () => _showImageFullscreen(attachment),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      attachment.getFullUrl(_getBaseUrl()),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: Colors.grey[400],
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        if (otherAttachments.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: otherAttachments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final attachment = otherAttachments[index];
              final isPdf = attachment.mimeType == 'application/pdf' ||
                  attachment.originalName.toLowerCase().endsWith('.pdf');
              return GestureDetector(
                onTap: isPdf ? () => _openPdf(attachment) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isPdf ? const Color.fromARGB(255, 255, 255, 255) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isPdf ? const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4) : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isPdf ? const Color.fromARGB(255, 219, 110, 110).withOpacity(0.15) : Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isPdf ? Icons.picture_as_pdf_rounded : Icons.insert_drive_file_rounded,
                          size: 22,
                          color: isPdf ? const Color(0xFFE65100) : Colors.blueGrey[400],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment.originalName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${attachment.mimeType} • ${_formatFileSize(attachment.size)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isPdf)
                        Icon(Icons.open_in_new_rounded, size: 18, color: Colors.grey[500]),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showImageFullscreen(FinancialAttachment attachment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                attachment.getFullUrl(_getBaseUrl()),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.image_not_supported_rounded, color: Colors.white, size: 48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPdf(FinancialAttachment attachment) async {
    final url = attachment.getFullUrl(_getBaseUrl());
    final fileName = attachment.originalName;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF7043)),
      ),
    );

    try {
      final response = await http.get(Uri.parse(url));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      Navigator.of(context).pop(); // close loading

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PdfViewerPage(
            filePath: file.path,
            title: fileName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเปิดไฟล์ PDF ได้: $e')),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }
}

class _PdfViewerPage extends StatefulWidget {
  final String filePath;
  final String title;

  const _PdfViewerPage({required this.filePath, required this.title});

  @override
  State<_PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<_PdfViewerPage> {
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF424242)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: _isReady && _totalPages > 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'หน้า ${_currentPage + 1} / $_totalPages',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                  ),
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onRender: (pages) => setState(() {
              _totalPages = pages ?? 0;
              _isReady = true;
            }),
            onPageChanged: (page, total) => setState(() {
              _currentPage = page ?? 0;
            }),
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
              );
            },
          ),
          if (!_isReady)
            const Center(child: CircularProgressIndicator(color: Color(0xFFFF7043))),
        ],
      ),
    );
  }
}
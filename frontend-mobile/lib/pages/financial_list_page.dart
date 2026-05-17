import 'package:flutter/material.dart';
import '../models/financial_model.dart';
import '../services/financial_service.dart';
import '../widgets/financial_item_card.dart';
import 'financial_detail_page.dart';

class FinancialListPage extends StatefulWidget {
  final String? token;

  const FinancialListPage({
    Key? key,
    this.token,
  }) : super(key: key);

  @override
  State<FinancialListPage> createState() => _FinancialListPageState();
}

class _FinancialListPageState extends State<FinancialListPage> {
  late FinancialService _service;
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  List<FinancialTransaction> _transactions = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  String? _errorMessage;

  String? _selectedType;
  late int _selectedMonth;
  late int _selectedYear;
  late final List<int> _years;

  @override
  void initState() {
    super.initState();
    _service = FinancialService();
    _searchController = TextEditingController();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _years = List<int>.generate(5, (index) => now.year - index);
    _loadTransactions(page: 1);
  }

  Future<void> _loadTransactions({required int page}) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = page;
      _transactions = [];
    });

    try {
      final response = await _service.getTransactions(
        page: _currentPage,
        limit: 8,
        search: _searchController.text.trim(),
        type: _selectedType,
        month: _selectedMonth,
        year: _selectedYear,
        token: widget.token,
      );
      setState(() {
        _transactions = response.data;
        _totalPages = response.pagination.totalPages;
        _isLoading = false;
      });
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาด: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _navigateToDetail(FinancialTransaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FinancialDetailPage(
          transaction: transaction,
          token: widget.token,
        ),
      ),
    );
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
          'Financial Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFF7043),
        onRefresh: () => _loadTransactions(page: 1),
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 16, bottom: 22),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSearchBar(),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFilterRow(),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildError(),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator(color: Color(0xFFFF7043))),
              ),
            if (!_isLoading && _transactions.isEmpty && _errorMessage == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildEmpty(),
              ),
            ..._transactions.map((transaction) {
              return FinancialItemCard(
                transaction: transaction,
                onTap: () => _navigateToDetail(transaction),
              );
            }).toList(),
            if (!_isLoading && _totalPages > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPagination(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
              _loadTransactions(page: 1);
            }
          });
        },
        style: const TextStyle(fontSize: 14, color: Color(0xFF424242)),
        decoration: InputDecoration(
          hintText: 'ค้นหาด้วยคำอธิบาย',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFFBDBDBD),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFBDBDBD), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Color(0xFFBDBDBD), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _loadTransactions(page: 1);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    const monthNames = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip('ALL', 'ทั้งหมด'),
              _buildTypeChip('INCOME', 'รายรับ'),
              _buildTypeChip('EXPENSE', 'รายจ่าย'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            _buildDropdown<int>(
              value: _selectedMonth,
              items: List.generate(12, (index) {
                final month = index + 1;
                return DropdownMenuItem<int>(
                  value: month,
                  child: Text(monthNames[month]),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMonth = value);
                  _loadTransactions(page: 1);
                }
              },
            ),
            const SizedBox(width: 8),
            _buildDropdown<int>(
              value: _selectedYear,
              items: _years.map((year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text('$year'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedYear = value);
                  _loadTransactions(page: 1);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, String label) {
    final isSelected = _selectedType == type || (type == 'ALL' && _selectedType == null);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFFF7043),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF424242),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      side: BorderSide(
        color: isSelected ? const Color(0xFFFF7043) : const Color(0xFFE0E0E0),
      ),
      onSelected: (_) {
        setState(() {
          _selectedType = type == 'ALL' ? null : type;
        });
        _loadTransactions(page: 1);
      },
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF616161)),
          style: const TextStyle(fontSize: 14, color: Color(0xFF424242)),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        _errorMessage ?? 'เกิดข้อผิดพลาด',
        style: const TextStyle(color: Color(0xFFD32F2F)),
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
            'ไม่พบรายการทางการเงิน',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final pageItems = List<Widget>.generate(_totalPages, (index) {
      final page = index + 1;
      final selected = page == _currentPage;
      return GestureDetector(
        onTap: selected ? null : () => _loadTransactions(page: page),
        child: Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFF7043) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? const Color(0xFFFF7043) : Colors.grey[300]!,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$page',
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey[700],
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () => _loadTransactions(page: _currentPage - 1) : null,
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
            color: _currentPage > 1 ? const Color(0xFFFF7043) : Colors.grey[300],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: pageItems),
          ),
          IconButton(
            onPressed: _currentPage < _totalPages ? () => _loadTransactions(page: _currentPage + 1) : null,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            color: _currentPage < _totalPages ? const Color(0xFFFF7043) : Colors.grey[300],
          ),
        ],
      ),
    );
  }
}

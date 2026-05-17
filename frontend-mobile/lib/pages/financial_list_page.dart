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

  @override
  void initState() {
    super.initState();
    _service = FinancialService();
    _searchController = TextEditingController();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
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
              child: _buildFilterButton(),
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

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: _showFilterSheet,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFF7043)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.tune_rounded, color: Color(0xFFFF7043), size: 20),
            SizedBox(width: 10),
            Text(
              'ตัวกรอง',
              style: TextStyle(
                color: Color(0xFFFF7043),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFFF7043), size: 20),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ตัวกรอง',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.black87),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'ประเภทธุรกรรม',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildTypeChip('ALL', 'ทั้งหมด', onSelected: (selected) {
                              setModalState(() {
                                _selectedType = null;
                              });
                            }),
                            const SizedBox(width: 10),
                            _buildTypeChip('INCOME', 'รายรับ', onSelected: (selected) {
                              setModalState(() {
                                _selectedType = 'INCOME';
                              });
                            }),
                            const SizedBox(width: 10),
                            _buildTypeChip('EXPENSE', 'รายจ่าย', onSelected: (selected) {
                              setModalState(() {
                                _selectedType = 'EXPENSE';
                              });
                            }),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'เดือน',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: _buildMonthDropdown(onChanged: (month) {
                            setModalState(() {
                              _selectedMonth = month;
                            });
                          }),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'ปี',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: _buildYearDropdown(onChanged: (year) {
                            setModalState(() {
                              _selectedYear = year;
                            });
                          }),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0xFFFF7043)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedType = null;
                                    final now = DateTime.now();
                                    _selectedMonth = now.month;
                                    _selectedYear = now.year;
                                  });
                                  setModalState(() {});
                                },
                                child: const Text(
                                  'ล้างทั้งหมด',
                                  style: TextStyle(
                                    color: Color(0xFFFF7043),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF7043),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  _loadTransactions(page: 1);
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'ใช้ตัวกรอง',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTypeChip(String type, String label, {ValueChanged<bool>? onSelected}) {
    final isSelected = _selectedType == type || (type == 'ALL' && _selectedType == null);
    final Color activeColor;
    switch (type) {
      case 'INCOME':
        activeColor = const Color(0xFF43A047); // green
        break;
      case 'EXPENSE':
        activeColor = const Color(0xFFE53935); // red
        break;
      default:
        activeColor = const Color(0xFFFF7043); // orange for ALL
    }
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: activeColor,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF424242),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      side: BorderSide(
        color: isSelected ? activeColor : const Color(0xFFE0E0E0),
      ),
      onSelected: onSelected,
    );
  }

  Widget _buildMonthDropdown({void Function(int month)? onChanged}) {
    const monthNames = [
      '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    return _buildDropdown<int>(
      value: _selectedMonth,
      items: List.generate(12, (i) => i + 1).map((m) {
        return DropdownMenuItem<int>(
          value: m,
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFFFF7043)),
              const SizedBox(width: 8),
              Text(monthNames[m]),
            ],
          ),
        );
      }).toList(),
      onChanged: (selected) {
        if (selected != null) {
          if (onChanged != null) {
            onChanged(selected);
          } else {
            setState(() => _selectedMonth = selected);
            _loadTransactions(page: 1);
          }
        }
      },
    );
  }

  Widget _buildYearDropdown({void Function(int year)? onChanged}) {
    final now = DateTime.now();
    final years = List.generate(10, (i) => now.year - i);
    return _buildDropdown<int>(
      value: _selectedYear,
      items: years.map((y) {
        return DropdownMenuItem<int>(
          value: y,
          child: Text('$y'),
        );
      }).toList(),
      onChanged: (selected) {
        if (selected != null) {
          if (onChanged != null) {
            onChanged(selected);
          } else {
            setState(() => _selectedYear = selected);
            _loadTransactions(page: 1);
          }
        }
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
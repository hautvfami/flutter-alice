import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/model/alice_calls_filter.dart';
import 'package:flutter_alice/theme/theme.dart';

class AliceSearchBottomSheet extends StatefulWidget {
  final AliceCallsFilter initialFilter;
  final ValueListenable<int>? filteredCountNotifier;
  final int totalCount;
  final ValueChanged<AliceCallsFilter> onFilterChanged;

  const AliceSearchBottomSheet({
    super.key,
    required this.initialFilter,
    required this.totalCount,
    required this.onFilterChanged,
    this.filteredCountNotifier,
  });

  @override
  State<AliceSearchBottomSheet> createState() => _AliceSearchBottomSheetState();
}

class _AliceSearchBottomSheetState extends State<AliceSearchBottomSheet> {
  static const List<String> _statusFilters = [
    'ALL',
    '2xx',
    '3xx',
    '4xx',
    '5xx',
    'Error',
  ];
  static const List<String> _methodFilters = [
    'ALL',
    'GET',
    'POST',
    'PUT',
    'DELETE',
  ];

  late final TextEditingController _textController;
  late AliceCallsFilter _currentFilter;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    _textController = TextEditingController(text: _currentFilter.query);
    _hasText = _textController.text.isNotEmpty;
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _textController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        _currentFilter = _currentFilter.copyWith(query: query.trim());
        widget.onFilterChanged(_currentFilter);
      }
    });
  }

  void _onStatusSelected(String status) {
    setState(() {
      _currentFilter = _currentFilter.copyWith(status: status);
    });
    widget.onFilterChanged(_currentFilter);
  }

  void _onMethodSelected(String method) {
    setState(() {
      _currentFilter = _currentFilter.copyWith(method: method);
    });
    widget.onFilterChanged(_currentFilter);
  }

  void _resetFilters() {
    _debounceTimer?.cancel();
    _textController.clear();
    setState(() {
      _currentFilter = AliceCallsFilter.empty;
    });
    widget.onFilterChanged(_currentFilter);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _textController,
                        autofocus: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.search,
                        style: AliceStyles.body.copyWith(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Search calls, url, status...",
                          hintStyle: AliceStyles.caption.copyWith(
                            color: AliceColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AliceColors.primary,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          suffixIcon: _hasText
                              ? IconButton(
                                  icon:
                                      const Icon(Icons.clear_rounded, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                  onPressed: () {
                                    _textController.clear();
                                    _debounceTimer?.cancel();
                                    setState(() {
                                      _currentFilter =
                                          _currentFilter.copyWith(query: '');
                                    });
                                    widget.onFilterChanged(_currentFilter);
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AliceColors.background,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AliceColors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AliceColors.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AliceColors.primary,
                              width: 1.2,
                            ),
                          ),
                        ),
                        onChanged: _onQueryChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.filteredCountNotifier != null)
                    ValueListenableBuilder<int>(
                      valueListenable: widget.filteredCountNotifier!,
                      builder: (_, count, __) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AliceColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "$count/${widget.totalCount}",
                            style: AliceStyles.captionBold.s11.primaryDark,
                          ),
                        );
                      },
                    ),
                  if (_currentFilter.hasActiveFilters)
                    IconButton(
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: AliceColors.error,
                      ),
                      tooltip: "Reset filters",
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      constraints: const BoxConstraints(),
                      onPressed: _resetFilters,
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AliceColors.textSecondary,
                    ),
                    tooltip: "Close",
                    padding: const EdgeInsets.only(left: 4),
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._statusFilters.map((status) {
                      final isSelected = _currentFilter.status == status;
                      return _buildChip(
                        label: status,
                        isSelected: isSelected,
                        color: _mapStatusColor(status),
                        onTap: () => _onStatusSelected(status),
                      );
                    }),
                    Container(
                      height: 14,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: AliceColors.divider,
                    ),
                    ..._methodFilters.map((method) {
                      final isSelected = _currentFilter.method == method;

                      return _buildChip(
                        label: method,
                        isSelected: isSelected,
                        color: _mapMethodColor(method),
                        onTap: () => _onMethodSelected(method),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withAlpha(18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : color.withAlpha(50),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }

  Color _mapMethodColor(String method) {
    switch (method) {
      case 'GET':
        return AliceColors.info;
      case 'POST':
        return AliceColors.success;
      case 'PUT':
        return AliceColors.warning;
      case 'DELETE':
        return AliceColors.error;
      default:
        return AliceColors.primary;
    }
  }

  Color _mapStatusColor(String status) {
    switch (status) {
      case '2xx':
        return AliceColors.success;
      case '3xx':
        return AliceColors.info;
      case '4xx':
        return AliceColors.warning;
      case '5xx':
      case 'Error':
        return AliceColors.error;
      default:
        return AliceColors.primary;
    }
  }
}

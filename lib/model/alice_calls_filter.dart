class AliceCallsFilter {
  final String query;
  final String status;
  final String method;

  const AliceCallsFilter({
    this.query = '',
    this.status = 'ALL',
    this.method = 'ALL',
  });

  bool get hasActiveFilters =>
      query.isNotEmpty || status != 'ALL' || method != 'ALL';

  AliceCallsFilter copyWith({
    String? query,
    String? status,
    String? method,
  }) {
    return AliceCallsFilter(
      query: query ?? this.query,
      status: status ?? this.status,
      method: method ?? this.method,
    );
  }

  static const empty = AliceCallsFilter();
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../providers/search_state_provider.dart';
import '../dream_summary_card.dart';
import '../error_message_widget.dart';
import '../filter_chips_widget.dart';

class SearchTab extends ConsumerStatefulWidget {
  const SearchTab({super.key});

  @override
  ConsumerState<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<SearchTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedEmotions = [];
  int _topK = 5;
  bool _showFilters = false;

  final List<String> _emotionOptions = [
    'happy',
    'sad',
    'anxious',
    'calm',
    'excited',
    'fearful',
    'peaceful',
    'confused',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    await ref.read(searchStateProvider.notifier).searchDreams(
          query,
          topK: _topK,
          startDate: _startDate,
          endDate: _endDate,
          emotionTags: _selectedEmotions.isNotEmpty ? _selectedEmotions : null,
        );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedEmotions = [];
      _topK = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final searchState = ref.watch(searchStateProvider);

    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.darkBlue,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Search dreams by meaning...',
                    hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
                    prefixIcon: const Icon(Icons.search, color: AppColors.lightBlue),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.white),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchStateProvider.notifier).clearSearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.lightBlue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.lightBlue),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: Icon(
                  Icons.filter_list,
                  color: _showFilters ? AppColors.primaryBlue : AppColors.lightBlue,
                ),
              ),
              IconButton(
                onPressed: searchState.isLoading ? null : _performSearch,
                icon: const Icon(Icons.search, color: AppColors.primaryBlue),
              ),
            ],
          ),
        ),

        // Filters section
        if (_showFilters)
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.darkBlue.withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date range
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectDateRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _startDate != null && _endDate != null
                              ? '${_startDate!.month}/${_startDate!.day} - ${_endDate!.month}/${_endDate!.day}'
                              : 'Select Date Range',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          foregroundColor: AppColors.white,
                        ),
                      ),
                    ),
                    if (_startDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                        },
                        icon: const Icon(Icons.clear, color: AppColors.white),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Emotion tags
                const Text(
                  'Emotion Tags',
                  style: TextStyle(
                    color: AppColors.lightBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                FilterChipsWidget(
                  options: _emotionOptions,
                  selectedOptions: _selectedEmotions,
                  onSelectionChanged: (selected) {
                    setState(() {
                      _selectedEmotions = selected;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Top K slider
                Row(
                  children: [
                    const Text(
                      'Results: ',
                      style: TextStyle(color: AppColors.lightBlue),
                    ),
                    Expanded(
                      child: Slider(
                        value: _topK.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: _topK.toString(),
                        activeColor: AppColors.primaryBlue,
                        onChanged: (value) {
                          setState(() {
                            _topK = value.toInt();
                          });
                        },
                      ),
                    ),
                    Text(
                      _topK.toString(),
                      style: const TextStyle(color: AppColors.white),
                    ),
                  ],
                ),

                // Clear filters button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                      foregroundColor: AppColors.primaryBlue,
                    ),
                    child: const Text('Clear Filters'),
                  ),
                ),
              ],
            ),
          ),

        // Error message
        if (searchState.error != null)
          ErrorMessageWidget(
            errorMessage: searchState.error!,
            onRetry: _performSearch,
          ),

        // Results
        Expanded(
          child: searchState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : searchState.searchResults.isEmpty
                  ? _buildEmptyState(searchState.currentQuery)
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: searchState.searchResults.length,
                      itemBuilder: (context, index) {
                        final dream = searchState.searchResults[index];
                        return DreamSummaryCard(
                          dreamSummary: dream,
                          onTap: () {
                            // Navigate to dream detail
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String? query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            query == null ? Icons.search : Icons.search_off,
            size: 64,
            color: AppColors.lightBlue.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            query == null ? 'Search your dreams' : 'No dreams found',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            query == null
                ? 'Try searching by meaning, not keywords'
                : 'Try adjusting your search or filters',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

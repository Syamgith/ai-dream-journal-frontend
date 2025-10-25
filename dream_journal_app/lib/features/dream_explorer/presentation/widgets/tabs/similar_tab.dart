import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../providers/similar_dreams_provider.dart';
import '../dream_summary_card.dart';
import '../error_message_widget.dart';
import '../dream_selector_modal.dart';
import '../exploring_indicator.dart';
import '../../../../dreams/presentation/pages/dream_details_page.dart';
import '../../../../dreams/providers/dream_repository_provider.dart';

class SimilarTab extends ConsumerStatefulWidget {
  final int? dreamId;

  const SimilarTab({super.key, this.dreamId});

  @override
  ConsumerState<SimilarTab> createState() => _SimilarTabState();
}

class _SimilarTabState extends ConsumerState<SimilarTab>
    with AutomaticKeepAliveClientMixin {
  int _topK = 5;
  int? _selectedDreamId;
  String? _selectedDreamTitle;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedDreamId = widget.dreamId;
    if (_selectedDreamId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Fetch dream details to get the title
        try {
          final dreamRepo = ref.read(dreamRepositoryProvider);
          final dreams = await dreamRepo.getDreams();
          final dream = dreams.firstWhere(
            (d) => d.id == _selectedDreamId,
            orElse: () => throw Exception('Dream not found'),
          );
          setState(() {
            _selectedDreamTitle = dream.title ?? 'Untitled Dream';
          });
          _findSimilarDreams();
        } catch (e) {
          debugPrint('Error fetching dream details: $e');
        }
      });
    }
  }

  Future<void> _selectDream() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DreamSelectorModal(),
    );

    if (result != null) {
      setState(() {
        _selectedDreamId = result['id'] as int;
        _selectedDreamTitle = result['title'] as String;
      });
    }
  }

  Future<void> _findSimilarDreams() async {
    if (_selectedDreamId == null || _selectedDreamTitle == null) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    await ref
        .read(similarDreamsProvider.notifier)
        .findSimilar(_selectedDreamId!, _selectedDreamTitle!, topK: _topK);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final similarState = ref.watch(similarDreamsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Similar Dreams',
            style: TextStyle(
              color: AppColors.lightBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Dream selector
          Card(
            color: AppColors.darkBlue,
            elevation: 4,
            child: InkWell(
              onTap: _selectDream,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _selectedDreamId != null
                          ? Icons.check_circle
                          : Icons.add_circle_outline,
                      size: 40,
                      color: _selectedDreamId != null
                          ? AppColors.primaryBlue
                          : AppColors.lightBlue.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Source Dream',
                            style: TextStyle(
                              color: AppColors.lightBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedDreamTitle != null)
                            Text(
                              _selectedDreamTitle!.length > 10
                                  ? '${_selectedDreamTitle!.substring(0, 10)}...'
                                  : _selectedDreamTitle!,
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            )
                          else
                            Text(
                              'Tap to select a dream',
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: AppColors.lightBlue, size: 16),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Top K slider
          Row(
            children: [
              const Text(
                'Number of results: ',
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
          const SizedBox(height: 16),

          // Find button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _selectedDreamId != null && !similarState.isLoading
                      ? _findSimilarDreams
                      : null,
              icon: const Icon(Icons.search),
              label: const Text('Find Similar Dreams'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: AppColors.darkBlue,
                disabledForegroundColor: AppColors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Error message
          if (similarState.error != null)
            ErrorMessageWidget(
              errorMessage: similarState.error!,
              onRetry: _findSimilarDreams,
            ),

          // Loading indicator
          if (similarState.isLoading)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: ExploringIndicator(),
            ),

          // Results
          if (!similarState.isLoading &&
              similarState.error == null &&
              similarState.similarDreams.isNotEmpty) ...[
            const Text(
              'Similar Dreams',
              style: TextStyle(
                color: AppColors.lightBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: similarState.similarDreams.length,
              itemBuilder: (context, index) {
                final dream = similarState.similarDreams[index];
                return DreamSummaryCard(
                  dreamSummary: dream,
                  onTap: () {
                    // Haptic feedback
                    HapticFeedback.lightImpact();

                    // Navigate to dream details page with optimistic navigation
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DreamDetailsPage(
                          dreamId: dream.dreamId,
                          initialTitle: dream.title,
                          initialDate: dream.date,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],

          // Empty state
          if (!similarState.isLoading &&
              similarState.error == null &&
              similarState.similarDreams.isEmpty &&
              _selectedDreamId != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.lightBlue.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No similar dreams found',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

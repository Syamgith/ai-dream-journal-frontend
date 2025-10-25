import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../core/widgets/markdown_text.dart';
import '../../../providers/comparison_state_provider.dart';
import '../error_message_widget.dart';
import '../dream_selector_modal.dart';
import '../exploring_indicator.dart';

class CompareTab extends ConsumerStatefulWidget {
  const CompareTab({super.key});

  @override
  ConsumerState<CompareTab> createState() => _CompareTabState();
}

class _CompareTabState extends ConsumerState<CompareTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _selectDream1() async {
    final dreamId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DreamSelectorModal(),
    );

    if (dreamId != null) {
      ref.read(comparisonStateProvider.notifier).selectDream1(dreamId);
    }
  }

  Future<void> _selectDream2() async {
    final dreamId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DreamSelectorModal(),
    );

    if (dreamId != null) {
      ref.read(comparisonStateProvider.notifier).selectDream2(dreamId);
    }
  }

  Future<void> _compareDreams() async {
    final state = ref.read(comparisonStateProvider);
    if (state.selectedDream1Id != null && state.selectedDream2Id != null) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      await ref
          .read(comparisonStateProvider.notifier)
          .compareDreams(state.selectedDream1Id!, state.selectedDream2Id!);
    }
  }

  void _copyToClipboard(String text) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: text));
    CustomSnackbar.show(
      context: context,
      message: 'Comparison copied to clipboard',
      type: SnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final comparisonState = ref.watch(comparisonStateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Two Dreams to Compare',
            style: TextStyle(
              color: AppColors.lightBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Dream selection cards
          Row(
            children: [
              Expanded(
                child: _buildDreamSelector(
                  title: 'Dream 1',
                  dreamId: comparisonState.selectedDream1Id,
                  onSelect: _selectDream1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDreamSelector(
                  title: 'Dream 2',
                  dreamId: comparisonState.selectedDream2Id,
                  onSelect: _selectDream2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Compare button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  comparisonState.canCompare ? _compareDreams : null,
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Compare Dreams'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: AppColors.darkBlue,
                disabledForegroundColor: AppColors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Clear button
          if (comparisonState.selectedDream1Id != null ||
              comparisonState.selectedDream2Id != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(comparisonStateProvider.notifier).clearComparison();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Selection'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.lightBlue,
                  side: const BorderSide(color: AppColors.lightBlue),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Error message
          if (comparisonState.error != null)
            ErrorMessageWidget(
              errorMessage: comparisonState.error!,
              onRetry: _compareDreams,
            ),

          // Loading indicator
          if (comparisonState.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: ExploringIndicator(),
            ),

          // Comparison results
          if (comparisonState.comparison != null) ...[
            Card(
              color: AppColors.darkBlue,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Comparison Analysis',
                          style: TextStyle(
                            color: AppColors.lightBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _copyToClipboard(comparisonState.comparison!),
                              icon: const Icon(Icons.copy,
                                  color: AppColors.lightBlue),
                              tooltip: 'Copy to clipboard',
                            ),
                            IconButton(
                              onPressed: () {
                                // Share functionality
                              },
                              icon: const Icon(Icons.share,
                                  color: AppColors.lightBlue),
                              tooltip: 'Share',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.lightBlue),
                    const SizedBox(height: 8),
                    MarkdownText(
                      data: comparisonState.comparison!,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDreamSelector({
    required String title,
    required int? dreamId,
    required VoidCallback onSelect,
  }) {
    return Card(
      color: AppColors.darkBlue,
      elevation: 4,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.14,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                dreamId != null ? Icons.check_circle : Icons.add_circle_outline,
                size: 40,
                color: dreamId != null
                    ? AppColors.primaryBlue
                    : AppColors.lightBlue.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.lightBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (dreamId != null)
                Text(
                  'ID: $dreamId',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

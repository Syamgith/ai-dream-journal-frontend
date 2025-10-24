import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../providers/pattern_analysis_provider.dart';
import '../dream_summary_card.dart';
import '../error_message_widget.dart';
import '../shimmer_skeleton.dart';

class PatternsTab extends ConsumerStatefulWidget {
  const PatternsTab({super.key});

  @override
  ConsumerState<PatternsTab> createState() => _PatternsTabState();
}

class _PatternsTabState extends ConsumerState<PatternsTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _queryController = TextEditingController();
  int _topK = 10;
  bool _showExamples = false;

  final List<String> _exampleQueries = [
    'recurring nightmares about being chased',
    'dreams about flying',
    'water-related dreams',
    'dreams about family members',
    'anxiety dreams during stressful periods',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _analyzePatterns() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    await ref.read(patternAnalysisProvider.notifier).analyzePatterns(
          query,
          topK: _topK,
        );

    // Show success snackbar
    final state = ref.read(patternAnalysisProvider);
    if (state.error == null && state.analysis != null && mounted) {
      CustomSnackbar.show(
        context: context,
        message: 'Pattern analysis complete!',
        type: SnackBarType.success,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _copyToClipboard(String text) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: text));
    CustomSnackbar.show(
      context: context,
      message: 'Analysis copied to clipboard',
      type: SnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final patternState = ref.watch(patternAnalysisProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input section
          TextField(
            controller: _queryController,
            maxLines: 2,
            maxLength: 200,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Describe a pattern to analyze...',
              hintStyle: TextStyle(color: AppColors.white.withValues(alpha: 0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightBlue),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightBlue),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
              filled: true,
              fillColor: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 16),

          // Examples section
          ExpansionTile(
            title: const Text(
              'Example Queries',
              style: TextStyle(color: AppColors.lightBlue),
            ),
            iconColor: AppColors.primaryBlue,
            collapsedIconColor: AppColors.lightBlue,
            initiallyExpanded: _showExamples,
            onExpansionChanged: (expanded) {
              setState(() {
                _showExamples = expanded;
              });
            },
            children: _exampleQueries.map((example) {
              return ListTile(
                title: Text(
                  example,
                  style: const TextStyle(color: AppColors.white, fontSize: 14),
                ),
                trailing: const Icon(Icons.arrow_forward, color: AppColors.primaryBlue),
                onTap: () {
                  _queryController.text = example;
                  setState(() {
                    _showExamples = false;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Top K slider
          Row(
            children: [
              const Text(
                'Dreams to analyze: ',
                style: TextStyle(color: AppColors.lightBlue),
              ),
              Expanded(
                child: Slider(
                  value: _topK.toDouble(),
                  min: 1,
                  max: 50,
                  divisions: 49,
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

          // Analyze button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: patternState.isLoading ? null : _analyzePatterns,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Analyze Patterns'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Error message
          if (patternState.error != null)
            ErrorMessageWidget(
              errorMessage: patternState.error!,
              onRetry: _analyzePatterns,
            ),

          // Loading skeleton
          if (patternState.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: AnalysisSkeleton(),
            ),

          // Analysis results
          if (patternState.analysis != null) ...[
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
                          'Pattern Analysis',
                          style: TextStyle(
                            color: AppColors.lightBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _copyToClipboard(patternState.analysis!),
                              icon: const Icon(Icons.copy, color: AppColors.lightBlue),
                              tooltip: 'Copy to clipboard',
                            ),
                            IconButton(
                              onPressed: () {
                                // Share functionality
                              },
                              icon: const Icon(Icons.share, color: AppColors.lightBlue),
                              tooltip: 'Share',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.lightBlue),
                    const SizedBox(height: 8),
                    Text(
                      patternState.analysis!,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Relevant dreams
            if (patternState.relevantDreams.isNotEmpty) ...[
              const Text(
                'Supporting Dreams',
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
                itemCount: patternState.relevantDreams.length,
                itemBuilder: (context, index) {
                  final dream = patternState.relevantDreams[index];
                  return DreamSummaryCard(
                    dreamSummary: dream,
                    onTap: () {
                      // Navigate to dream detail
                    },
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }
}

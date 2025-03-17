import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/dreams_provider.dart';
import '../widgets/dream_card.dart';
import 'package:flutter/foundation.dart';
//import '../widgets/dream_icon.dart';

class DreamsPage extends ConsumerWidget {
  const DreamsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dreams = ref.watch(dreamsProvider);
    final isLoading = ref.watch(dreamsLoadingProvider);
    final hasInitialLoad = ref.watch(dreamsInitialLoadProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(20),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         'December',
          //         style: AppTextStyles.monthTitle,
          //       ),
          //       Row(
          //         children: [
          //           Text(
          //             '10',
          //             style: AppTextStyles.dayNumber,
          //           ),
          //           const SizedBox(width: 8),
          //           Text(
          //             'Tue',
          //             style: AppTextStyles.dayText,
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            child: isLoading && !hasInitialLoad
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : dreams.isEmpty
                    ? Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/add-dream'),
                          child: const Text(
                            'Add your first dream!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(dreamsProvider.notifier)
                            .loadDreams(forceRefresh: true),
                        child: _DreamsList(dreams: dreams),
                      ),
          ),
          //SleepingIcon()
        ],
      ),
    );
  }
}

// A separate widget for the dreams list to optimize rebuilds
class _DreamsList extends StatelessWidget {
  final List<dynamic> dreams;

  const _DreamsList({required this.dreams});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: dreams.length,
      itemBuilder: (context, index) {
        final dream = dreams[dreams.length - 1 - index];
        return KeyedSubtree(
          // Use the dream ID as a key to maintain widget identity
          key: ValueKey(
              dream.id ?? 'dream-${dream.timestamp.millisecondsSinceEpoch}'),
          child: DreamCard(dream: dream),
        );
      },
    );
  }
}

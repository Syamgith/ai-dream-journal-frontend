import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../providers/dreams_provider.dart';
import '../widgets/dream_card.dart';
//import '../widgets/dream_icon.dart';

class DreamsPage extends ConsumerWidget {
  const DreamsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dreams = ref.watch(dreamsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Dreams',
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
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
            child: ListView.builder(
              itemCount: dreams.length,
              itemBuilder: (context, index) {
                final dream = dreams[dreams.length - 1 - index];
                return DreamCard(dream: dream);
              },
            ),
          ),
          //SleepingIcon()
        ],
      ),
    );
  }
}

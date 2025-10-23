import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../dreams/providers/dream_repository_provider.dart';
import '../../../dreams/data/models/dream_entry.dart';

class DreamSelectorModal extends ConsumerStatefulWidget {
  const DreamSelectorModal({super.key});

  @override
  ConsumerState<DreamSelectorModal> createState() =>
      _DreamSelectorModalState();
}

class _DreamSelectorModalState extends ConsumerState<DreamSelectorModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Select a Dream',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.white),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Search dreams...',
                hintStyle: TextStyle(color: AppColors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: AppColors.lightBlue),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.white),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
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
                  borderSide:
                      const BorderSide(color: AppColors.primaryBlue, width: 2),
                ),
                filled: true,
                fillColor: AppColors.darkBlue,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 16),

          // Dreams list
          Expanded(
            child: FutureBuilder(
              future: ref.read(dreamRepositoryProvider).getDreams(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading dreams',
                      style: TextStyle(color: AppColors.white.withOpacity(0.7)),
                    ),
                  );
                }

                final dreams = (snapshot.data as List<DreamEntry>?) ?? [];
                final filteredDreams = _searchQuery.isEmpty
                    ? dreams
                    : dreams
                        .where((dream) =>
                            (dream.title?.toLowerCase().contains(_searchQuery) ?? false) ||
                            dream.description
                                .toLowerCase()
                                .contains(_searchQuery))
                        .toList();

                if (filteredDreams.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.lightBlue.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No dreams found',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDreams.length,
                  itemBuilder: (context, index) {
                    final dream = filteredDreams[index];
                    final dateFormat = DateFormat('MMM dd, yyyy');
                    final formattedDate = dateFormat.format(dream.timestamp);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: AppColors.darkBlue,
                      child: ListTile(
                        title: Text(
                          dream.title ?? 'Untitled Dream',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              dream.description,
                              style: TextStyle(
                                color: AppColors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: AppColors.lightBlue,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.primaryBlue,
                          size: 16,
                        ),
                        onTap: () {
                          Navigator.pop(context, dream.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

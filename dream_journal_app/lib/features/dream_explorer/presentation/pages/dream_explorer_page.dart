import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/dream_explorer_app_bar.dart';
import '../widgets/tabs/chat_tab.dart';
import '../widgets/tabs/search_tab.dart';
import '../widgets/tabs/patterns_tab.dart';
import '../widgets/tabs/compare_tab.dart';
import '../widgets/tabs/similar_tab.dart';

class DreamExplorerPage extends StatefulWidget {
  final int? initialTab;
  final int? dreamId;

  const DreamExplorerPage({
    super.key,
    this.initialTab,
    this.dreamId,
  });

  @override
  State<DreamExplorerPage> createState() => _DreamExplorerPageState();
}

class _DreamExplorerPageState extends State<DreamExplorerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTab ?? 0, // Default to Chat tab (index 0)
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DreamExplorerAppBar(
        title: 'Dream Explorer',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.lightBlue,
          tabs: const [
            Tab(icon: Icon(Icons.chat), text: 'Chat'),
            Tab(icon: Icon(Icons.search), text: 'Search'),
            Tab(icon: Icon(Icons.pattern), text: 'Patterns'),
            Tab(icon: Icon(Icons.compare_arrows), text: 'Compare'),
            Tab(icon: Icon(Icons.layers), text: 'Similar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ChatTab(), // Index 0 - DEFAULT
          const SearchTab(), // Index 1
          const PatternsTab(), // Index 2
          const CompareTab(), // Index 3
          SimilarTab(dreamId: widget.dreamId), // Index 4
        ],
      ),
    );
  }
}

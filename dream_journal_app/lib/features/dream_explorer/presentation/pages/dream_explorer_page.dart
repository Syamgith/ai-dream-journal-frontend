import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
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
  double _dragOffset = 0.0;
  bool _isDragging = false;

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

  void _handleVerticalDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset = 0.0;
    });
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Only allow downward drag (positive delta)
      if (details.delta.dy > 0) {
        _dragOffset += details.delta.dy;
        // Apply elastic resistance - the further you drag, the harder it gets
        _dragOffset = _dragOffset * 0.95;
      }
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    // If dragged more than 150 pixels, dismiss the page
    if (_dragOffset > 150) {
      Navigator.of(context).pop();
    } else {
      // Otherwise, snap back to original position
      setState(() {
        _dragOffset = 0.0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: GestureDetector(
        onVerticalDragStart: _handleVerticalDragStart,
        onVerticalDragUpdate: _handleVerticalDragUpdate,
        onVerticalDragEnd: _handleVerticalDragEnd,
        child: AnimatedContainer(
          duration:
              _isDragging ? Duration.zero : const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _dragOffset, 0),
          child: Scaffold(
            backgroundColor: AppColors.background,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 48 + 20),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: AppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.lightBlue,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Dream Explorer',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: TabBar(
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
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const ChatTab(), // Index 0 - DEFAULT
              const SearchTab(), // Index 1
              const PatternsTab(), // Index 2
              const CompareTab(), // Index 3
              SimilarTab(dreamId: widget.dreamId), // Index 4
            ],
          ),
        ),
      ),
      ),
    );
  }
}

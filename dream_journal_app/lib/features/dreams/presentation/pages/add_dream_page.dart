import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/dream_entry.dart';
import '../../providers/dreams_provider.dart';

class AddDreamPage extends ConsumerStatefulWidget {
  final DreamEntry? dream;
  const AddDreamPage({super.key, this.dream});

  @override
  ConsumerState<AddDreamPage> createState() => _AddDreamPageState();
}

class _AddDreamPageState extends ConsumerState<AddDreamPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  late DateTime _selectedDate;
  String? _interpretation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.dream != null) {
      _titleController.text = widget.dream!.title ?? '';
      _descriptionController.text = widget.dream!.description;
      _selectedDate = widget.dream!.timestamp;
      _interpretation = widget.dream!.interpretation;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.dream != null ? 'Edit Dream' : 'Add Dream',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primaryBlue.withAlpha(77),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        maxLength: 30,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                        decoration: InputDecoration(
                          labelText: null,
                          hintText: 'Give your dream a title...',
                          alignLabelWithHint: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          counterText: '',
                          hintStyle: TextStyle(
                            color: AppColors.white.withAlpha(128),
                            fontSize: 14,
                            letterSpacing: 0.3,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(14, 8, 14, 8),
                          prefixIcon: Icon(
                            Icons.edit_outlined,
                            color: AppColors.white.withAlpha(128),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryBlue.withAlpha(77),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          height: 1.5,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: 'Write about your dream experience...',
                          hintStyle: TextStyle(
                            color: AppColors.white.withAlpha(128),
                            fontSize: 15,
                            letterSpacing: 0.3,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16, top: 12),
                            child: Icon(
                              Icons.auto_stories_outlined,
                              color: AppColors.white.withAlpha(128),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.white.withAlpha(179),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(_selectedDate),
                          style: TextStyle(
                            color: AppColors.white.withAlpha(230),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
              if (_interpretation != null)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dream Interpretation',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _interpretation!,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  height: 56,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.lightBlue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withAlpha(77),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _saveDream,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Text(
                      widget.dream != null ? 'Update Dream' : 'Save Dream',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveDream() async {
    if (_descriptionController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dream = DreamEntry(
        id: widget.dream?.id,
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : null,
        description: _descriptionController.text.trim(),
        timestamp: _selectedDate,
        interpretation: widget.dream?.interpretation,
      );

      if (widget.dream != null) {
        await ref.read(dreamsProvider.notifier).updateDream(dream);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        final interpretedDream =
            await ref.read(dreamsProvider.notifier).addDream(dream);

        if (mounted) {
          setState(() {
            _interpretation = interpretedDream.interpretation;
          });
        }
        return; // Don't pop the page, show interpretation instead
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

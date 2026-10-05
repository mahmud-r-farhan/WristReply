import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Chip editor for managing user-defined custom blocked words in the LPTE shield.
class CustomWordEditor extends StatefulWidget {
  final List<String> words;
  final ValueChanged<List<String>> onChanged;
  final int maxWords;

  const CustomWordEditor({
    super.key,
    required this.words,
    required this.onChanged,
    this.maxWords = 24,
  });

  @override
  State<CustomWordEditor> createState() => _CustomWordEditorState();
}

class _CustomWordEditorState extends State<CustomWordEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addWord() {
    final text = _controller.text.trim().toLowerCase();
    if (text.isEmpty) {
      Navigator.pop(context);
      return;
    }
    if (widget.words.length >= widget.maxWords) {
      Navigator.pop(context);
      return;
    }
    if (!widget.words.contains(text)) {
      final updated = List<String>.from(widget.words)..add(text);
      widget.onChanged(updated);
    }
    _controller.clear();
    Navigator.pop(context);
  }

  void _removeWord(String word) {
    final updated = List<String>.from(widget.words)..remove(word);
    widget.onChanged(updated);
  }

  void _showAddDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        title: const Text('Add Blocked Word', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: TextField(
          controller: _controller,
          autofocus: true,
          maxLength: 32,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter keyword to shield...',
            hintStyle: TextStyle(color: AppColors.textTertiary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: _addWord,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentDanger, foregroundColor: Colors.white),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.words.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No custom words blocked. Default dictionary active.',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.words.map((word) {
              return Chip(
                label: Text(word, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                backgroundColor: AppColors.surfaceRaised,
                deleteIconColor: AppColors.textTertiary,
                onDeleted: () => _removeWord(word),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.borderSubtle),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: widget.words.length >= widget.maxWords ? null : _showAddDialog,
          icon: const Icon(Icons.add, size: 16, color: AppColors.accentDanger),
          label: Text(
            widget.words.length >= widget.maxWords
                ? 'MAX ${widget.maxWords} WORDS REACHED'
                : 'ADD CUSTOM BLOCKED WORD',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentDanger,
            side: BorderSide(color: AppColors.accentDanger.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Interactive list editor for configuring custom fallback quick reply templates.
class FallbackPillEditor extends StatefulWidget {
  final List<String> pills;
  final ValueChanged<List<String>> onChanged;

  const FallbackPillEditor({
    super.key,
    required this.pills,
    required this.onChanged,
  });

  @override
  State<FallbackPillEditor> createState() => _FallbackPillEditorState();
}

class _FallbackPillEditorState extends State<FallbackPillEditor> {
  final TextEditingController _textController = TextEditingController();

  void _addPill() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final updated = List<String>.from(widget.pills)..add(text);
      widget.onChanged(updated);
      _textController.clear();
      Navigator.pop(context);
    }
  }

  void _removePill(int index) {
    final updated = List<String>.from(widget.pills)..removeAt(index);
    widget.onChanged(updated);
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        title: const Text('Add Fallback Pill', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: TextField(
          controller: _textController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. Call you in 10 minutes',
            hintStyle: TextStyle(color: AppColors.textTertiary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: _addPill,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentMint, foregroundColor: Colors.black),
            child: const Text('Add'),
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
        ...widget.pills.asMap().entries.map((entry) {
          final index = entry.key;
          final pill = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Text('${index + 1}.', style: const TextStyle(color: AppColors.accentMint, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(pill, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textTertiary),
                  onPressed: () => _removePill(index),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: _showAddDialog,
          icon: const Icon(Icons.add, size: 16, color: AppColors.accentMint),
          label: const Text('ADD CUSTOM FALLBACK PILL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accentMint,
            side: const BorderSide(color: AppColors.accentMint),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
      ],
    );
  }
}

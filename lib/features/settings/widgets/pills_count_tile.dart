import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Interactive dropdown tile for selecting the number of Smart Reply action pills.
class PillsCountTile extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;

  const PillsCountTile({
    super.key,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Pills Per Message',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          DropdownButton<int>(
            value: count,
            dropdownColor: AppColors.surfaceRaised,
            items: [1, 2, 3].map((n) => DropdownMenuItem(value: n, child: Text('$n pills'))).toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ],
      ),
    );
  }
}

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

  static const List<int> _allowedCounts = <int>[1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    final safeCount = _allowedCounts.contains(count) ? count : 3;
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pills Per Message',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2),
                Text(
                  'Maximum action chips rendered under each notification.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          DropdownButton<int>(
            value: safeCount,
            dropdownColor: AppColors.surfaceRaised,
            items: _allowedCounts
                .map((n) => DropdownMenuItem<int>(
                      value: n,
                      child: Text('$n pills', style: const TextStyle(color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ],
      ),
    );
  }
}

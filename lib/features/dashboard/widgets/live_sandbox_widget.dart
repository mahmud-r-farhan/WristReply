import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/platform/native_channel.dart';
import '../../../shared/widgets/reply_pill_preview.dart';

/// Live Testing Sandbox widget enabling simulated on-device replies without a second phone.
class LiveSandboxWidget extends StatefulWidget {
  const LiveSandboxWidget({super.key});

  @override
  State<LiveSandboxWidget> createState() => _LiveSandboxWidgetState();
}

class _LiveSandboxWidgetState extends State<LiveSandboxWidget> {
  final TextEditingController _controller = TextEditingController(
    text: 'Hey, are you free for a quick call right now?',
  );
  List<String> _generatedPills = [];
  bool _isLoading = false;
  String? _dispatchedNotice;

  @override
  void initState() {
    super.initState();
    _generatePills();
  }

  Future<void> _generatePills() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isLoading = true);

    final pills = await NativeChannel.simulateSmartReply(text);
    if (mounted) {
      setState(() {
        _generatedPills = pills.isNotEmpty ? pills : ['Free now, call!', 'Busy, text me', '10 min pls'];
        _isLoading = false;
        _dispatchedNotice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LIVE TEST SANDBOX',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentMint),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceInteractive,
              hintText: 'Type or simulate a message...',
              hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded, size: 18, color: AppColors.accentMint),
                onPressed: _generatePills,
              ),
            ),
            onSubmitted: (_) => _generatePills(),
          ),
          const SizedBox(height: 14),
          const Text(
            'GENERATED PILLS (TAP TO SIMULATE SEND):',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _generatedPills.map((pill) {
              return ReplyPillPreview(
                text: pill,
                onTap: () {
                  setState(() {
                    _dispatchedNotice = 'Simulated dispatch: "$pill"';
                  });
                },
              );
            }).toList(),
          ),
          if (_dispatchedNotice != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.accentMint, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _dispatchedNotice!,
                    style: const TextStyle(color: AppColors.accentMint, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

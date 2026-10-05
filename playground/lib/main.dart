import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PlaygroundApp());
}

/// Color tokens matching the OLED Dark Utility design system of the
/// production Android app. See lib/core/constants/app_colors.dart.
class AppColors {
  AppColors._();
  static const Color surfaceCanvas = Color(0xFF0B0E14);
  static const Color surfaceRaised = Color(0xFF131823);
  static const Color surfaceInteractive = Color(0xFF1C2333);
  static const Color borderSubtle = Color(0xFF222B3D);
  static const Color borderAccent = Color(0xFF2D3A54);
  static const Color accentPrimary = Color(0xFF00F2FE);
  static const Color accentMint = Color(0xFF38EF7D);
  static const Color accentWarning = Color(0xFFFFB020);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF475569);
}

class PlaygroundApp extends StatelessWidget {
  const PlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WristReply AI Playground',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: AppColors.surfaceCanvas,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentMint,
          secondary: AppColors.accentPrimary,
          surface: AppColors.surfaceRaised,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: -1),
          headlineMedium: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          labelSmall: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        ),
      ),
      home: const PlaygroundHome(),
    );
  }
}

class PlaygroundHome extends StatefulWidget {
  const PlaygroundHome({super.key});

  @override
  State<PlaygroundHome> createState() => _PlaygroundHomeState();
}

class _PlaygroundHomeState extends State<PlaygroundHome> {
  final TextEditingController _text = TextEditingController(
    text: 'Hey, are you free for a quick call right now?',
  );
  List<String> _pills = const [];
  String? _localeDetected;
  String? _dispatchNotice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _generate() {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    final result = WebFallbackEngine.resolve(text);
    setState(() {
      _pills = result.replies;
      _localeDetected = result.localeLabel;
      _dispatchNotice = null;
    });
  }

  void _dispatch(String pill) {
    HapticFeedback.lightImpact();
    setState(() => _dispatchNotice = 'Simulated dispatch: "$pill"');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accentMint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentMint.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: AppColors.accentMint, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WristReply AI',
                              style: TextStyle(
                                color: AppColors.accentPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Interactive Playground',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const _PrivacyBadge(),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Try the offline-first smart reply engine directly in your browser. No data leaves this device — the entire pipeline runs on-device.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  _buildSandbox(),
                  const SizedBox(height: 24),
                  _buildLocalePreview(),
                  const SizedBox(height: 24),
                  _buildArchitecture(),
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSandbox() {
    return Container(
      padding: const EdgeInsets.all(18),
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
              if (_localeDetected != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'LOCALE: ${_localeDetected!.toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.accentPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _text,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceInteractive,
              hintText: 'Type or paste an incoming message…',
              hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.accentMint),
                onPressed: _generate,
              ),
            ),
            onSubmitted: (_) => _generate(),
          ),
          const SizedBox(height: 14),
          const Text(
            'GENERATED PILLS — TAP TO SIMULATE:',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _pills.map((pill) => _ReplyPillPreview(text: pill, onTap: () => _dispatch(pill))).toList(),
          ),
          if (_dispatchNotice != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppColors.accentMint, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _dispatchNotice!,
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

  Widget _buildLocalePreview() {
    final samples = <String, String>{
      'English': 'Hey what time are we leaving?',
      'Spanish': 'Hola amigo, ¿dónde estás?',
      'German': 'Hallo, wo bist du?',
      'Portuguese': 'Onde você está?',
      'French': 'Tu es où en ce moment ?',
      'Arabic': 'وينك يا غالي؟',
      'Hindi': 'Bhai kahan ho?',
      'Bengali': 'কেমন আছো?',
    };
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MULTI-REGIONAL LOCALE PREVIEW',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          for (final entry in samples.entries) ...[
            InkWell(
              onTap: () {
                _text.text = entry.value;
                _generate();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: AppColors.accentMint,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.play_arrow_rounded, color: AppColors.textTertiary, size: 16),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildArchitecture() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ARCHITECTURE',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '• :core-engine is a pure Kotlin library with zero Flutter deps\n'
            '• NotificationListenerService runs headless at ~18 MB RAM\n'
            '• 0% idle CPU, 0 network permissions, 100% on-device NLP\n'
            '• Mirrors to Wear OS, Zepp OS, and budget RTOS smartwatches',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _Chip(label: 'Kotlin', icon: '🟪'),
              _Chip(label: 'ML Kit Smart Reply', icon: '🧠'),
              _Chip(label: 'Notification', icon: '🔔'),
              _Chip(label: 'Wear OS', icon: '⌚'),
              _Chip(label: 'Zero Cloud', icon: '🔒'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '© 2026 Mahmud R-Farhan — Apache 2.0',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
        ),
        TextButton.icon(
          icon: const Icon(Icons.code_rounded, size: 14, color: AppColors.accentPrimary),
          label: const Text(
            'GitHub',
            style: TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _ReplyPillPreview extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _ReplyPillPreview({required this.text, required this.onTap});

  @override
  State<_ReplyPillPreview> createState() => _ReplyPillPreviewState();
}

class _ReplyPillPreviewState extends State<_ReplyPillPreview> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceInteractive,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Text(
            widget.text,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _PrivacyBadge extends StatelessWidget {
  const _PrivacyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentMint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentMint.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, color: AppColors.accentMint, size: 14),
          SizedBox(width: 6),
          Text(
            'ZERO-CLOUD',
            style: TextStyle(color: AppColors.accentMint, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String icon;
  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceInteractive,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Deterministic mirror of the Kotlin `FallbackReplyEngine` contract.
///
/// Both engines share the same priority order so the playground demos the
/// exact same behavior the Android app will ship.
class WebFallbackEngine {
  static const _samples = {
    'english_casual': ['Sounds good!', 'On my way!', "Can't talk now, text later."],
    'english_pro': ['Understood, looking into it.', 'I will update you shortly.', 'Noted with thanks.'],
    'english_late_night': ['Asleep, talk tomorrow', 'Can it wait till morning?', 'Good night'],
    'spanish_casual': ['¡Dale, suena bien!', '¡Voy en camino!', 'No puedo hablar ahora, te escribo.'],
    'spanish_pro': ['Entendido, lo reviso ahora.', 'Te confirmo en un momento.', 'Quedo al pendiente.'],
    'spanish_late_night': ['Ya estoy durmiendo, hablamos mañana', '¿Puede esperar a mañana?', 'Buenas noches'],
    'german_casual': ['Alles klar!', 'Bin unterwegs!', 'Kann gerade nicht, melde mich später.'],
    'german_pro': ['Verstanden, ich prüfe das.', 'Ich gebe Ihnen gleich Bescheid.', 'Vielen Dank.'],
    'german_late_night': ['Schlafe schon, melde mich morgen', 'Kann das bis morgen warten?', 'Gute Nacht'],
    'portuguese_casual': ['Beleza, combinado!', 'Estou a caminho!', 'Não posso falar agora, te ligo já.'],
    'portuguese_pro': ['Entendido, já estou verificando.', 'Retorno em breve.', 'Muito obrigado.'],
    'portuguese_late_night': ['Dormindo já, falo amanhã', 'Pode esperar até amanhã?', 'Boa noite'],
    'french_casual': ['Ça marche !', 'Je suis en route !', 'Occupé pour le moment, je te rappelle.'],
    'french_pro': ['C\'est bien noté, je m\'en occupe.', 'Je reviens vers vous rapidement.', 'Merci bien.'],
    'french_late_night': ['Je dors déjà, on se parle demain', 'Ça peut attendre demain matin ?', 'Bonne nuit'],
    'arabic_casual': ['تمام، إن شاء الله!', 'أنا في الطريق!', 'مشغول الآن، بكلمك بعدين.'],
    'arabic_pro': ['تم الاستلام، سأوافيك بالتفاصيل قريباً.', 'شكراً جزيلاً.', 'سأتواصل معك في أقرب وقت.'],
    'arabic_late_night': ['نائم الآن، نتحدث غداً', 'ممكن تنتظر للصباح؟', 'تصبح على خير'],
    'hindi_casual': ['Theek hai, badhiya!', 'Raste me hu!', 'Abhi thoda busy hu, baad me call karta hu.'],
    'hindi_pro': ['समझा, अभी देखता हूँ।', 'जल्दी अपडेट करता हूँ।', 'धन्यवाद।'],
    'hindi_late_night': ['So raha hu, subah baat karte hai', 'Kal subah baat karein?', 'Shubh ratri'],
    'hindi_deva': ['हाँ, बिल्कुल!', 'रास्ते में हूँ!', 'थोड़ी देर में बात करता हूँ।'],
    'bengali_casual': ['হ্যাঁ, ঠিক আছে!', 'আমি রাস্তায় আছি!', 'একটু পর কথা বলছি।'],
    'bengali_late_night': ['Ghumacche, shokale kotha boli', 'Shokale bolte parbo?', 'Shubh ratri'],
  };

  static FallbackResult resolve(String text, {bool applyChronoBias = true}) {
    final tone = _detectTone(text);
    final isLate = _isLateNightHour();
    final key = _resolveKey(tone, isLate, applyChronoBias);
    final locale = _localeLabel(tone);
    final replies = _samples[key] ?? _samples['english_casual']!;
    return FallbackResult(replies: replies, localeLabel: locale);
  }

  static String _resolveKey(String tone, bool isLate, bool applyChronoBias) {
    if (isLate && applyChronoBias) {
      switch (tone) {
        case 'spanish':
          return 'spanish_late_night';
        case 'german':
          return 'german_late_night';
        case 'portuguese':
          return 'portuguese_late_night';
        case 'french':
          return 'french_late_night';
        case 'arabic':
          return 'arabic_late_night';
        case 'hindi':
          return 'hindi_late_night';
        case 'bengali':
          return 'bengali_late_night';
      }
      return 'english_late_night';
    }
    if (tone == 'hindi') return 'hindi_casual';
    if (tone == 'bengali') return 'bengali_casual';
    return '${tone}_casual';
  }

  static bool _isLateNightHour() {
    final hour = DateTime.now().hour;
    return hour >= 23 || hour <= 6;
  }

  static String _detectTone(String text) {
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return 'arabic';
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) return 'bengali';
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) return 'hindi_deva';
    final lower = text.toLowerCase();
    if (RegExp(r'\b(donde|d[oó]nde|hola|gracias|amigo|vamos)\b').hasMatch(lower)) return 'spanish';
    if (RegExp(r'\b(wo|wie|hallo|danke|bitte|unterwegs|bist)\b').hasMatch(lower)) return 'german';
    if (RegExp(r'\b(onde|ol[áa]|obrigado|beleza|tudo)\b').hasMatch(lower)) return 'portuguese';
    if (RegExp(r'\b(o[uù]|comment|merci|salut|dispo)\b').hasMatch(lower)) return 'french';
    if (RegExp(r'\b(kahan|kidhar|kya|badhiya|bhai)\b').hasMatch(lower)) return 'hindi';
    if (RegExp(r'\b(kothay|koi|kemon|aschis|hobe)\b').hasMatch(lower)) return 'bengali';
    return 'english';
  }

  static String _localeLabel(String tone) {
    switch (tone) {
      case 'spanish':
        return 'es-ES';
      case 'german':
        return 'de-DE';
      case 'portuguese':
        return 'pt-BR';
      case 'french':
        return 'fr-FR';
      case 'arabic':
        return 'ar-MENA';
      case 'hindi':
      case 'hindi_deva':
        return 'hi-IN';
      case 'bengali':
        return 'bn-BD';
    }
    return 'en-US';
  }
}

class FallbackResult {
  final List<String> replies;
  final String localeLabel;
  const FallbackResult({required this.replies, required this.localeLabel});
}
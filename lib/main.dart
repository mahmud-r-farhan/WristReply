import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/platform/native_channel.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/onboarding/screens/disclosure_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WristReplyApp());
}

/// Root entry point for WristReply AI presentation client.
class WristReplyApp extends StatelessWidget {
  const WristReplyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

/// Brief splash gate routing users to Onboarding or Cockpit based on permission state.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routeNext();
  }

  Future<void> _routeNext() async {
    final isGranted = await NativeChannel.isListenerRunning();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isGranted ? const DashboardScreen() : const DisclosureScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF38EF7D)),
      ),
    );
  }
}

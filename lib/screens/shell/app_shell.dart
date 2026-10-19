import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sleep_provider.dart';
import '../about/about_screen.dart';
import '../insights/insights_screen.dart';
import '../log/log_screen.dart';
import '../settings/settings_screen.dart';
import '../tonight/tonight_screen.dart';
import 'app_bottom_nav.dart';
import 'app_header.dart';
import 'overflow_menu.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final loading = context.select<SleepProvider, bool>((p) => p.isLoading);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              now: DateTime.now(),
              onOpenMenu: () => OverflowMenu.show(
                context,
                onSettings: () => _push(const SettingsScreen()),
                onAbout: () => _push(const AboutScreen()),
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : IndexedStack(
                      index: _tab,
                      children: const [TonightScreen(), LogScreen(), InsightsScreen()],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(index: _tab, onChanged: (i) => setState(() => _tab = i)),
    );
  }
}

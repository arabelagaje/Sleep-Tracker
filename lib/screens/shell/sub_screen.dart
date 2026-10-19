import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

// Page frame for screens opened from the ⋮ menu: back button + title.
class SubScreen extends StatelessWidget {
  const SubScreen({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Row(
              children: [
                Transform.translate(
                  offset: const Offset(-12, 0),
                  child: IconButton(
                    tooltip: 'Back',
                    icon: Icon(Icons.chevron_left, color: c.ink2),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-12, 0),
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

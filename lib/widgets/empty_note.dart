import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EmptyNote extends StatelessWidget {
  const EmptyNote({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(color: context.colors.ink2, fontSize: 14, height: 1.5),
    ),
  );
}

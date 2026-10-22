import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';

/// Tombol utama kuning pill — DESIGN_SYSTEM.md §6.
class LazyButton extends StatelessWidget {
  const LazyButton({
    super.key,
    required this.onPressed,
    this.label = 'Kasih aku yang paling ringan',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      icon: Icons.bolt,
      expanded: true,
      onTap: onPressed,
    );
  }
}

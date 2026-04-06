import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Overlay semitransparente de carregamento sobreposto ao [child].
/// Exibido quando [isLoading] é `true`.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  const LoadingOverlay({required this.isLoading, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.onPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

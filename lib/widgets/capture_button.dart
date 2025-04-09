import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';

class CaptureButton extends StatelessWidget {
  final bool isLoading;
  final bool isRetake;
  final VoidCallback? onTap;
  
  const CaptureButton({
    super.key,
    this.isLoading = false,
    this.isRetake = false,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isRetake
                ? MainTheme.redWarning
                : MainTheme.blueText,
            width: 3,
          ),
        ),
        child: Center(
          child: isLoading
            ? const CircularProgressIndicator(color: MainTheme.blueText)
            : isRetake
                ? const Icon(Icons.refresh, color: MainTheme.redWarning, size: 28)
                : Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: MainTheme.blueText,
                      shape: BoxShape.circle,
                    ),
                  ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';

class CameraModeButton extends StatelessWidget {
  final bool useNativeCamera;
  final bool isDisabled;
  final VoidCallback onTap;
  
  const CameraModeButton({
    super.key,
    required this.useNativeCamera,
    required this.onTap,
    this.isDisabled = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
          border: Border.all(
            color: useNativeCamera 
                ? MainTheme.blueText 
                : MainTheme.textfieldBorder,
            width: 1.5,
          ),
        ),
        child: Icon(
          useNativeCamera ? Icons.photo_camera : Icons.camera_alt,
          color: isDisabled
              ? MainTheme.placeholderText
              : MainTheme.blueText,
          size: 22,
        ),
      ),
    );
  }
}
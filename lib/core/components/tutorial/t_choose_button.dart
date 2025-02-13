import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';

/// A reusable custom button widget used for user entry actions
class ChooseTutorialButton extends StatelessWidget {
  /// Callback function triggered when the button is tapped.
  final Function()? onTap;

  /// Text to display on the button
  final String buttonText;

  const ChooseTutorialButton({
    super.key,
    required this.onTap,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handle button tap
      child: Container(
        padding: const EdgeInsets.all(16), // Inner padding for button content
        margin: const EdgeInsets.symmetric(horizontal: 50.0), // Horizontal margin
        decoration: BoxDecoration(
          color: MainTheme.buttonBackground,
          borderRadius: BorderRadius.circular(30), // Rounded corners
        ),
        // Button text
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              color: MainTheme.buttonText,
              fontFamily: 'BaiJamjuree',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:client/components/Color/theme.dart';


/// A *reusable* custom button widget used for user entry actions
class EntryButton extends StatelessWidget {

  /// Callback function triggered when the button is tapped.
  final Function()? onTap;

  const EntryButton({
    super.key,
    required this.onTap,
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
        child: const Center(
          child: Text(
            "เข้าสู่ระบบ", 
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

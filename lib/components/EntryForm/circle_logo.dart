import 'package:flutter/material.dart';
import 'package:client/components/Color/theme.dart';


/// A *reusable* widget representing a square tile with an image inside
class SquareTile extends StatelessWidget {

  // Path to the image asset displayed in the tile
  final String imagePath;

  const SquareTile({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      // Padding inside the tile
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        border: Border.all(
          color: MainTheme.logoBorder,
        ),

        // Rounded corners
        borderRadius: BorderRadius.circular(64),
        color: MainTheme.white,
      ),
      
      child: Image.asset(
        // Provide path for images/icon from assets folder
        imagePath,
        height: 40,
      ),
    );
  }
}

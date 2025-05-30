import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';

class EyeScanTabSelector extends StatelessWidget {
  final bool isRightEyeSelected;
  final bool isRightEyeCaptured;
  final Function(bool) onEyeSelected;

  const EyeScanTabSelector({
    super.key,
    required this.isRightEyeSelected,
    required this.isRightEyeCaptured,
    required this.onEyeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: MainTheme.blueText, width: 1),
      ),
      child: Row(
        children: [
          // Right Eye Tab
          Expanded(
            child: GestureDetector(
              onTap: () => onEyeSelected(true),
              child: Container(
                decoration: BoxDecoration(
                  color: isRightEyeSelected 
                      ? MainTheme.blueText 
                      : MainTheme.transparent,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Center(
                  child: Text(
                    'ตาขวา',
                    style: TextStyle(
                      color: isRightEyeSelected 
                          ? MainTheme.white 
                          : MainTheme.blueText,
                      fontFamily: 'BaiJamjuree',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Left Eye Tab
          Expanded(
            child: GestureDetector(
              onTap: isRightEyeCaptured ? () => onEyeSelected(false) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: !isRightEyeSelected 
                      ? MainTheme.blueText 
                      : MainTheme.transparent,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: Center(
                  child: Text(
                    'ตาซ้าย',
                    style: TextStyle(
                      color: !isRightEyeSelected 
                          ? MainTheme.white 
                          : isRightEyeCaptured
                              ? MainTheme.blueText
                              : MainTheme.placeholderText,
                      fontFamily: 'BaiJamjuree',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
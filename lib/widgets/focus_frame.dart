import 'package:flutter/material.dart';

class FocusFrame extends StatelessWidget {
  final double size;
  final Color color;
  final double lineWidth;
  final double cornerLength;

  const FocusFrame({
    super.key,
    this.size = 240,
    this.color = Colors.white,
    this.lineWidth = 3,
    this.cornerLength = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.transparent,
      child: Stack(
        children: [
          // Top-left corner
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: cornerLength,
              height: cornerLength,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: color, width: lineWidth),
                  left: BorderSide(color: color, width: lineWidth),
                ),
              ),
            ),
          ),
          // Top-right corner
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: cornerLength,
              height: cornerLength,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: color, width: lineWidth),
                  right: BorderSide(color: color, width: lineWidth),
                ),
              ),
            ),
          ),
          // Bottom-left corner
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: cornerLength,
              height: cornerLength,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: color, width: lineWidth),
                  left: BorderSide(color: color, width: lineWidth),
                ),
              ),
            ),
          ),
          // Bottom-right corner
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: cornerLength,
              height: cornerLength,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: color, width: lineWidth),
                  right: BorderSide(color: color, width: lineWidth),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
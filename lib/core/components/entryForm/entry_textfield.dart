import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart'; // For visibility icons

/// A *reusable* custom text field widget for user input.
class EntryTextField extends StatefulWidget {

  /// Controller for managing the input text
  final TextEditingController controller;

  /// Hint text displayed when the input is empty
  final String hintText;

  /// Label text displayed above the text field
  final String label;

  /// Determines whether the text is obscured
  final bool obscureText; 

  /// Icon to display inside the text field
  final dynamic icon;

  /// Optional helper text displayed below the text field
  final String? helperText;

  /// Determines whether to show the helper text
  final bool showHelper;

  /// Color for the helper text
  final Color? helperTextColor;
  
  /// Whether the field has an error
  final bool hasError;

  const EntryTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.label,
    required this.obscureText,
    required this.icon,
    this.helperText,
    this.showHelper = false,
    this.helperTextColor,
    this.hasError = false,
  });

  @override
  State<EntryTextField> createState() => _EntryTextFieldState();
}

class _EntryTextFieldState extends State<EntryTextField> {
  // Add this variable to control password visibility
  bool _showPassword = false;

  // FocusNode to track focus state of the text field
  final FocusNode _focusNode = FocusNode();

  // Tracks whether the text field is focused
  bool _isFocused = false;
  
  // Track if the field has text
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    
    // Check initial text
    _hasText = widget.controller.text.isNotEmpty;
    
    // Listen for focus changes
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    
    // Listen for text changes
    widget.controller.addListener(_updateTextState);
  }
  
  void _updateTextState() {
    final newHasText = widget.controller.text.isNotEmpty;
    if (_hasText != newHasText) {
      setState(() {
        _hasText = newHasText;
      });
    }
  }

  // Clean up the focus node and controller listeners when the widget is removed.
  @override
  void dispose() {
    widget.controller.removeListener(_updateTextState);
    _focusNode.dispose();
    super.dispose();
  }
  
  // Get the appropriate color based on focus, text state, and error state
  Color _getIconColor() {
    if (widget.hasError) {
      return MainTheme.redWarning;
    } else if (_isFocused || _hasText) {
      return MainTheme.textfieldFocus;
    }
    return MainTheme.placeholderText;
  }
  
  // Get border color based on state
  Color _getBorderColor() {
    if (widget.hasError) {
      return MainTheme.redWarning;
    } else if (_isFocused || _hasText) {
      return MainTheme.textfieldFocus;
    }
    return MainTheme.textfieldBorder;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Horizontal padding for alignment.
      padding: const EdgeInsets.symmetric(horizontal: 40.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label displayed above the text field.
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'BaiJamjuree',
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // The text field with icon and focus styling
          Container(
            decoration: BoxDecoration(
              // Subtle shadow effect.
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              // Use _showPassword to control password visibility
              obscureText: widget.obscureText && !_showPassword,
              decoration: InputDecoration(
                // Default border
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    // Change border color based on state
                    color: _getBorderColor(),
                    width: widget.hasError ? 1.5 : 1.0,
                  ), 
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),

                // Focused border.
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.hasError ? MainTheme.redWarning : MainTheme.textfieldFocus,
                    width: widget.hasError ? 1.5 : 1.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),

                // color for textfield
                fillColor: MainTheme.textfieldBackground,
                filled: true,

                hintText: widget.hintText,

                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: MainTheme.placeholderText, // Placeholder text color.
                  fontFamily: 'BaiJamjuree',
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.5,
                ),

                // Icon in text field
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Iconify(
                    // Display the provided icon
                    widget.icon, 
                    color: _getIconColor(), // Use our helper method
                    size: 20,
                  ),
                ),

                // Add suffix icon for password toggle
                suffixIcon: widget.obscureText ? 
                  IconButton(
                    splashRadius: 20,
                    icon: Iconify(
                      _showPassword ? Mdi.eye : Mdi.eye_off,
                      color: _getIconColor(), // Use our helper method
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ) : null,
              ),
            ),
          ),
          
          // Add helper text if provided and should be shown
          if (widget.showHelper && widget.helperText != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: Text(
                widget.helperText!,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'BaiJamjuree',
                  fontWeight: FontWeight.w400,
                  color: widget.helperTextColor ?? MainTheme.placeholderText, // Use provided color or default
                  letterSpacing: -0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

class EntryDatePicker extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String label;
  final String icon;

  const EntryDatePicker({
    super.key,
    required this.controller,
    required this.hintText,
    required this.label,
    required this.icon,
  });

  @override
  State<EntryDatePicker> createState() => _EntryDatePickerState();
}

class _EntryDatePickerState extends State<EntryDatePicker> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
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

  @override
  void dispose() {
    widget.controller.removeListener(_updateTextState);
    _focusNode.dispose();
    super.dispose();
  }
  
  // Get the appropriate color based on focus and text state
  Color _getIconColor() {
    // Use focus color if focused OR has text
    if (_isFocused || _hasText) {
      return MainTheme.textfieldFocus;
    }
    // Otherwise use the placeholder color
    return MainTheme.placeholderText;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: MainTheme.textfieldFocus,
              onPrimary: Colors.white,
              onSurface: MainTheme.mainText,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: MainTheme.textfieldFocus, 
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      // Format date as YYYY-MM-DD and update the controller
      widget.controller.text = picked.toString().split(' ')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'BaiJamjuree',
                fontWeight: FontWeight.w500,
                color: MainTheme.mainText,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: MainTheme.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    // Change border color when the field has text
                    color: _hasText ? MainTheme.textfieldFocus : MainTheme.textfieldBorder
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: MainTheme.textfieldFocus),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                fillColor: MainTheme.textfieldBackground,
                filled: true,
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: MainTheme.placeholderText,
                  fontFamily: 'BaiJamjuree',
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.5,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Iconify(
                    widget.icon, 
                    color: _getIconColor(), // Use our helper method
                    size: 20,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.calendar_month, 
                    color: _getIconColor(), // Match the icon color logic
                    size: 20,
                  ),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
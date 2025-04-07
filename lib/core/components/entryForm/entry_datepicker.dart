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

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: MainTheme.textfieldBorder),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
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
                    // Display the provided icon
                    widget.icon, 
                    color: _isFocused
                        ? MainTheme.textfieldFocus // Icon color when focused
                        : MainTheme.placeholderText, // Default icon color
                    size: 20,
                  ),
                ),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month, 
                    color: MainTheme.textfieldFocus, 
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
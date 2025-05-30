import 'package:flutter/material.dart';
import 'package:client/core/theme/theme.dart';

class EntryGenderPicker extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const EntryGenderPicker({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  State<EntryGenderPicker> createState() => _EntryGenderPickerState();
}

class _EntryGenderPickerState extends State<EntryGenderPicker> {
  String? _selectedGender;

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
      widget.controller.text = gender; // Update controller with selected gender
    });
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
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectGender('male'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedGender == 'male' 
                        ? MainTheme.maleButtonBackground 
                        : MainTheme.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedGender == 'male' 
                          ? MainTheme.maleButtonBackground 
                          : MainTheme.grey
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.male, 
                          color: _selectedGender == 'male' 
                            ? MainTheme.black 
                            : MainTheme.black
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'เพศชาย',
                          style: TextStyle(
                            color: _selectedGender == 'male' 
                              ? MainTheme.black 
                              : MainTheme.black,
                            fontFamily: 'BaiJamjuree',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectGender('female'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedGender == 'female' 
                        ? MainTheme.femaleButtonBackground 
                        : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedGender == 'female' 
                          ? MainTheme.femaleButtonBackground 
                          : MainTheme.grey
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.female, 
                          color: _selectedGender == 'female' 
                            ? MainTheme.black 
                            : MainTheme.black
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'เพศหญิง',
                          style: TextStyle(
                            color: _selectedGender == 'female' 
                              ? MainTheme.black 
                              : MainTheme.black,
                            fontFamily: 'BaiJamjuree',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
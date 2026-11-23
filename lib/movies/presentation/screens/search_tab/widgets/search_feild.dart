import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Search',
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        filled: true,
        // TODO: استبدلي اللون ده بـ AppColors
        fillColor: const Color(0xFF282A28),
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
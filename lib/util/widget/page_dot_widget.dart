import 'package:ak_api_test/constants.dart';
import 'package:flutter/material.dart';

class PagerDot extends StatelessWidget {
  const PagerDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 16 : 13,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.purple : const Color(0xFF34245D),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

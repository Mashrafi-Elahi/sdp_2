import 'package:flutter/material.dart';

class DiceFace extends StatelessWidget {
  final int value;
  final double size;

  const DiceFace({
    super.key,
    required this.value,
    this.size = 70.0,
  });

  Widget _dot(bool visible) {
    return Opacity(
      opacity: visible ? 1.0 : 0.0,
      child: Container(
        width: size * 0.2,
        height: size * 0.2,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF8DE273), // Teacher's light green
        borderRadius: BorderRadius.circular(size * 0.15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_dot(value > 1), _dot(false), _dot(value > 3)],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_dot(value == 6), _dot(value % 2 == 1), _dot(value == 6)],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_dot(value > 3), _dot(false), _dot(value > 1)],
          ),
        ],
      ),
    );
  }
}

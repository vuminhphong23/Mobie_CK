import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ForwardIcon extends StatelessWidget {
  final Function() onTap;
  const ForwardIcon({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(Ionicons.chevron_forward_outline, color: Colors.grey,),
      ),
    );
  }
}

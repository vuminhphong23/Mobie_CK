
import 'package:flutter/material.dart';

class weatherItem extends StatelessWidget {
  const weatherItem({
    Key? key,
    required this.value, required this.text, required this.unit, required this.imageUrl,
  }) : super(key: key);

  final dynamic value;
  final String text;
  final String unit;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(text, style: const TextStyle(
          color: Color(0xff04225b),
          fontSize: 16,
        ),),
        const SizedBox(
          height: 5,
        ),
        Container(
          padding: const EdgeInsets.all(10.0),
          height: 60,
          width: 60,
          decoration: const BoxDecoration(
            color: Color(0xffE0E8FB),
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Image.asset(imageUrl),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(value.toString() + unit, style: const TextStyle(
          fontSize: 16,
          color: Color(0xff04225b),
        ),)
      ],
    );
  }
}
import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final IconData? iconData;
  final void Function()? onPressed;

  const MyTextBox({
    Key? key,
    required this.text,
    required this.sectionName,
    this.iconData,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.only(left: 15, bottom: 15),
      margin: EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Row(
        children: [
          if (iconData != null)
            Padding(
              padding: const EdgeInsets.only( right: 10,top: 15),
              child: Icon(
                iconData,
                color: Colors.grey[400],
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sectionName,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(text),
              ],
            ),
          ),
          if (onPressed != null)
            Padding(
              padding: const EdgeInsets.only( left: 10,top: 15),
              child: IconButton(
                onPressed: onPressed,
                icon: Icon(Icons.settings),
                color: Colors.grey[400],
              ),
            ),
        ],
      ),
    );
  }
}

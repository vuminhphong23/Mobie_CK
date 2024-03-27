import 'package:flutter/material.dart';

class PostAppBar extends StatelessWidget {
  final String name;
  const PostAppBar({required this.name});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            height: 50,
            child: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 6,
                    )
                  ]
                ),
                child: Icon(
                  Icons.arrow_back,
                  size: 28,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Color(0xFFF65959),
                size: 35,
              ),
              Text(
                name,
                style: TextStyle(fontSize: 21,fontWeight: FontWeight.w500),
              )
            ],
          ),
          Container(
            width: 50,
            height: 50,
            child: InkWell(
              onTap: (){},
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 6,
                      )
                    ]
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

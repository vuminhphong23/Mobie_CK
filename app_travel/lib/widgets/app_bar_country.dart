import 'package:flutter/material.dart';

import '../pages/cities_of_country.dart';
import '../pages/comment_page.dart';

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
          InkWell(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PostComment()));
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                    )
                  ]
              ),
              child: Icon(
                Icons.comment,
                color: Colors.redAccent,
                size: 28,
              ),
            ),
          ),

          Container(
            width: 50,
            height: 50,
            child: InkWell(
              onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CityListScreen(countryName: name),
                    ),
                  );
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
                  Icons.library_add,
                  color: Colors.blueAccent,
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

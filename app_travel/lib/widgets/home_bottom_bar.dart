
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/interfaces.dart';

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInterface>(
      builder: (context, ui, child) {
        return Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: ui.appBarColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Navigator.pushNamed(context, "favoritesPage"),
                child: Icon(
                  Icons.favorite_outline,
                  color: Colors.black,
                  size: 30,
                ),
              ),
              InkWell(
                onTap: () => Navigator.pushNamed(context, "homePage"),
                child: Icon(
                  Icons.home,
                  color: Colors.black,
                  size: 40,
                ),
              ),

              InkWell(
                onTap: () => Navigator.pushNamed(context, "settingsPage"),
                child: Icon(
                  Icons.settings_outlined,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

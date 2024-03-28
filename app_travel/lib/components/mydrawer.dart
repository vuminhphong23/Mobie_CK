import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

import '../login/signin_screen.dart';
import '../models/interfaces.dart';
import 'setting_items.dart';


class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserInterface>(
        builder: (context, ui, child) {
          return Drawer(

            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: ui.appBarColor,
                  ),
                  child: Container(
                    child:Row(
                      children: [
                        GestureDetector(
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white, size: 50),
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'shoemaker@gmail.com',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, "homePage"),
                        child: SettingItem(
                          title: "Home",
                          icon: Ionicons.home,
                          bgColor: Colors.purple.shade100,
                          iconColor: Colors.purple,
                          onTap: () => Navigator.pushNamed(context, "homePage"),
                        ),
                      ),
                      SizedBox(height: 10,),
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, "favoritesPage"),
                        child: SettingItem(
                          title: "Favorites",
                          icon: Icons.favorite_outline,
                          bgColor: Colors.blue.shade100,
                          iconColor: Colors.blue,
                          onTap: () => Navigator.pushNamed(context, "favoritesPage"),
                        ),
                      ),
                      SizedBox(height: 10,),
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, "settingsPage"),
                        child: SettingItem(
                          title: "Settings",
                          icon: Ionicons.settings_outline,
                          bgColor: Colors.orange.shade100,
                          iconColor: Colors.orange,
                          onTap: () => Navigator.pushNamed(context, "settingsPage"),
                        ),
                      ),
                      InkWell(
                        onTap: () => {
                          FirebaseAuth.instance.signOut().then((value) {
                            print("Signed Out");
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                          }),
                        },
                        child: SettingItem(
                          title: "Logout",
                          icon: Ionicons.log_out,
                          bgColor: Colors.red.shade100,
                          iconColor: Colors.red,
                          onTap: () => {
                            FirebaseAuth.instance.signOut().then((value) {
                              print("Signed Out");
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                            }),
                          },
                        ),
                      ),

                    ],
                  ),
                ),

              ],
            ),
          );
        }
    );
  }
}
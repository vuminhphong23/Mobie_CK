import 'package:app_travel/login/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../login/signin_screen.dart';
import '../models/interfaces.dart';
import 'setting_items.dart';


class MyDrawer extends StatefulWidget {

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  late String userName = '';
  Future<String> getUserName(String email) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(email)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        return userData?['username'] ?? '';
      } else {
        return '';
      }
    } catch (e) {
      print('Error getting user name: $e');
      return '';
    }
  }
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
                        Container(
                          width: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FutureBuilder<String>(
                                future: getUserName(currentUser.email!),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator(); // Hiển thị loading khi đang lấy dữ liệu
                                  } else {
                                    if (snapshot.hasError) {
                                      return Text('Error getting username'); // Hiển thị thông báo lỗi nếu có lỗi xảy ra
                                    } else {
                                      return Text(
                                        snapshot.data ?? '', // Sử dụng dữ liệu trả về từ snapshot
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              Text(
                                currentUser.email!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),


                            ],
                          ),
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
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) =>  SignInScreen()),
                                (Route<dynamic> route) => false,
                          );
                        },

                        child: SettingItem(
                          title: "Logout",
                          icon: Ionicons.log_out,
                          bgColor: Colors.red.shade100,
                          iconColor: Colors.red,
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) =>  SignInScreen()),
                                  (Route<dynamic> route) => false,
                            );
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
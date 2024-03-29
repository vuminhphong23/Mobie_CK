
import 'package:app_travel/pages/profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../components/forward_icon.dart';
import '../components/setting_items.dart';
import '../models/interfaces.dart';
import 'package:firebase_auth/firebase_auth.dart';



class SettingsPage extends StatefulWidget {

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<UserInterface>(
        builder: (context, ui, child) {
          return Scaffold(
            // drawer: MyDrawer(),
            appBar: AppBar(
              title: Text('Settings',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
              backgroundColor: Colors.transparent,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (currentUser != null) // Use if condition instead of ternary operator
                      SizedBox(
                        width: double.infinity,
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFFF5F9FD),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF475269)
                                        .withOpacity(0.3),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person,
                                size: 45,
                                color: Color(0xFF475269),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentUser!.email!.length <= 20 ? currentUser!.email! : currentUser!.email!.substring(0, 17) + '...',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                            SizedBox(width: 13,),
                            ForwardIcon(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProfilePage())),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        "No user logged in",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            Provider.of<UserInterface>(context, listen: false).resetSettings();
                          },
                          child: Text(
                            "Reset",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purple.shade100,
                            ),
                            child: Icon(
                              Ionicons.logo_firefox,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            "Dark Mode",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            Provider
                                .of<UserInterface>(context)
                                .themeMode == ThemeMode.dark ? "Dark" : "Light",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF475269),
                            ),
                          ),
                          const SizedBox(width: 10),

                          Switch(
                            value: Provider
                                .of<UserInterface>(context)
                                .themeMode == ThemeMode.dark,
                            onChanged: (value) {
                              ThemeMode newThemeMode = value
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                              Provider
                                  .of<UserInterface>(context, listen: false)
                                  .themeMode = newThemeMode;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    SettingItem(
                      title: "Languages",
                      icon: Ionicons.earth,
                      bgColor: Colors.orange.shade100,
                      iconColor: Colors.orange,
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    SettingItem(
                      title: "Notifications",
                      icon: Ionicons.notifications,
                      bgColor: Colors.blue.shade100,
                      iconColor: Colors.blue,
                      onTap: () {},
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.shade100,
                            ),
                            child: Icon(
                              Ionicons.nuclear,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            "Colors",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),

                          const SizedBox(width: 20),
                          Container(
                              child: DropdownButton<String>(
                                value: ui.strAppBarColor,
                                items: UserInterface.listColorAppBar.map<
                                    DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,style: TextStyle(color: Color(0xFF475269), fontWeight: FontWeight.w400),),
                                      );
                                    }
                                ).toList(),
                                onChanged: (String? value) {
                                  ui.appBarColor = value!;
                                },
                              )
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    InkWell(
                      onTap: () => Navigator.pushNamed(context, "/"),
                      child: SettingItem(
                        title: "Logout",
                        icon: Ionicons.log_out,
                        bgColor: Colors.red.shade100,
                        iconColor: Colors.red,
                        onTap: () => Navigator.pushNamed(context, "/"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // bottomNavigationBar: HomeBottomBar(),
          );
        }
    );
  }

}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/mydrawer.dart';
import '../widgets/textbox.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> editField(String field) async
  {
    String newValue ="";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Edit $field",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            autofocus: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: TextStyle(color: Colors.grey),
            ),
            onChanged: (value){
              newValue = value;
            },
          ),
          actions: [
            TextButton(
                onPressed:() => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.white),)
            ),

            TextButton(
                onPressed:() => Navigator.of(context).pop(newValue),
                child: Text('Save', style: TextStyle(color: Colors.white),)
            )
          ],
        )
    );

    if(newValue.trim().length > 0)
    {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 28),),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.email).snapshots(),
        builder: (context, snapshot) {
          if(snapshot.hasData){
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                SizedBox(height: 50,),
                Container(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 35,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.black38,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700],fontWeight: FontWeight.bold,fontSize: 16),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Text(
                    'My Details',
                    style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),
                  ),
                ),
                MyTextBox(
                  text: userData['username'],
                  iconData: Icons.verified_user,
                  sectionName: 'Username',
                  onPressed: () => editField('username'),
                ),
                MyTextBox(
                  text: userData['phone'],
                  iconData: Icons.phone,
                  sectionName: 'Phone',
                  onPressed: () => editField('phone'),
                ),
                MyTextBox(
                  text: userData['sex'],
                  iconData: Icons.add,
                  sectionName: 'Sex',
                  onPressed: () => editField('sex'),
                ),
                MyTextBox(
                  text: userData['address'],
                  iconData: Icons.location_on,
                  sectionName: 'Address',
                  onPressed: () => editField('address'),
                )

              ],
            );
          } else if (snapshot.hasError){
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
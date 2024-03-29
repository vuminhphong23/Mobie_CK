

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/wall_post.dart';

class PostComment extends StatefulWidget {
  const PostComment({super.key});

  @override
  State<PostComment> createState() => _PostCommentState();
}

class _PostCommentState extends State<PostComment> {

  final currentUser = FirebaseAuth.instance.currentUser;

  final textController = TextEditingController();

  //Post Comment
  void postMessage(){
    if(textController.text.isNotEmpty){
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser!.email!,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    setState(() {
      textController.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Post Comment',
          style: TextStyle(color: Colors.white) ,
        ),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          children: [

            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: false).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index){
                        final post = snapshot.data!.docs[index];
                        return WallPost(
                          message: post['Message'],
                          user: post['UserEmail'],
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                        );
                      },
                    );
                  } else if(snapshot.hasError){
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center (
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      obscureText: false,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.black.withOpacity(0.5)),
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                        filled: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Colors.white.withOpacity(0.3),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
                      ),
                    ),
                  ),

                  IconButton(onPressed: postMessage, icon: const Icon(Icons.arrow_circle_up))
                ],
              ),
            ),

            Text("Loggin in as: " + currentUser!.email!, style: TextStyle(color: Colors.grey),),
            SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }
}
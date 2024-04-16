
import '../components/like_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;


  const WallPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {

  final currentUser = FirebaseAuth.instance.currentUser;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser?.email);
  }

  void toggleLike(){
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
    FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser?.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser?.email])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Row(
        children: [

          Column(
            children: [
              LikeButton(isLiked: isLiked, onTap: toggleLike),

              SizedBox(height: 5,),

              Text(
                widget.likes.length.toString(),
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),

          SizedBox(width: 20,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 10,),
              Text(widget.message),
            ],
          )
        ],
      ),
    );
  }
}
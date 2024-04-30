import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/models/post_comments.dart';
import 'package:social_media_app/utils/collection_names.dart';
import 'package:social_media_app/utils/field_names.dart';

class PostCommentServices {
  final currentUser = FirebaseAuth.instance.currentUser;
  final CollectionReference _postCommentsCollection = FirebaseFirestore.instance
      .collection(FirestoreCollectionNames.postComments);

  Future<void> addPostComment(String postId, String comment) async {
    try {
      PostComments newComment = PostComments(
        postId: postId,
        uid: currentUser!.uid,
        commentText: comment,
        commentCreatedTime: Timestamp.now(),
      );
      await _postCommentsCollection.add(newComment.asMap());
    } catch (e) {
      // ignore: avoid_print
      print("addPostComment ERROR ---> $e");
    }
  }

  Stream<List<PostComments>> getPostComments(String postId) {
    return _postCommentsCollection
        .where(DocumentFieldNames.postId, isEqualTo: postId)
        .orderBy(DocumentFieldNames.commentCreatedTime, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostComments.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}

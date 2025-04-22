import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urms_ulab/models/post_model.dart';
import 'package:urms_ulab/models/profile_model.dart'; // Firestore package

class FirebaseNotifier extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProfile(Profile profile) async {
    try {
      final docRef = _firestore.collection('profiles').doc(profile.studentId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set(profile.toMap());
        notifyListeners();
      } else {
        debugPrint(
            'Profile with studentId ${profile.studentId} already exists.');
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  Future<Profile?> getProfileById(String id) async {
    try {
      final doc = await _firestore.collection('profiles').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return Profile.fromMap(data);
      } else {
        debugPrint('No profile found for id: $id');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  Future<void> createpost({required PostModel post}) async {
    log(post.toString());
    try {
      final docRef = _firestore.collection('posts').doc(post.postId);
      await docRef.set(post.toMap());
    } catch (e) {
      debugPrint('Error saving post: $e');
    }
  }

  Future<void> deletePost({required String postID}) async {
    try {
      final docRef = _firestore.collection('posts').doc(postID);
      await docRef.delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting post: $e');
    }
  }

  Future<void> updatePost(
      {required String postID, required PostModel updatedData}) async {
    try {
      final docRef = _firestore.collection('posts').doc(postID);
      await docRef.update(updatedData.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating post: $e');
    }
  }

  Stream<List<PostModel>> getAllPostbyProfileID({required String profileID}) {
    return _firestore
        .collection('posts')
        .where('postCreatorID', isEqualTo: profileID)
        .orderBy('postCreatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());
  }

  Stream<List<PostModel>> getAllPost() {
    return _firestore
        .collection('posts')
        .orderBy('postCreatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromMap(doc.data())).toList());
  }

  Stream<PostModel?> getPostByPostID(String postID) {
    return _firestore.collection('posts').doc(postID).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return PostModel.fromMap(data);
      } else {
        debugPrint('No post found for postID: $postID');
        return null;
      }
    });
  }

  
}

final firebaseProvider = ChangeNotifierProvider(
  (ref) => FirebaseNotifier(),
);

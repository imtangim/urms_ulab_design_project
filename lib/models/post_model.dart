// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class PostModel {
  final String postId;
  final String postDescription;
  final List<String> postReactorIDs;
  final List<String> postCommentIDs;
  final String postCreatorID;
  final DateTime postCreatedAt;

  PostModel({
    String? postId,
    List<String>? postReactorIDs,
    List<String>? postCommentIDs,
    required this.postDescription,
    required this.postCreatorID,
    DateTime? postCreatedAt,
  })  : postId = postId ?? Uuid().v4(),
        postCreatedAt = postCreatedAt ?? DateTime.now(),
        postReactorIDs = postReactorIDs ?? [],
        postCommentIDs = postCommentIDs ?? [],
        assert(postDescription.isNotEmpty, "Post description cannot be empty"),
        assert(postCreatorID.isNotEmpty, "Post creator ID cannot be empty");

  PostModel copyWith({
    String? postId,
    String? postDescription,
    List<String>? postReactorIDs,
    List<String>? postCommentIDs,
    String? postCreatorID,
    DateTime? postCreatedAt,
  }) {
    return PostModel(
        postId: postId ?? this.postId,
        postDescription: postDescription ?? this.postDescription,
        postReactorIDs: postReactorIDs ?? this.postReactorIDs,
        postCommentIDs: postCommentIDs ?? this.postCommentIDs,
        postCreatorID: postCreatorID ?? this.postCreatorID,
        postCreatedAt: postCreatedAt ?? this.postCreatedAt);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'postId': postId,
      'postDescription': postDescription,
      'postReactorIDs': postReactorIDs,
      'postCommentIDs': postCommentIDs,
      'postCreatorID': postCreatorID,
      'postCreatedAt': postCreatedAt.toIso8601String(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] as String,
      postDescription: map['postDescription'] as String,
      postReactorIDs: List<String>.from(
        (map['postReactorIDs'] as List),
      ),
      postCommentIDs: List<String>.from(
        (map['postCommentIDs'] as List),
      ),
      postCreatorID: map['postCreatorID'] as String,
      postCreatedAt: DateTime.parse(map['postCreatedAt'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostModel(postId: $postId, postDescription: $postDescription, postReactorIDs: $postReactorIDs, postCommentIDs: $postCommentIDs, postCreatorID: $postCreatorID)';
  }

  @override
  bool operator ==(covariant PostModel other) {
    if (identical(this, other)) return true;

    return other.postId == postId &&
        other.postDescription == postDescription &&
        listEquals(other.postReactorIDs, postReactorIDs) &&
        listEquals(other.postCommentIDs, postCommentIDs) &&
        other.postCreatorID == postCreatorID;
  }

  @override
  int get hashCode {
    return postId.hashCode ^
        postDescription.hashCode ^
        postReactorIDs.hashCode ^
        postCommentIDs.hashCode ^
        postCreatorID.hashCode;
  }
}

class Comment {
  final String commentID;
  final String comment;
  final String userID;
  final String postID;
  final List<String> commentReactorIDs;
  Comment({
    String? commentID,
    required this.comment,
    required this.userID,
    List<String>? commentReactorIDs,
    required this.postID,
  })  : commentReactorIDs = commentReactorIDs ?? [],
        commentID = commentID ?? Uuid().v4(),
        assert(comment.isNotEmpty, "Comment cannot be empty"),
        assert(userID.isNotEmpty, "User ID cannot be empty");
}

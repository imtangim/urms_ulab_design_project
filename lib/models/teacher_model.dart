// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Teacher {
  final String teacherId;
  final String teacherName;
  final String email;
  final String photo;
  final String phone;
  final List<Education> education;
  final String designation;
  final List<Reviews> reviews;

  Teacher({
    required this.teacherId,
    required this.teacherName,
    required this.email,
    required this.photo,
    required this.phone,
    required this.education,
    required this.designation,
    List<Reviews>? reviews,
  }) : reviews = reviews ?? [];

  factory Teacher.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Teacher(
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teacherName'] ?? '',
      email: data['email'] ?? '',
      photo: data['photo'] ?? '',
      phone: data['phone'] ?? '',
      education: (data['education'] as List?)
              ?.map((e) => Education.fromMap(e))
              .toList() ??
          [],
      designation: data['designation'] ?? '',
      reviews:
          (data['reviews'] as List?)?.map((e) => Reviews.fromMap(e)).toList() ??
              [],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'teacherId': teacherId,
      'teacherName': teacherName,
      'email': email,
      'photo': photo,
      'phone': phone,
      'education': education.map((x) => x.toMap()).toList(),
      'designation': designation,
      'reviews': reviews.map((x) => x.toMap()).toList(),
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      teacherId: map['teacherId'] as String,
      teacherName: map['teacherName'] as String,
      email: map['email'] as String,
      photo: map['photo'] as String,
      phone: map['phone'] as String,
      education: List<Education>.from(
        (map['education'] ?? []).map<Education>(
          (x) => Education.fromMap(x as Map<String, dynamic>),
        ),
      ),
      designation: map['designation'] as String,
      reviews: List<Reviews>.from(
        (map['reviews'] ?? []).map<Reviews>(
          (x) => Reviews.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Teacher.fromJson(String source) =>
      Teacher.fromMap(json.decode(source) as Map<String, dynamic>);

  Teacher copyWith({
    String? teacherId,
    String? teacherName,
    String? email,
    String? photo,
    String? phone,
    List<Education>? education,
    String? designation,
    List<Reviews>? reviews,
  }) {
    return Teacher(
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      phone: phone ?? this.phone,
      education: education ?? this.education,
      designation: designation ?? this.designation,
      reviews: reviews ?? this.reviews,
    );
  }
}

class Education {
  final String degree;
  final String institution;

  Education({required this.degree, required this.institution});

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      degree: map['degree'] as String,
      institution: map['institution'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'degree': degree,
      'institution': institution,
    };
  }

  String toJson() => json.encode(toMap());

  factory Education.fromJson(String source) =>
      Education.fromMap(json.decode(source) as Map<String, dynamic>);

  Education copyWith({
    String? degree,
    String? institution,
  }) {
    return Education(
      degree: degree ?? this.degree,
      institution: institution ?? this.institution,
    );
  }
}

class Reviews {
  final String reviewId;
  final String reviewerId;
  final String reviewText;
  final int rating;
  final bool isAnonymous;
  final List<String> helpfulIDs;
  final List<String> nothelpfulIDs;
  Reviews(
 {
    required this.reviewId,
    required this.reviewerId,
    required this.reviewText,
    required this.rating,
    required this.isAnonymous,
    required    this.helpfulIDs,
   required this.nothelpfulIDs,
  });

  Reviews copyWith({
    String? reviewId,
    String? reviewerId,
    String? reviewText,
    int? rating,
    bool? isAnonymous,
    List<String>? helpfulIDs,
    List<String>? nothelpfulIDs,
  }) {
    return Reviews(
      reviewId: reviewId ?? this.reviewId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewText: reviewText ?? this.reviewText,
      rating: rating ?? this.rating,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      helpfulIDs: helpfulIDs ?? this.helpfulIDs,
      nothelpfulIDs:   nothelpfulIDs ?? this.nothelpfulIDs, 
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'reviewId': reviewId,
      'reviewerId': reviewerId,
      'reviewText': reviewText,
      'rating': rating,
      'isAnonymous': isAnonymous,
      'helpfulIDs': helpfulIDs, 
      'nothelpfulIDs': nothelpfulIDs,
    };
  }

  factory Reviews.fromMap(Map<String, dynamic> map) {
    return Reviews(
      reviewId: map['reviewId'] as String,
      reviewerId: map['reviewerId'] as String,
      reviewText: map['reviewText'] as String,
      rating: map['rating'] as int,
      isAnonymous: map['isAnonymous'] as bool,
      helpfulIDs: List<String>.from(map['helpfulIDs'] ?? []),
      nothelpfulIDs: List<String>.from(map['nothelpfulIDs'] ?? []), 
    );
  }
}

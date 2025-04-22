import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urms_ulab/models/teacher_model.dart';

class TeachersNotifier extends StateNotifier<AsyncValue<List<Teacher>>> {
  TeachersNotifier() : super(const AsyncValue.loading()) {
    loadInitialTeachers();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;
  final int _pageSize = 10;

  Future<void> loadInitialTeachers() async {
    try {
      final querySnapshot = await _firestore
          .collection('teachers')
          .orderBy('teacherName')
          .limit(_pageSize)
          .get();

      if (querySnapshot.docs.isEmpty) {
        state = const AsyncValue.data([]);
        _hasMoreData = false;
        return;
      }

      _lastDocument = querySnapshot.docs.last;
      final teachers =
          querySnapshot.docs.map((doc) => Teacher.fromFirestore(doc)).toList();

      state = AsyncValue.data(teachers);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadMoreTeachers() async {
    if (!_hasMoreData) return;

    try {
      final currentState = state;
      if (currentState is! AsyncData<List<Teacher>>) return;

      final querySnapshot = await _firestore
          .collection('teachers')
          .orderBy('teacherName')
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _hasMoreData = false;
        return;
      }

      _lastDocument = querySnapshot.docs.last;
      final newTeachers =
          querySnapshot.docs.map((doc) => Teacher.fromFirestore(doc)).toList();

      state = AsyncValue.data([...currentState.value, ...newTeachers]);
    } catch (e) {
      // We don't update state here to preserve current data
      debugPrint('Error loading more teachers: $e');
    }
  }

  Future<void> updateTeacher(String teacherId, Teacher updatedData) async {
    try {
      // 1. Update Firestore document
      await _firestore
          .collection('teachers')
          .doc(teacherId)
          .update(updatedData.toMap());

      // 2. Update local state
      final currentState = state;
      if (currentState is AsyncData<List<Teacher>>) {
        final updatedTeachers = currentState.value.map((teacher) {
          if (teacher.teacherId == teacherId) {
            return teacher.copyWith(
              teacherName: updatedData.teacherName,
              email: updatedData.email,
              photo: updatedData.photo,
              phone: updatedData.phone,
              education: updatedData.education,
              designation: updatedData.designation,
              reviews: updatedData.reviews,
            );
          }
          return teacher;
        }).toList();

        state = AsyncValue.data(updatedTeachers);
      }
    } catch (e) {
      debugPrint('Error updating teacher: $e');
    }
  }

  Stream<Teacher> getTeacherById(String teacherId) {
    return _firestore
        .collection('teachers')
        .doc(teacherId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Teacher.fromFirestore(snapshot);
      } else {
        throw Exception('Teacher not found');
      }
    });
  }

  Future<void> deleteReview(String teacherId, String reviewId) async {
    try {
      // 1. Update Firestore document
      final teacherDoc = _firestore.collection('teachers').doc(teacherId);
      final teacherSnapshot = await teacherDoc.get();

      if (!teacherSnapshot.exists) {
        throw Exception('Teacher not found');
      }

      final teacherData = teacherSnapshot.data() as Map<String, dynamic>;
      final reviews =
          List<Map<String, dynamic>>.from(teacherData['reviews'] ?? []);

      final updatedReviews =
          reviews.where((review) => review['reviewId'] != reviewId).toList();

      await teacherDoc.update({'reviews': updatedReviews});

      // 2. Update local state
      final currentState = state;
      if (currentState is AsyncData<List<Teacher>>) {
        final updatedTeachers = currentState.value.map((teacher) {
          if (teacher.teacherId == teacherId) {
            return teacher.copyWith(
              reviews: (updatedReviews
                  .map((review) => Reviews.fromMap(review))
                  .toList()),
            );
          }
          return teacher;
        }).toList();

        state = AsyncValue.data(updatedTeachers);
      }
    } catch (e) {
      debugPrint('Error deleting review: $e');
    }
  }

  bool get hasMoreData => _hasMoreData;
}

// Providers
final teachersProvider =
    StateNotifierProvider<TeachersNotifier, AsyncValue<List<Teacher>>>(
  (ref) => TeachersNotifier(),
);

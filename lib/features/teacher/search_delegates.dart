import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urms_ulab/features/teacher/teacher_detail_screen.dart';
import 'package:urms_ulab/models/teacher_model.dart';

class TeacherSearchDelegate extends SearchDelegate<Teacher?> {
  final WidgetRef ref;

  TeacherSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Teacher>>(
      future: searchTeachers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final teachers = snapshot.data ?? [];

        if (teachers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No teachers found matching "$query"',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return InkWell(
              onTap: () {
                close(context, teacher);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherDetailScreen(teacher: teacher),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(teacher.photo),
                      onBackgroundImageError: (exception, stackTrace) {},
                      child: teacher.photo.isEmpty
                          ? Text(
                              teacher.teacherName.isNotEmpty
                                  ? teacher.teacherName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher.teacherName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            teacher.designation,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Teacher>> searchTeachers(String searchQuery) async {
    if (searchQuery.trim().isEmpty) {
      return [];
    }

    log(searchQuery);

    final query = searchQuery.trim();
    final results = <Teacher>[];

    try {
      // Create a batch of queries to search across different fields
      // We'll use separate queries instead of complex compound queries

      // Search in name field
      final nameQuerySnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('searchName', arrayContains: query.toLowerCase())
          .limit(20)
          .get();

      // Add results to our list
      for (final doc in nameQuerySnapshot.docs) {
        final teacher = Teacher.fromFirestore(doc);
        // Use a Set or Map to prevent duplicates
        if (!results.any((t) => t.teacherId == teacher.teacherId)) {
          results.add(teacher);
        }
      }

      // Search in email field
      if (results.length < 20) {
        final emailQuerySnapshot = await FirebaseFirestore.instance
            .collection('teachers')
            .where('email', isGreaterThanOrEqualTo: query.toLowerCase())
            .where('email', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
            .limit(20 - results.length)
            .get();

        for (final doc in emailQuerySnapshot.docs) {
          final teacher = Teacher.fromFirestore(doc);
          if (!results.any((t) => t.teacherId == teacher.teacherId)) {
            results.add(teacher);
          }
        }
      }

      // Search in designation field
      if (results.length < 20) {
        final designationQuerySnapshot = await FirebaseFirestore.instance
            .collection('teachers')
            .where('designationLower',
                isGreaterThanOrEqualTo: query.toLowerCase())
            .where('designationLower',
                isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
            .limit(20 - results.length)
            .get();

        for (final doc in designationQuerySnapshot.docs) {
          final teacher = Teacher.fromFirestore(doc);
          if (!results.any((t) => t.teacherId == teacher.teacherId)) {
            results.add(teacher);
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('Error searching teachers: $e');
      // If the specific queries fail, fall back to a simpler approach
      try {
        // Simple fallback search
        final fallbackSnapshot = await FirebaseFirestore.instance
            .collection('teachers')
            .orderBy('teachername')
            .limit(20)
            .get();

        return fallbackSnapshot.docs
            .map((doc) => Teacher.fromFirestore(doc))
            .where((teacher) {
          final searchableText =
              '${teacher.teacherName} ${teacher.email} ${teacher.designation}'
                  .toLowerCase();
          return searchableText.contains(query.toLowerCase());
        }).toList();
      } catch (fallbackError) {
        debugPrint('Fallback search error: $fallbackError');
        return [];
      }
    }
  }
}

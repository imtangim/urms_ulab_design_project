import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/features/teacher/widget/contact_info_tile.dart';
import 'package:urms_ulab/features/teacher/widget/review_screen.dart';
import 'package:urms_ulab/models/teacher_model.dart';
import 'package:urms_ulab/provider/firebase_provider.dart';
import 'package:urms_ulab/provider/shared_preference_provider.dart';
import 'package:urms_ulab/provider/teacher_provider.dart';

class TeacherDetailScreen extends ConsumerStatefulWidget {
  final Teacher teacher;

  const TeacherDetailScreen({super.key, required this.teacher});

  @override
  ConsumerState<TeacherDetailScreen> createState() =>
      _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends ConsumerState<TeacherDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: ref
            .read(teachersProvider.notifier)
            .getTeacherById(widget.teacher.teacherId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Faculty Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                centerTitle: false,
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
              ),
              body: Center(
                child: CircularProgressIndicator(
                  color: Appcolor.primaryColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Faculty Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: Appcolor.buttonBackgroundColor,
                  foregroundColor: Appcolor.white,
                ),
                onPressed: () {
                  final studentId = ref.read(sharedPrefProvider).studentID!;
                  final hasReviewed = snapshot.data!.reviews.any(
                    (review) => review.reviewerId == studentId,
                  );

                  if (hasReviewed) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('You have already given a review.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    return;
                  }

                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(5),
                      ),
                    ),
                    builder: (context) {
                      return ReviewScreen(
                        teacher: widget.teacher,
                        teacherId: widget.teacher.teacherId,
                      );
                    },
                  );
                },
                child: Text("Give Review"),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.network(
                              widget.teacher.photo,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey.shade300,
                                  child: Text(
                                    snapshot.data != null
                                        ? snapshot.data!.teacherName[0]
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          snapshot.data!.teacherName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          snapshot.data!.designation,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ContactInfoTile(
                              icon: Icons.email_outlined,
                              title: 'Email',
                              subtitle: snapshot.data!.email,
                              iconColor: Colors.blue.shade700,
                            ),
                          ],
                        ),
                        const Divider(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ContactInfoTile(
                              icon: Icons.phone_outlined,
                              title: 'Phone',
                              subtitle: snapshot.data!.phone,
                              iconColor: Colors.green.shade700,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 10,
                          children: [
                            const Text(
                              'Education',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Column(
                              children: [
                                if (snapshot.data!.education.isEmpty)
                                  const Text(
                                      'No education information available')
                                else
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.education.length,
                                    itemBuilder: (context, index) {
                                      final education =
                                          snapshot.data!.education[index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.school_outlined,
                                                  size: 18,
                                                  color: Colors.amber.shade800,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    education.degree,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 28, top: 0),
                                              child: Text(
                                                education.institution,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          'Student Ratings',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          snapshot.data!.reviews.isEmpty
                              ? 'No ratings yet'
                              : 'Average Rating: ${(snapshot.data!.reviews.map((e) => e.rating).reduce((a, b) => a + b) / snapshot.data!.reviews.length).toStringAsFixed(1)} / 10',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    spacing: 10,
                    children: [
                      ...List.generate(
                        snapshot.data!.reviews.length,
                        (index) {
                          final review = snapshot.data!.reviews[index];
                          return ReviewCard(
                            teacher: snapshot.data!,
                            reviewId: review.reviewId,
                            reviewerId: review.reviewerId,
                            reviewText: review.reviewText,
                            rating: review.rating,
                            isAnonymous: review.isAnonymous,
                          );
                        },
                      )
                    ],
                  ),
                  if (snapshot.data!.reviews.isEmpty)
                    Center(
                      child: Text(
                        'No reviews yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Appcolor.greyLabelColor,
                        ),
                      ),
                    )
                ],
              ),
            ),
          );
        });
  }
}

class ReviewCard extends ConsumerWidget {
  final String reviewId;
  final String reviewerId;
  final String reviewText;
  final int rating;
  final bool isAnonymous;
  final Teacher teacher;
  const ReviewCard({
    super.key,
    required this.reviewId,
    required this.reviewerId,
    required this.reviewText,
    required this.rating,
    required this.isAnonymous,
    required this.teacher,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Appcolor.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Appcolor.primaryColor.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isAnonymous &&
                    reviewerId != ref.read(sharedPrefProvider).studentID)
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Appcolor.primaryColor.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          color: Appcolor.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Anonymous User",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Appcolor.textColor,
                        ),
                      ),
                    ],
                  )
                else
                  FutureBuilder(
                      future:
                          ref.read(firebaseProvider).getProfileById(reviewerId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Row(
                            spacing: 20,
                            children: [
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: CircleAvatar(
                                  backgroundColor: Appcolor.white,
                                ),
                              ),
                              Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  height: 30,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Appcolor.white,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: ClipOval(
                                child: Image.network(
                                  snapshot.data!.profileImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 70,
                                      height: 70,
                                      color: Appcolor.fillColor,
                                      child: Icon(
                                        Icons.person,
                                        size: 27,
                                        color: Appcolor.primaryColor,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data!.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Appcolor.textColor,
                                  ),
                                ),
                                if (isAnonymous)
                                  Text(
                                    'Only Showing you',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: Appcolor.greyLabelColor,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      }),
                TextButton(
                  onPressed: () async {
                    ref.read(teachersProvider.notifier).deleteReview(
                          teacher.teacherId,
                          reviewId,
                        );
                  },
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Appcolor.redColor,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  "$rating/10",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Appcolor.greyLabelColor,
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              reviewText,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Appcolor.greyLabelColor,
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: Appcolor.fillColor),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10,
              children: [
                GestureDetector(
                  onTap: () async {
                    final studentId = ref.read(sharedPrefProvider).studentID!;

                    final review = teacher.reviews.firstWhere(
                      (review) => review.reviewId == reviewId,
                    );

                    if (review.helpfulIDs.contains(studentId)) {
                      // Remove studentId from helpfulIDs
                      final updatedHelpfulIDs =
                          List<String>.from(review.helpfulIDs)
                            ..remove(studentId);

                      // Update reviews
                      final updatedReviews = teacher.reviews.map((r) {
                        if (r.reviewId == reviewId) {
                          return r.copyWith(helpfulIDs: updatedHelpfulIDs);
                        }
                        return r;
                      }).toList();

                      // Update teacher
                      await ref.read(teachersProvider.notifier).updateTeacher(
                            teacher.teacherId,
                            teacher.copyWith(reviews: updatedReviews),
                          );
                    } else {
                      // Ensure studentId is not in notHelpfulIDs
                      final updatedNotHelpfulIDs =
                          List<String>.from(review.nothelpfulIDs)
                            ..remove(studentId);

                      await ref.read(teachersProvider.notifier).updateTeacher(
                            teacher.teacherId,
                            teacher.copyWith(
                              reviews: teacher.reviews.map((r) {
                                if (r.reviewId == reviewId) {
                                  return r.copyWith(
                                    helpfulIDs: [
                                      ...r.helpfulIDs,
                                      studentId,
                                    ],
                                    nothelpfulIDs: updatedNotHelpfulIDs,
                                  );
                                }
                                return r;
                              }).toList(),
                            ),
                          );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        teacher.reviews
                                .firstWhere(
                                    (review) => review.reviewId == reviewId)
                                .helpfulIDs
                                .contains(
                                    ref.read(sharedPrefProvider).studentID!)
                            ? Icons.thumb_up_alt
                            : Icons.thumb_up_outlined,
                        size: 16,
                        color: Appcolor.greyLabelColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Helpful (${teacher.reviews.firstWhere((review) => review.reviewId == reviewId).helpfulIDs.length})",
                        style: TextStyle(
                          fontSize: 12,
                          color: Appcolor.greyLabelColor,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final studentId = ref.read(sharedPrefProvider).studentID!;

                    final review = teacher.reviews.firstWhere(
                      (review) => review.reviewId == reviewId,
                    );

                    if (review.nothelpfulIDs.contains(studentId)) {
                      // Remove studentId from notHelpfulIDs
                      final updatedNotHelpfulIDs =
                          List<String>.from(review.nothelpfulIDs)
                            ..remove(studentId);

                      // Update reviews
                      final updatedReviews = teacher.reviews.map((r) {
                        if (r.reviewId == reviewId) {
                          return r.copyWith(
                              nothelpfulIDs: updatedNotHelpfulIDs);
                        }
                        return r;
                      }).toList();

                      // Update teacher
                      await ref.read(teachersProvider.notifier).updateTeacher(
                            teacher.teacherId,
                            teacher.copyWith(reviews: updatedReviews),
                          );
                    } else {
                      // Ensure studentId is not in helpfulIDs
                      final updatedHelpfulIDs =
                          List<String>.from(review.helpfulIDs)
                            ..remove(studentId);

                      await ref.read(teachersProvider.notifier).updateTeacher(
                            teacher.teacherId,
                            teacher.copyWith(
                              reviews: teacher.reviews.map((r) {
                                if (r.reviewId == reviewId) {
                                  return r.copyWith(
                                    nothelpfulIDs: [
                                      ...r.nothelpfulIDs,
                                      studentId,
                                    ],
                                    helpfulIDs: updatedHelpfulIDs,
                                  );
                                }
                                return r;
                              }).toList(),
                            ),
                          );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(
                        teacher.reviews
                                .firstWhere(
                                    (review) => review.reviewId == reviewId)
                                .nothelpfulIDs
                                .contains(
                                    ref.read(sharedPrefProvider).studentID!)
                            ? Icons.thumb_down_alt
                            : Icons.thumb_down_alt_outlined,
                        size: 16,
                        color: Appcolor.greyLabelColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "Not Helpful (${teacher.reviews.firstWhere((review) => review.reviewId == reviewId).nothelpfulIDs.length})",
                        style: TextStyle(
                          fontSize: 12,
                          color: Appcolor.greyLabelColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  "ID: #${reviewId.substring(0, 6)}",
                  style: TextStyle(
                    fontSize: 10,
                    color: Appcolor.greyLabelColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

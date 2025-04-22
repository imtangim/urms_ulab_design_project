import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/models/teacher_model.dart';
import 'package:urms_ulab/provider/shared_preference_provider.dart';
import 'package:urms_ulab/provider/teacher_provider.dart';
import 'package:uuid/uuid.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String teacherId;
  final Teacher teacher;
  const ReviewScreen({
    super.key,
    required this.teacher,
    required this.teacherId,
  });

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _ratingController =
      TextEditingController(text: '5');
  bool _isAnonymous = false;
  String? _ratingError;

  @override
  void dispose() {
    _reviewController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _validateRating(String value) {
    setState(() {
      if (value.isEmpty) {
        _ratingError = 'Rating is required';
      } else {
        try {
          int rating = int.parse(value);
          if (rating < 1 || rating > 10) {
            _ratingError = 'Rating must be between 1 and 10';
          } else {
            _ratingError = null;
          }
        } catch (e) {
          _ratingError = 'Please enter a valid number';
        }
      }
    });
  }

  GlobalKey<FormState> key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Appcolor.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Write a Review',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Appcolor.textColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Appcolor.textColor),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating input
            Text(
              'Rating (1-10)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Appcolor.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Appcolor.fillColor,
                borderRadius: BorderRadius.circular(12),
                border: _ratingError != null
                    ? Border.all(color: Appcolor.redColor, width: 1)
                    : null,
              ),
              child: TextFormField(
                controller: _ratingController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: InputDecoration(
                  hintText: 'Enter rating from 1 to 10',
                  hintStyle: TextStyle(color: Appcolor.greyLabelColor),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  errorStyle: const TextStyle(
                      height: 0), // Hide the default error message
                ),
                onChanged: _validateRating,
              ),
            ),
            if (_ratingError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  _ratingError!,
                  style: TextStyle(
                    color: Appcolor.redColor,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Review text field
            Text(
              'Your Review',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Appcolor.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Appcolor.fillColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your review';
                  }
                  return null;
                },
                controller: _reviewController,
                maxLines: 5,
                cursorColor: Appcolor.textColor,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: TextStyle(color: Appcolor.greyLabelColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Anonymous switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Appcolor.fillColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Post Anonymously',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Appcolor.textColor,
                        ),
                      ),
                      Text(
                        'Your name will not be displayed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Appcolor.greyLabelColor,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value;
                      });
                    },
                    activeColor: Appcolor.primaryColor,
                    activeTrackColor: Appcolor.primaryColor.withOpacity(0.5),
                    inactiveThumbColor: Colors.black,
                    inactiveTrackColor: Colors.grey.shade400,
                    trackOutlineColor: WidgetStateColor.resolveWith(
                      (states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.transparent;
                        } else {
                          return Colors.transparent;
                        }
                      },
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  _validateRating(_ratingController.text);

                  if (_ratingError != null) {}

                  if (key.currentState!.validate()) {
                    Reviews reviews = Reviews(
                      reviewId: Uuid().v4(),
                      reviewerId: ref.read(sharedPrefProvider).studentID!,
                      reviewText: _reviewController.text.trim(),
                      rating: num.parse(_ratingController.text.trim()).toInt(),
                      isAnonymous: _isAnonymous,
                      helpfulIDs: [],
                      nothelpfulIDs: [],
                    );

                    await ref.read(teachersProvider.notifier).updateTeacher(
                          widget.teacherId,
                          widget.teacher.copyWith(
                            reviews: [
                              ...widget.teacher.reviews,
                              reviews,
                            ],
                          ),
                        );
                    await ref
                        .read(teachersProvider.notifier)
                        .loadInitialTeachers();

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Appcolor.buttonBackgroundColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Submit Review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Appcolor.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

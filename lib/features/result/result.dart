import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/core/fetch_result.dart';
import 'package:urms_ulab/core/scapper.dart';
import 'package:urms_ulab/models/result_model.dart';
import 'package:urms_ulab/provider/shared_preference_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({
    super.key,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late Future<dynamic> resultFuuture;

  @override
  void initState() {
    super.initState();

    resultFuuture = Scapper.fetchData(
      title: "Result",
      designatedurl: "https://urms-online.ulab.edu.bd/Status.php",
      cookie: ref.read(sharedPrefProvider).token!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Appcolor.primaryColor,
        elevation: 0,
        title: Text(
          'Academic Results',
          style: TextStyle(
            color: Appcolor.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.picture_as_pdf, color: Appcolor.white),
          //   onPressed: () {
          //     // PDF download functionality
          //   },
          // ),
          // IconButton(
          //   icon: Icon(Icons.share, color: Appcolor.white),
          //   onPressed: () {
          //     // Share functionality
          //   },
          // ),
        ],
      ),
      body: FutureBuilder(
          future: resultFuuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Appcolor.buttonBackgroundColor,
                  strokeCap: StrokeCap.round,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(
                    color: Appcolor.redColor,
                    fontSize: 16,
                  ),
                ),
              );
            }
            if (snapshot.data is FetchFailure) {
              return Center(
                child: Text(
                  'Error: ${(snapshot.data as FetchFailure).message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return _buildBody(context,
                result: (snapshot.data as FetchSuccess).data as Result);
          }),
    );
  }

  Widget _buildBody(BuildContext context, {required Result result}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _buildHeaderCard(result: result),
          ),
          _buildSummaryCard(result: result),
          _buildSemesterGPAsCard(result: result),
          _buildCourseResultsCard(result: result),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildCurrentCoursesCard(result: result),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard({required Result result}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Appcolor.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Appcolor.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Appcolor.primaryColor,
                  child: Text(
                    result.studentName.substring(0, 1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Appcolor.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.studentName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Appcolor.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${result.studentId}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Appcolor.greyLabelColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Appcolor.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              result.semesterName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Appcolor.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 18, color: Appcolor.greyLabelColor),
                const SizedBox(width: 8),
                Text(
                  'Adviser: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Appcolor.greyLabelColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  result.adviserName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Appcolor.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email, size: 18, color: Appcolor.greyLabelColor),
                const SizedBox(width: 8),
                Text(
                  result.adviserEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Appcolor.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required Result result}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Appcolor.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Appcolor.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Appcolor.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCircularIndicator(
                    title: 'CGPA',
                    value: result.cgpa,
                    maxValue: 4.0,
                    color: _getCgpaColor(result.cgpa),
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    title: 'Credit Hours',
                    value: result.totalCreditHoursCompleted.toString(),
                    icon: Icons.shield,
                  ),
                ),
                Expanded(
                  child: _buildInfoTile(
                    title: 'Courses',
                    value: result.totalCoursesCompleted.toString(),
                    icon: Icons.book,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularIndicator({
    required String title,
    required double value,
    required double maxValue,
    required Color color,
  }) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40,
          lineWidth: 8,
          percent: value / maxValue,
          center: Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Appcolor.textColor,
            ),
          ),
          progressColor: color,
          backgroundColor: Colors.grey[200]!,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1500,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Appcolor.greyLabelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Appcolor.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 28,
              color: Appcolor.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Appcolor.textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Appcolor.greyLabelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterGPAsCard({required Result result}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Appcolor.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Appcolor.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Semester Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Appcolor.textColor,
                  ),
                ),
                Icon(Icons.bar_chart, color: Appcolor.primaryColor),
              ],
            ),
            const SizedBox(height: 16),
            for (var semesterGPA in result.semesterGpas)
              Column(
                children: [
                  _buildSemesterGPARow(semesterGPA),
                  if (semesterGPA != result.semesterGpas.last)
                    const Divider(height: 24),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterGPARow(SemesterGPA semesterGPA) {
    String semesterFormatted = _formatSemester(semesterGPA.semester);

    return Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Appcolor.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              semesterFormatted,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Appcolor.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GPA: ${semesterGPA.gpa.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Appcolor.textColor,
                    ),
                  ),
                  Text(
                    'CGPA: ${semesterGPA.cgpa.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Appcolor.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearPercentIndicator(
                lineHeight: 8,
                percent: semesterGPA.gpa / 4.0,
                backgroundColor: Colors.grey[200],
                progressColor: _getCgpaColor(semesterGPA.gpa),
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Text(
                'Credit Hours: ${semesterGPA.creditHoursCompleted}',
                style: TextStyle(
                  fontSize: 12,
                  color: Appcolor.greyLabelColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCourseResultsCard({required Result result}) {
    // Filter completed courses (with results)
    final completedCourses = result.courseResults
        .where((course) => course.result != null && course.result != 'W')
        .toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Appcolor.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Appcolor.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Completed Courses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Appcolor.textColor,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Appcolor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${completedCourses.length} Courses',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Appcolor.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < completedCourses.length; i++) ...[
              _buildCourseResultTile(completedCourses[i]),
              if (i < completedCourses.length - 1) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentCoursesCard({required Result result}) {
    // Filter current courses (no results yet)
    final currentCourses =
        result.courseResults.where((course) => course.result == null).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Appcolor.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Appcolor.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Courses',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Appcolor.textColor,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Appcolor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentCourses.length} Courses',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Appcolor.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < currentCourses.length; i++) ...[
              _buildCurrentCourseTile(currentCourses[i]),
              if (i < currentCourses.length - 1) const Divider(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCourseResultTile(CourseResult course) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getGradeColor(course.result).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              course.result ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getGradeColor(course.result),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.courseTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Appcolor.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    course.courseCode,
                    style: TextStyle(
                      fontSize: 12,
                      color: Appcolor.greyLabelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${course.credit.toStringAsFixed(1)} Cr',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Appcolor.greyLabelColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Appcolor.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatSemester(course.semester),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Appcolor.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (course.comments != null) ...[
                const SizedBox(height: 4),
                Text(
                  course.comments!,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Appcolor.greyLabelColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentCourseTile(CourseResult course) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.school,
              size: 20,
              color: Appcolor.greyLabelColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.courseTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Appcolor.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    course.courseCode,
                    style: TextStyle(
                      fontSize: 12,
                      color: Appcolor.greyLabelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${course.credit.toStringAsFixed(1)} Cr',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Appcolor.greyLabelColor,
                      ),
                    ),
                  ),
                  if (course.courseType.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course.courseType,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatSemester(String semester) {
    if (semester.length >= 3) {
      final year = semester.substring(0, 2);
      final term = semester.substring(2);

      String termName = "";
      switch (term) {
        case "1":
          termName = "Spring";
          break;
        case "2":
          termName = "Summer";
          break;
        case "3":
          termName = "Fall";
          break;
        default:
          termName = "Term $term";
      }

      return "$termName '$year";
    }
    return semester;
  }

  Color _getCgpaColor(double cgpa) {
    if (cgpa >= 3.5) return Colors.green;
    if (cgpa >= 3.0) return Colors.blue;
    if (cgpa >= 2.5) return Colors.orange;
    return Colors.red;
  }

  Color _getGradeColor(String? grade) {
    if (grade == null) return Colors.grey;

    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green[700]!;
      case 'A-':
      case 'B+':
        return Colors.green;
      case 'B':
      case 'B-':
        return Colors.blue;
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'C-':
      case 'D+':
      case 'D':
        return Colors.orange[700]!;
      case 'F':
        return Colors.red;
      case 'W':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

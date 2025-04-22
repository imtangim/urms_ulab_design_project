// result_model.dart
class Result {
  final String semester;
  final String semesterName;
  final String studentId;
  final String studentName;
  final String adviserName;
  final String adviserEmail;
  final double cgpa;
  final double totalCreditHoursCompleted;
  final int coursesCompletedBeforeSemester;
  final int coursesCompletedInSemester;
  final int totalCoursesCompleted;
  final List<SemesterGPA> semesterGpas;
  final List<CourseResult> courseResults;

  Result({
    required this.semester,
    required this.semesterName,
    required this.studentId,
    required this.studentName,
    required this.adviserName,
    required this.adviserEmail,
    required this.cgpa,
    required this.totalCreditHoursCompleted,
    required this.coursesCompletedBeforeSemester,
    required this.coursesCompletedInSemester,
    required this.totalCoursesCompleted,
    required this.semesterGpas,
    required this.courseResults,
  });

  Map<String, dynamic> toJson() {
    return {
      'semester': semester,
      'semesterName': semesterName,
      'studentId': studentId,
      'studentName': studentName,
      'adviserName': adviserName,
      'adviserEmail': adviserEmail,
      'cgpa': cgpa,
      'totalCreditHoursCompleted': totalCreditHoursCompleted,
      'coursesCompletedBeforeSemester': coursesCompletedBeforeSemester,
      'coursesCompletedInSemester': coursesCompletedInSemester,
      'totalCoursesCompleted': totalCoursesCompleted,
      'semesterGpas': semesterGpas.map((gpa) => gpa.toJson()).toList(),
      'courseResults': courseResults.map((course) => course.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Result(semester: $semester, semesterName: $semesterName, studentId: $studentId, studentName: $studentName, cgpa: $cgpa, totalCreditHours: $totalCreditHoursCompleted, courseResults: ${courseResults.length})';
  }
}

class SemesterGPA {
  final String semester;
  final double creditHoursCompleted;
  final double gpa;
  final double cgpa;

  SemesterGPA({
    required this.semester,
    required this.creditHoursCompleted,
    required this.gpa,
    required this.cgpa,
  });

  Map<String, dynamic> toJson() {
    return {
      'semester': semester,
      'creditHoursCompleted': creditHoursCompleted,
      'gpa': gpa,
      'cgpa': cgpa,
    };
  }

  @override
  String toString() {
    return 'SemesterGPA(semester: $semester, creditHours: $creditHoursCompleted, gpa: $gpa, cgpa: $cgpa)';
  }
}

class CourseResult {
  final String semester;
  final String courseCode;
  final String courseTitle;
  final String courseType;
  final double credit;
  final String? result;
  final String? comments;

  CourseResult({
    required this.semester,
    required this.courseCode,
    required this.courseTitle,
    required this.courseType,
    required this.credit,
    this.result,
    this.comments,
  });

  Map<String, dynamic> toJson() {
    return {
      'semester': semester,
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'courseType': courseType,
      'credit': credit,
      'result': result,
      'comments': comments,
    };
  }

  @override
  String toString() {
    return 'CourseResult(semester: $semester, courseCode: $courseCode, courseTitle: $courseTitle, credit: $credit, result: $result)';
  }
}
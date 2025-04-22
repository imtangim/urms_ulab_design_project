import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:urms_ulab/core/fetch_result.dart';
import 'package:urms_ulab/models/billing_model.dart';
import 'package:urms_ulab/models/profile_model.dart';
import 'package:urms_ulab/models/result_model.dart';
import 'package:urms_ulab/models/schedule_model.dart';

class Scapper {
  static Future<FetchResult> fetchData({
    required String title,
    required String designatedurl,
    required String cookie,
  }) async {
    if (kDebugMode) {
      print("Fetching $title...");
    }
    String sessionCookie = cookie;

    var url = Uri.parse(designatedurl);
    var response = await http.get(
      url,
      headers: {
        "Cookie": sessionCookie, // Use stored session
      },
    );

    if (response.statusCode == 200) {
      Document document = parser.parse(response.body);
      Element? login = document.querySelector('table.login');
      if (login != null) {
        return FetchFailure("Session expired, please log in again.");
      }

      if (title == "Schedule") {
        var courseData = extractCourseData(response.body);
        return FetchSuccess(courseData);
      } else if (title == "Billing") {
        var billingData = findPaymentData(response.body);
        return FetchSuccess(billingData);
      } else if (title == "Profile") {
        return FetchSuccess(extractProfileFromHtml(response.body));
      } else if (title == "Result") {
        Result result = extractResultFromHtml(response.body);
        return FetchSuccess(result);
      }

      return FetchSuccess("Fetched $title successfully.");
      // If you want to just return the raw body you could do:
      // return FetchSuccess(response.body);
    } else {
      return FetchFailure(
          "Failed to fetch $title with status: ${response.statusCode} - ${response.reasonPhrase}");
    }
  }

// Extract course schedule from HTML
  static List<Course> extractCourseData(String html) {
    Document document = parser.parse(html);
    List<Course> courses = [];

    Element? table = document.querySelector('table.content');
    if (table == null) return courses;

    List<Element> rows = table.querySelectorAll('tbody > tr');
    if (rows.isEmpty) return courses;

    // List<String> headers = rows.first.children.map((e) => e.text.trim()).toList();
    rows.removeAt(0); // Remove header row

    Course? currentCourse;
    for (var row in rows) {
      List<Element> cells = row.children;

      if (cells.isEmpty) continue;

      if (cells.length > 3) {
        // This row starts a new course
        String courseId = cells[0].text.trim();
        String courseName = cells[1].text.trim();
        String section = cells[2].text.trim();
        String day = cells[3].text.trim();
        String time = cells[4].text.trim();
        String roomNo = cells[5].text.trim();
        String classLink = cells[6].text.trim();

        currentCourse = Course(
          courseId: courseId,
          courseName: courseName,
          section: section,
          schedule: [Schedule(day: day, time: time)],
          room: roomNo,
          classLink: classLink,
        );

        courses.add(currentCourse);
      } else if (currentCourse != null) {
        // Additional row for the same course (same Course ID)
        String day = cells[0].text.trim();
        String time = cells[1].text.trim();
        String roomNo = cells[2].text.trim();

        currentCourse.schedule.add(Schedule(day: day, time: time));
        currentCourse.copyWith(room: roomNo); // Room stays the same
      }
    }

    return courses;
  }

  static BillingData? findPaymentData(String html) {
    Document document = parser.parse(html);
    BillingData paymentData = BillingData(
      dues: [],
      payments: [],
    );
    List<Due> dues = [];
    List<Payment> payments = [];

    List<Element> table = document.querySelectorAll('table.content');
    if (table.isEmpty) return paymentData;

    List<Element> billingRows = table[0].querySelectorAll('tbody > tr');
    List<Element> paymentRows = table[1].querySelectorAll('tbody > tr');
    if (billingRows.isEmpty) return paymentData;

    Due? currentDue;
    for (var i = 0; i < billingRows.length; i++) {
      List<Element> cells = billingRows[i].children;
      if (i == 0) {
        continue;
      }

      if (cells.isEmpty) continue;

      if (cells.length > 1) {
        // This row starts a new due
        String date = cells[0].text.trim();
        String head = cells[1].text.trim();
        int amount = convertToInt(cells[2].text.trim());
        int discount = convertToInt(cells[3].text.trim());
        int dueVat = convertToInt(cells[4].text.trim());
        int vatAdjusted = convertToInt(cells[5].text.trim());
        int payable = convertToInt(cells[6].text.trim());

        currentDue = Due(
          date: date,
          head: head,
          amount: amount,
          discount: discount,
          dueVat: dueVat,
          vatAdjusted: vatAdjusted,
          payable: payable,
        );

        dues.add(currentDue);
      }
    }

    Payment? paymentElement;
    for (var i = 0; i < paymentRows.length; i++) {
      List<Element> cells = paymentRows[i].children;
      if (i == 0) {
        continue;
      }

      if (cells.isEmpty) continue;

      if (cells.length > 1) {
        // This row starts a new due
        String date = cells[0].text.trim();
        String mrNo = cells[1].text.trim();
        int amount = convertToInt(cells[2].text.trim());
        String chequeNo = cells[3].text.trim();
        String comment = cells[4].text.trim();
        paymentElement = Payment(
          date: date,
          mrNo: mrNo,
          amount: amount,
          chequeNo: chequeNo,
          comments: comment,
        );
        payments.add(paymentElement);
      }
    }

    paymentData = BillingData(
      dues: dues,
      payments: payments,
    );
    return paymentData;
  }

  static int convertToInt(String formattedString) {
    // Remove commas and split at the decimal point, then parse the integer part
    String cleanedString = formattedString.replaceAll(',', '');
    int result = int.parse(cleanedString.split('.')[0]);
    return result;
  }

  static Result extractResultFromHtml(String html) {
    Document document = parser.parse(html);

    // Extract header info
    final contentTd = document.querySelector('td.content');
    if (contentTd == null) {
      throw Exception('Content not found in result page');
    }

    final headerText = contentTd.text;

    // Use RegExp to extract information from the header
    final semesterMatch =
        RegExp(r'Semester:\s*(\d+)\s*\((\w+\s+\d+)\)').firstMatch(headerText);
    final studentMatch = RegExp(r'Student:\s*(\d+)\s+(.+?)(?=\s*Adviser:)')
        .firstMatch(headerText);
    final adviserMatch =
        RegExp(r'Adviser:\s*(.+?)(?=\s*Email:)').firstMatch(headerText);
    final emailMatch =
        RegExp(r'Email:\s*(.+?)(?=\s*CGPA|\s*Total)').firstMatch(headerText);
    final cgpaMatch = RegExp(r'CGPA:\s*([\d.]+)').firstMatch(headerText);
    final totalCreditMatch = RegExp(r'Total Credit Hours completed :([\d.]+)')
        .firstMatch(headerText);
    final courseBeforeMatch =
        RegExp(r'Number of Courses Completed Before This semester :([\d]+)')
            .firstMatch(headerText);
    final courseThisMatch =
        RegExp(r'Number of Courses Completed in This semester :([\d]+)')
            .firstMatch(headerText);
    final totalCourseMatch =
        RegExp(r'Total Number of Courses Completed :([\d]+)')
            .firstMatch(headerText);

    // Extract semester-wise GPA
    List<SemesterGPA> semesterGpas = [];
    final gpaTable = document.querySelectorAll(
        'table.content')[0]; // First table with class "content"
    final gpaRows = gpaTable.querySelectorAll('tr');
    // Skip header row
    for (int i = 1; i < gpaRows.length; i++) {
      final cells = gpaRows[i].querySelectorAll('td');
      if (cells.length >= 4) {
        semesterGpas.add(SemesterGPA(
          semester: cells[0].text.trim(),
          creditHoursCompleted: double.parse(cells[1].text.trim()),
          gpa: double.parse(cells[2].text.trim()),
          cgpa: double.parse(cells[3].text.trim()),
        ));
      }
    }

    // Extract course results
    List<CourseResult> courseResults = [];
    final coursesTable = document.querySelectorAll(
        'table.content')[1]; // Second table with class "content"
    final courseRows = coursesTable.querySelectorAll('tr');
    // Skip header row
    for (int i = 1; i < courseRows.length; i++) {
      final cells = courseRows[i].querySelectorAll('td');
      if (cells.length >= 7) {
        courseResults.add(CourseResult(
          semester: cells[0].text.trim(),
          courseCode: cells[1].text.trim(),
          courseTitle: cells[2].text.trim(),
          courseType: cells[3].text.trim(),
          credit: double.parse(cells[4].text.trim()),
          result: cells[5].text.trim().isNotEmpty ? cells[5].text.trim() : null,
          comments:
              cells[6].text.trim().isNotEmpty ? cells[6].text.trim() : null,
        ));
      }
    }

    return Result(
      semester: semesterMatch?.group(1) ?? '',
      semesterName: semesterMatch?.group(2) ?? '',
      studentId: studentMatch?.group(1) ?? '',
      studentName: studentMatch?.group(2) ?? '',
      adviserName: adviserMatch?.group(1) ?? '',
      adviserEmail: emailMatch?.group(1) ?? '',
      cgpa: double.parse(cgpaMatch?.group(1) ?? '0.0'),
      totalCreditHoursCompleted:
          double.parse(totalCreditMatch?.group(1) ?? '0.0'),
      coursesCompletedBeforeSemester:
          int.parse(courseBeforeMatch?.group(1) ?? '0'),
      coursesCompletedInSemester: int.parse(courseThisMatch?.group(1) ?? '0'),
      totalCoursesCompleted: int.parse(totalCourseMatch?.group(1) ?? '0'),
      semesterGpas: semesterGpas,
      courseResults: courseResults,
    );
  }

  static Profile extractProfileFromHtml(String htmlString) {
    final document = parser.parse(htmlString);

    final profileTable = document.querySelector('table.noborder');
    if (profileTable == null) {
      throw Exception('Profile table not found');
    }

    // Profile Image URL
    final imageElement = profileTable.querySelector('img');
    final imageUrl = imageElement?.attributes['src'] ?? '';

    // Extract student info from paragraph
    final profileP = document.querySelector('td.content p')?.text ?? '';
    String studentId = '';

    // Extract student ID from the paragraph which contains "Student: 242014013"
    final studentMatch = RegExp(r'Student:\s*(\d+)').firstMatch(profileP);
    if (studentMatch != null && studentMatch.groupCount >= 1) {
      studentId = studentMatch.group(1) ?? '';
    }

    // Name - from h2 element
    final nameElement = profileTable.querySelector('h2');
    final name = nameElement?.text.trim() ?? '';

    // Department - directly target the cell with "CSE" text
    String department = '';
    final rows = profileTable.querySelectorAll('tr');

    // The department "CSE" is in the third row (index 2), in the last cell
    if (rows.length > 2) {
      final deptRow = rows[2];
      final deptCells = deptRow.querySelectorAll('td');
      if (deptCells.isNotEmpty) {
        // Take the last cell in this row which contains the department
        department = deptCells[deptCells.length - 1].text.trim();
      }
    }

    // Map to store label-value pairs
    Map<String, String> data = {};

    for (var row in rows) {
      final tds = row.querySelectorAll('td');
      for (int i = 0; i < tds.length - 1; i += 2) {
        if (i + 1 < tds.length) {
          final label = tds[i].text.trim();
          if (label.isNotEmpty) {
            final value = tds[i + 1]
                .innerHtml
                .trim()
                .replaceAll('<br>', ', ')
                .replaceAll(RegExp(r'\s+'), ' ');
            data[label] = value;
          }
        }
      }
    }

    // Extract other paragraph values
    final semesterMatch = RegExp(r'Semester:\s*(\d+)').firstMatch(profileP);
    final semesterNameMatch = RegExp(r'\(([^)]+)\)').firstMatch(profileP);
    final adviserNameMatch =
        RegExp(r'Adviser:\s*(.*?)\s*Email:').firstMatch(profileP);
    final adviserEmailMatch = RegExp(r'Email:\s*(.*)').firstMatch(profileP);

    final semester = semesterMatch?.group(1) ?? '';
    final semesterName = semesterNameMatch?.group(1) ?? '';
    final adviserName = adviserNameMatch?.group(1) ?? '';
    final adviserEmail = adviserEmailMatch?.group(1) ?? '';

    return Profile(
      studentId: studentId,
      name: name,
      department: department,
      phoneNumber: data['Tel/Mobile'] ?? '',
      activeStatus: data['Active Status'] ?? '',
      ulabMail: data['ULAB Mail'] ?? '',
      paymentStatus: data['Payment Status'] ?? '',
      personalMail: data['Personal Mail'] ?? '',
      registrationStatus: data['Registration Status'] ?? '',
      presentAddress: data['Present Address'] ?? '',
      profileImageUrl: imageUrl,
      semester: semester,
      semesterName: semesterName,
      adviserName: adviserName,
      adviserEmail: adviserEmail,
    );
  }
}


// Fetch schedule using stored session


// Map<String, dynamic>? findPaymentData(String html) {
//   Document document = parser.parse(html);
//   Map<String, dynamic> paymentData = {};
//   List<DueElement> dues = [];
//   List<PaymentElement> payments = [];

//   List<Element> table = document.querySelectorAll('table.content');
//   if (table.isEmpty) return paymentData;

//   List<Element> billingRows = table[0].querySelectorAll('tbody > tr');
//   List<Element> paymentRows = table[1].querySelectorAll('tbody > tr');
//   if (billingRows.isEmpty) return paymentData;

//   DueElement? currentDue;
//   for (var i = 0; i < billingRows.length; i++) {
//     List<Element> cells = billingRows[i].children;
//     if (i == 0) {
//       continue;
//     }

//     if (cells.isEmpty) continue;

//     if (cells.length > 1) {
//       // This row starts a new due
//       String date = cells[0].text.trim();
//       String head = cells[1].text.trim();
//       int amount = convertToInt(cells[2].text.trim());
//       int discount = convertToInt(cells[3].text.trim());
//       int dueVat = convertToInt(cells[4].text.trim());
//       int vatAdjusted = convertToInt(cells[5].text.trim());
//       int payable = convertToInt(cells[6].text.trim());

//       currentDue = DueElement(
//         date: date,
//         head: head,
//         amount: amount,
//         discount: discount,
//         dueVat: dueVat,
//         vatAdjusted: vatAdjusted,
//         payable: payable,
//       );

//       dues.add(currentDue);
//     }
//   }

//   PaymentElement? paymentElement;
//   for (var i = 0; i < paymentRows.length; i++) {
//     List<Element> cells = paymentRows[i].children;
//     if (i == 0) {
//       continue;
//     }

//     if (cells.isEmpty) continue;

//     if (cells.length > 1) {
//       // This row starts a new due
//       String date = cells[0].text.trim();
//       String mrNo = cells[1].text.trim();
//       int amount = convertToInt(cells[2].text.trim());
//       String chequeNo = cells[3].text.trim();
//       String comment = cells[4].text.trim();
//       paymentElement = PaymentElement(
//         date: date,
//         mrNo: mrNo,
//         amount: amount,
//         chequeNo: chequeNo,
//         comments: comment,
//       );
//       payments.add(paymentElement);
//     }
//   }

//   paymentData = {
//     "dues": dues.map((e) => e.toJson()).toList(),
//     "payments": payments.map((e) => e.toJson()).toList(),
//   };
//   return paymentData;
// }

// Profile extractProfileFromHtml(String htmlString) {
//   final document = parser.parse(htmlString);

//   final profileTable = document.querySelector('table.noborder');
//   if (profileTable == null) {
//     throw Exception('Profile table not found');
//   }

//   final rows = profileTable.querySelectorAll('tr');

//   // Profile Image URL
//   final imageUrl = profileTable.querySelector('img')?.attributes['src'] ?? '';

//   // Student ID, Name, Department
//   final cells = profileTable.querySelectorAll('td');
//   final studentId = cells[2].text.trim();
//   final name = profileTable.querySelector('h2')?.text.trim() ?? '';
//   final department = cells[3].text.trim();

//   // Map to store label-value pairs
//   Map<String, String> data = {};

//   for (var row in rows) {
//     final tds = row.querySelectorAll('td');
//     for (int i = 0; i < tds.length - 1; i += 2) {
//       final label = tds[i].text.trim();
//       final value = tds[i + 1]
//           .innerHtml
//           .trim()
//           .replaceAll('<br>', ', ')
//           .replaceAll(RegExp(r'\s+'), ' ');
//       if (label.isNotEmpty) {
//         data[label] = value;
//       }
//     }
//   }
//   // Extract paragraph values
//   final profileP = document.querySelector('td.content p')?.text ?? '';

//   final semesterMatch = RegExp(r'Semester:\s*(\d+)').firstMatch(profileP);
//   final semesterNameMatch = RegExp(r'\(([^)]+)\)').firstMatch(profileP);
//   final adviserNameMatch =
//       RegExp(r'Adviser:\s*(.*?)\s*Email:').firstMatch(profileP);
//   final adviserEmailMatch = RegExp(r'Email:\s*(.*)').firstMatch(profileP);

//   final semester = semesterMatch?.group(1) ?? '';
//   final semesterName = semesterNameMatch?.group(1) ?? '';
//   final adviserName = adviserNameMatch?.group(1) ?? '';
//   final adviserEmail = adviserEmailMatch?.group(1) ?? '';

//   return Profile(
//     studentId: studentId,
//     name: name,
//     department: department,
//     phoneNumber: data['Tel/Mobile'] ?? '',
//     activeStatus: data['Active Status'] ?? '',
//     ulabMail: data['ULAB Mail'] ?? '',
//     paymentStatus: data['Payment Status'] ?? '',
//     personalMail: data['Personal Mail'] ?? '',
//     registrationStatus: data['Registration Status'] ?? '',
//     presentAddress: data['Present Address'] ?? '',
//     profileImageUrl: imageUrl,
//     semester: semester,
//     semesterName: semesterName,
//     adviserName: adviserName,
//     adviserEmail: adviserEmail,
//   );
// }

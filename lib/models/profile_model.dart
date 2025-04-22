import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Profile {
  final String studentId;
  final String name;
  final String department;
  final String phoneNumber;
  final String activeStatus;
  final String ulabMail;
  final String paymentStatus;
  final String personalMail;
  final String registrationStatus;
  final String presentAddress;
  final String profileImageUrl;
  final String semester;
  final String semesterName;
  final String adviserName;
  final String adviserEmail;

  Profile({
    required this.studentId,
    required this.name,
    required this.department,
    required this.phoneNumber,
    required this.activeStatus,
    required this.ulabMail,
    required this.paymentStatus,
    required this.personalMail,
    required this.registrationStatus,
    required this.presentAddress,
    required this.profileImageUrl,
    required this.semester,
    required this.semesterName,
    required this.adviserName,
    required this.adviserEmail,
  });

  @override
  String toString() {
    return 'Profile(studentId: $studentId, name: $name, department: $department, phoneNumber: $phoneNumber, activeStatus: $activeStatus, ulabMail: $ulabMail, paymentStatus: $paymentStatus, personalMail: $personalMail, registrationStatus: $registrationStatus, presentAddress: $presentAddress, profileImageUrl: $profileImageUrl, semester: $semester, semesterName: $semesterName, adviserName: $adviserName, adviserEmail: $adviserEmail)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'studentId': studentId,
      'name': name,
      'department': department,
      'phoneNumber': phoneNumber,
      'activeStatus': activeStatus,
      'ulabMail': ulabMail,
      'paymentStatus': paymentStatus,
      'personalMail': personalMail,
      'registrationStatus': registrationStatus,
      'presentAddress': presentAddress,
      'profileImageUrl': profileImageUrl,
      'semester': semester,
      'semesterName': semesterName,
      'adviserName': adviserName,
      'adviserEmail': adviserEmail,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      studentId: map['studentId'] as String,
      name: map['name'] as String,
      department: map['department'] as String,
      phoneNumber: map['phoneNumber'] as String,
      activeStatus: map['activeStatus'] as String,
      ulabMail: map['ulabMail'] as String,
      paymentStatus: map['paymentStatus'] as String,
      personalMail: map['personalMail'] as String,
      registrationStatus: map['registrationStatus'] as String,
      presentAddress: map['presentAddress'] as String,
      profileImageUrl: map['profileImageUrl'] as String,
      semester: map['semester'] as String,
      semesterName: map['semesterName'] as String,
      adviserName: map['adviserName'] as String,
      adviserEmail: map['adviserEmail'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) => Profile.fromMap(json.decode(source) as Map<String, dynamic>);
}

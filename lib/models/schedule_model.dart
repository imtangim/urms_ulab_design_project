// ignore_for_file: public_member_api_docs, sort_constructors_first

class Course {
  final String courseId;
  final String courseName;
  final String section;
  final List<Schedule> schedule;
  final String room;
  final String classLink;

  Course({
    required this.courseId,
    required this.courseName,
    required this.section,
    required this.schedule,
    required this.room,
    required this.classLink,
  });

  Course copyWith({
    String? courseId,
    String? courseName,
    String? section,
    List<Schedule>? schedule,
    String? room,
    String? classLink,
  }) {
    return Course(
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      section: section ?? this.section,
      schedule: schedule ?? this.schedule,
      room: room ?? this.room,
      classLink: classLink ?? this.classLink,
    );
  }
}

class Schedule {
  final String day;
  final String time;

  Schedule({required this.day, required this.time});

  Schedule copyWith({
    String? day,
    String? time,
  }) {
    return Schedule(
      day: day ?? this.day,
      time: time ?? this.time,
    );
  }
}

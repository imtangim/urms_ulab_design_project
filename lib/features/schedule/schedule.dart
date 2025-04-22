import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/core/fetch_result.dart';
import 'package:urms_ulab/core/scapper.dart';
import 'package:urms_ulab/models/schedule_model.dart';
import 'package:urms_ulab/provider/shared_preference_provider.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  late Future<FetchResult> fetchCourses;

  final List<String> days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  int selectedDayIndex = 0;

  // Get today's day
  String getCurrentDay() {
    final now = DateTime.now();
    return DateFormat('EEE').format(now).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    final today = getCurrentDay();
    final index = days.indexOf(today);
    if (index != -1) {
      selectedDayIndex = index;
    }
    fetchCourses = Scapper.fetchData(
      title: "Schedule",
      designatedurl: "https://urms-online.ulab.edu.bd/schedule.php",
      cookie: ref.read(sharedPrefProvider).header!.setCookie,
    );
  }

  // Filter courses by selected day
  List<Course> getCoursesForDay(String day, {required List<Course> courses}) {
    return courses.where((course) {
      return course.schedule.any((schedule) => schedule.day == day);
    }).toList();
  }

  // Get time period (Morning, Afternoon, Evening)
  String getTimePeriod(String timeString) {
    if (timeString.isEmpty) return "";
    final startTime = timeString.split(' - ')[0];
    final hour = int.parse(startTime.split(':')[0]);
    final isPM = startTime.contains('PM');

    final adjustedHour = isPM && hour != 12 ? hour + 12 : hour;

    if (adjustedHour < 12) return "Morning";
    if (adjustedHour < 17) return "Afternoon";
    return "Evening";
  }

  // Group courses by time period
  Map<String, List<CourseWithSchedule>> groupCoursesByTimePeriod(
      List<Course> courses, String day) {
    final Map<String, List<CourseWithSchedule>> grouped = {
      "Morning": [],
      "Afternoon": [],
      "Evening": [],
    };

    for (final course in courses) {
      final schedule = course.schedule.firstWhere(
        (s) => s.day == day,
        orElse: () => Schedule(day: day, time: ""),
      );

      if (schedule.time.isNotEmpty) {
        final period = getTimePeriod(schedule.time);
        grouped[period]!
            .add(CourseWithSchedule(course: course, schedule: schedule));
      }
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: fetchCourses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  color: Appcolor.buttonBackgroundColor,
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            if (snapshot.data is FetchFailure) {
              return Center(
                child: Text(
                  "Error: ${(snapshot.data as FetchFailure).message}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            final selectedDay = days[selectedDayIndex];
            final filteredCourses = getCoursesForDay(
              selectedDay,
              courses: (snapshot.data as FetchSuccess).data as List<Course>,
            );
            final groupedCourses =
                groupCoursesByTimePeriod(filteredCourses, selectedDay);

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 50,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      "My Schedule",
                      style: TextStyle(
                        color: Appcolor.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Appcolor.primaryColor,
                            Appcolor.primaryColor.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Center(
                          child: Text(
                            DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            style: TextStyle(
                              color: Appcolor.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Container(
                      height: 50,
                      color: Appcolor.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: days.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedDayIndex == index;
                          final isToday = days[index] == getCurrentDay();

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedDayIndex = index;
                              });
                            },
                            child: Container(
                              width: 45,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 3, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Appcolor.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                                border: isToday && !isSelected
                                    ? Border.all(
                                        color: Appcolor.white.withOpacity(0.7),
                                        width: 1.5)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  days[index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected || isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Appcolor.primaryColor
                                        : Appcolor.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Schedule for ",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Appcolor.textColor,
                                ),
                              ),
                              TextSpan(
                                text: DateFormat('EEEE').format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Appcolor.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Appcolor.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${filteredCourses.length} Classes",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Appcolor.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (filteredCourses.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Appcolor.fillColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.event_busy,
                              size: 50,
                              color: Appcolor.greyLabelColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No classes scheduled",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Appcolor.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Enjoy your free day!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Appcolor.greyLabelColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final periods = ["Morning", "Afternoon", "Evening"];
                        final period = periods[index];
                        final coursesInPeriod = groupedCourses[period]!;

                        if (coursesInPeriod.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                children: [
                                  Icon(
                                    index == 0
                                        ? Icons.wb_sunny
                                        : index == 1
                                            ? Icons.wb_twilight
                                            : Icons.nights_stay,
                                    size: 18,
                                    color: Appcolor.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    period,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Appcolor.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Divider(
                                      color: Appcolor.primaryColor
                                          .withOpacity(0.2),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...coursesInPeriod
                                .map((courseWithSchedule) => EnhancedCourseCard(
                                      courseWithSchedule: courseWithSchedule,
                                    ))
                                ,
                          ],
                        );
                      },
                      childCount: 3, // Morning, Afternoon, Evening
                    ),
                  ),
              ],
            );
          }),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Action to add a course or event
      //   },
      //   backgroundColor: Appcolor.primaryColor,
      //   child: Icon(Icons.add, color: Appcolor.white),
      // ),
    );
  }
}

class CourseWithSchedule {
  final Course course;
  final Schedule schedule;

  CourseWithSchedule({required this.course, required this.schedule});
}

class EnhancedCourseCard extends StatelessWidget {
  final CourseWithSchedule courseWithSchedule;

  const EnhancedCourseCard({
    super.key,
    required this.courseWithSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final course = courseWithSchedule.course;
    final schedule = courseWithSchedule.schedule;

    // Extract time for visual display
    String startTime = "";
    String endTime = "";
    if (schedule.time.isNotEmpty) {
      final parts = schedule.time.split(' - ');
      if (parts.length == 2) {
        startTime = parts[0];
        endTime = parts[1];
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        color: Appcolor.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Appcolor.fillColor, width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // View course details
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time column
                if (startTime.isNotEmpty)
                  Container(
                    width: 62,
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      children: [
                        Text(
                          startTime,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Appcolor.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: 35,
                          width: 1,
                          color: Appcolor.primaryColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          endTime,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Appcolor.greyLabelColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Course details
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: startTime.isNotEmpty ? 10 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Appcolor.primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                course.courseId,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Appcolor.primaryColor,
                                ),
                              ),
                            ),
                            // const Spacer(),
                            // Icon(
                            //   Icons.arrow_forward_ios,
                            //   size: 14,
                            //   color: Appcolor.greyLabelColor,
                            // ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          course.courseName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Appcolor.textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoItem(
                                Icons.location_on, "Room ${course.room}"),
                            const SizedBox(width: 12),
                            _buildInfoItem(
                                Icons.groups, "Section ${course.section}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Appcolor.greyLabelColor,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Appcolor.greyLabelColor,
          ),
        ),
      ],
    );
  }
}

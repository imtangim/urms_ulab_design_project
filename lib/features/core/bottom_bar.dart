import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/features/billing/billing.dart';
import 'package:urms_ulab/features/homepage/homepage.dart';
import 'package:urms_ulab/features/profile/profile_screen.dart';
import 'package:urms_ulab/features/result/result.dart';
import 'package:urms_ulab/features/schedule/schedule.dart';
import 'package:urms_ulab/features/teacher/teacher_screen.dart';
import 'package:urms_ulab/models/profile_model.dart';

class BottomBar extends ConsumerStatefulWidget {
  final Profile profile;
  const BottomBar({
    super.key,
    required this.profile,
  });

  @override
  ConsumerState<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<BottomBar> {
  final List<Widget> _screen = [
    Homepage(),
    ResultScreen(),
    TeacherScreen(),
    ScheduleScreen(),
    BillingScreen(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    minimumSize: Size(10, 10),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    // radius: 50,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.network(
                        widget.profile.profileImageUrl,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Appcolor.fillColor,
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Appcolor.primaryColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            )
          : null,
      body: _screen[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          _currentIndex = value;
          setState(() {});
        },
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Appcolor.buttonBackgroundColor,
        selectedItemColor: Appcolor.selectedColor,
        unselectedItemColor: Appcolor.unselectedColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        items: [
          BottomNavigationBarItem(
            icon: _currentIndex == 0
                ? Icon(Iconsax.home_25)
                : Icon(Iconsax.home_2),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 1
                ? Icon(Iconsax.chart_15)
                : Icon(Iconsax.chart_21),
            label: "Result",
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 2
                ? Icon(Iconsax.teacher5)
                : Icon(Iconsax.teacher),
            label: "Teachers",
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 3
                ? Icon(
                    Iconsax.calendar_15,
                  )
                : Icon(
                    Iconsax.calendar,
                  ),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 4
                ? Icon(Iconsax.document5)
                : Icon(Iconsax.document),
            label: "Billing",
          ),
        ],
      ),
    );
  }
}

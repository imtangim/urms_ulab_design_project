import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/features/billing/billing.dart';
import 'package:urms_ulab/features/homepage/homepage.dart';
import 'package:urms_ulab/features/result/result.dart';
import 'package:urms_ulab/features/schedule/schedule.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final List<Widget> _screen = [
    Homepage(),
    ResultScreen(),
    ScheduleScreen(),
    BillingScreen()
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            onPressed: () {},
            child: CircleAvatar(),
          )
        ],
      ),
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
                ? Icon(
                    Iconsax.calendar_15,
                  )
                : Icon(
                    Iconsax.calendar,
                  ),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 3
                ? Icon(Iconsax.document5)
                : Icon(Iconsax.document),
            label: "Billing",
          ),
        ],
      ),
    );
  }
}

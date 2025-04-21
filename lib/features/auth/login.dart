import 'package:flutter/material.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/features/core/bottom_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController studentIDTxtEditingController = TextEditingController();
  TextEditingController passswordTxtEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            // SvgPicture.asset("assets/ulab.svg"),
            Image.asset("assets/ULAB-logo.webp"),
            Text(
              "Welcome Back",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Column(
              spacing: 5,
              children: [
                AuthTextFormField(
                  textEditingController: studentIDTxtEditingController,
                  label: "Student ID".toUpperCase(),
                ),
                AuthTextFormField(
                  textEditingController: passswordTxtEditingController,
                  label: "Password".toUpperCase(),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolor.buttonBackgroundColor,
                      foregroundColor: Colors.white,
                      maximumSize: Size(double.maxFinite, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: Size(double.maxFinite, 40),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => BottomBar(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text("Login"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AuthTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;

  const AuthTextFormField({
    super.key,
    required this.label,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextFormField(
            controller: textEditingController,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              isDense: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              fillColor: Appcolor.fillColor,
              filled: true,
              constraints: BoxConstraints(
                maxHeight: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

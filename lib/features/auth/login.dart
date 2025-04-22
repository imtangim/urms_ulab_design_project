import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/core/fetch_result.dart';
import 'package:urms_ulab/core/scapper.dart';
import 'package:urms_ulab/features/core/bottom_bar.dart';
import 'package:urms_ulab/models/profile_model.dart';
import 'package:urms_ulab/provider/auth_provider.dart';
import 'package:urms_ulab/provider/shared_preference_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  TextEditingController studentIDTxtEditingController = TextEditingController();
  TextEditingController passswordTxtEditingController = TextEditingController();

  bool isLoading = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          SizedBox(
            height: double.maxFinite,
            width: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
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
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          onPressed: () async {
                            setState(() {
                              isLoading = !isLoading;
                            });
                            if (formKey.currentState!.validate()) {
                              int? code = await ref
                                  .read(authProvider)
                                  .loginAndStoreSession(
                                    studentIDTxtEditingController.text.trim(),
                                    passswordTxtEditingController.text.trim(),
                                    ref,
                                  );

                              if (code == 200) {
                                if (mounted) {
                                  Profile profile = (await Scapper.fetchData(
                                    title: "Profile",
                                    designatedurl:
                                        "https://urms-online.ulab.edu.bd/profile.php",
                                    cookie: ref.read(sharedPrefProvider).token!,
                                  ) as FetchSuccess)
                                      .data as Profile;

                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => BottomBar(
                                        profile: profile,
                                      ),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                            }
                            setState(() {
                              isLoading = !isLoading;
                            });
                          },
                          child: Text("Login"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "By Clicking Login | I agree to the Terms & Conditions and Privacy Policy of Developer",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Appcolor.textColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: CircularProgressIndicator(
                  color: Appcolor.buttonBackgroundColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
            )
        ],
      ),
    );
  }
}

class AuthTextFormField extends StatefulWidget {
  final String label;
  final TextEditingController textEditingController;

  const AuthTextFormField({
    super.key,
    required this.label,
    required this.textEditingController,
  });

  @override
  State<AuthTextFormField> createState() => _AuthTextFormFieldState();
}

class _AuthTextFormFieldState extends State<AuthTextFormField> {
  bool isObsecure = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextFormField(
            inputFormatters: widget.label == "PASSWORD"
                ? null
                : [FilteringTextInputFormatter.digitsOnly],
            controller: widget.textEditingController,
            obscureText: widget.label == "PASSWORD" ? isObsecure : false,
            cursorColor: Appcolor.buttonBackgroundColor,
            decoration: InputDecoration(
              isCollapsed: false,
              suffixIcon: widget.label == "PASSWORD"
                  ? IconButton(
                      padding: EdgeInsets.all(0),
                      alignment: Alignment.center,
                      visualDensity: VisualDensity.compact,
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.all(0),
                      ),
                      onPressed: () {
                        setState(() {
                          isObsecure = !isObsecure;
                        });
                      },
                      icon:
                          Icon(isObsecure ? Iconsax.eye4 : Iconsax.eye_slash5),
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              // isDense: true,

              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              fillColor: Appcolor.fillColor,
              filled: true,
              constraints: BoxConstraints(
                maxHeight: 45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

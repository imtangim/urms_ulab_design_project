import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urms_ulab/core/colors.dart';
import 'package:urms_ulab/core/fetch_result.dart';
import 'package:urms_ulab/core/scapper.dart';
import 'package:urms_ulab/main.dart';
import 'package:urms_ulab/models/auth_response_header.dart';
import 'package:urms_ulab/models/profile_model.dart';
import 'package:urms_ulab/provider/firebase_provider.dart';
import 'package:urms_ulab/provider/shared_preference_provider.dart';

class AuthNotifier extends ChangeNotifier {
  Future<int?> loginAndStoreSession(
      String studentID, String password, WidgetRef ref) async {
    try {
      var url = Uri.parse("https://urms-online.ulab.edu.bd/index.php");
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: "studentID=$studentID&password=$password",
      );
      if (response.statusCode == 200) {
        String? rawCookie = response.headers['set-cookie'];
        String responseBody = response.body;
        if (responseBody.contains("Invalid Password") ||
            responseBody.contains("Incorrect login information!")) {
          log("Invalid Found");
          throw "invalid";
        }
        if (rawCookie != null) {
          Profile profile = (await Scapper.fetchData(
            title: "Profile",
            designatedurl: "https://urms-online.ulab.edu.bd/profile.php",
            cookie: rawCookie,
          ) as FetchSuccess)
              .data as Profile;
          await ref.read(sharedPrefProvider).saveAuth(
                cookieToken: rawCookie,
                header: AuthResponseHeader.fromMap(response.headers),
                studentID: profile.studentId,
              );

          log(profile.ulabMail.toString());
          await ref.read(firebaseProvider).saveProfile(profile);
          return 200;
        } else {
          throw "invalid E";
        }
      } else {
        throw "invalid";
      }
    } catch (e) {
      log(e.toString());
      scafoldKey.currentState!.showSnackBar(
        SnackBar(
          content: Text(
            "Invalid Id or Password",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Appcolor.redColor,
        ),
      );
    }
    return null;
  }
}

final authProvider = ChangeNotifierProvider(
  (ref) => AuthNotifier(),
);

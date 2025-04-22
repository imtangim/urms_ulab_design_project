import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urms_ulab/core/fetch_result.dart';
import 'package:urms_ulab/core/scapper.dart';
import 'package:urms_ulab/features/auth/login.dart';
import 'package:urms_ulab/features/core/bottom_bar.dart';
import 'package:urms_ulab/models/auth_response_header.dart';
import 'package:urms_ulab/models/profile_model.dart';

class SharedPreferenceNotifier extends ChangeNotifier {
  SharedPreferences? _sharedPreferences;

  String? token;

  AuthResponseHeader? header;

  String? studentID;

  SharedPreferences? get sharedPreferences => _sharedPreferences;

  Future<void> saveAuth(
      {required String cookieToken,
      required AuthResponseHeader header,
      required String studentID}) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences!.setString("token", cookieToken);
    await _sharedPreferences!.setString("authHeader", header.toJson());
    token = cookieToken;
    this.header = header;
    this.studentID = studentID;

    notifyListeners();
  }

  Future<Widget> authStateDecider(WidgetRef ref) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    String? headerString = _sharedPreferences?.getString("authHeader");
    String? token = getAuthToken();

    if (headerString != null) {
      header = AuthResponseHeader.fromMap(jsonDecode(headerString));

      if (HttpDate.parse(header!.expires).isBefore(DateTime.now()) == false) {
        this.token = token;
        notifyListeners();
        try {
          Profile profile = (await Scapper.fetchData(
            title: "Profile",
            designatedurl: "https://urms-online.ulab.edu.bd/profile.php",
            cookie: this.token!,
          ) as FetchSuccess)
              .data as Profile;
          studentID = profile.studentId;
          return BottomBar(
            profile: profile,
          );
        } catch (e) {
          _sharedPreferences!.clear();
          notifyListeners();
          return LoginScreen();
        }
      } else {
        _sharedPreferences!.clear();
        notifyListeners();
        return LoginScreen();
      }
    }
    _sharedPreferences!.clear();
    notifyListeners();
    return LoginScreen();
  }

  String? getAuthToken() {
    return _sharedPreferences?.getString("token");
  }

  Future<void> singout() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences!.clear();
    notifyListeners();
  }
}

final sharedPrefProvider = ChangeNotifierProvider(
  (ref) => SharedPreferenceNotifier(),
);

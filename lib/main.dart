import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sdomirea/model/courses_base.dart';
import 'package:sdomirea/pages/preloader_page.dart';
import 'package:sdomirea/sdo_api/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SDOApp());
}

class SDOApp extends StatelessWidget {
  const SDOApp({super.key});

  static CoursesBase base = CoursesBase(courses: {}, downloadedCourses: {});
  static late SharedPreferences sharedPreferences;
  static MoodleSession session = MoodleSession.NULL;

  static void updateCoursesBase() {
    SDOApp.sharedPreferences
        .setString('base', jsonEncode(SDOApp.base.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const PreLoaderScreen(
          title: "",
        ));
  }
}

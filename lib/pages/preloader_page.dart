import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sdomirea/main.dart';
import 'package:sdomirea/sdo_api/course_details.dart';
import '../model/courses_base.dart';
import '../model/user.dart';
import '../sdo_api/auth.dart';
import '../sdo_api/courses.dart';
import 'courses_page.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreLoaderScreen extends StatefulWidget {
  const PreLoaderScreen({super.key, required this.title});

  final String title;

  @override
  State<PreLoaderScreen> createState() => _PreLoaderScreenState();
}

class _PreLoaderScreenState extends State<PreLoaderScreen> {
  Future<void> initCoursesBase() async {
    SDOApp.sharedPreferences = await SharedPreferences.getInstance();
    if (SDOApp.sharedPreferences.containsKey('base')) {
      SDOApp.base = CoursesBase.fromJson(
          jsonDecode(SDOApp.sharedPreferences.getString('base')!));
      if (SDOApp.base.courses.isNotEmpty) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    CoursesListPage(title: '', courses: SDOApp.base.courses)),
            (route) => false);
        return;
      }
    }
    if (SDOApp.sharedPreferences.containsKey('user')) {
      try {
        User user = User.fromJson(
            jsonDecode(SDOApp.sharedPreferences.getString('user')!));
        MoodleSession session =
            await MireaAuth.requestAuthFromNetwork(user.login, user.password);
        SDOApp.session = session;
        await EduCourses.getMyCourses(session).then((value) {
          SDOApp.base.courses = value;
          SDOApp.updateCoursesBase();

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      CoursesListPage(title: '', courses: value)),
              (route) => false);
        });
      } on IOException {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage(title: '')),
            (route) => false);
      }
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage(title: '')),
        (route) => false);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initCoursesBase();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff011627),
      body: Center(
        child: PreLoader(),
      ),
    );
  }
}

class PreLoader extends Column {
  PreLoader({super.key})
      : super(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              SizedBox(
                width: 200,
                child: Image(image: AssetImage('assets/images/mirea_logo.png')),
              ),
              SizedBox(height: 50),
              Text("СДО\nРТУ МИРЭА",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center)
            ]);
}

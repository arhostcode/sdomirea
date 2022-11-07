import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sdomirea/main.dart';
import 'package:sdomirea/model/user.dart';
import 'package:sdomirea/pages/courses_page.dart';
import 'package:sdomirea/sdo_api/auth.dart';
import 'package:sdomirea/sdo_api/courses.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String message = "";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    return Scaffold(
      backgroundColor: const Color(0xff011627),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 50),
                  child: SizedBox(
                    width: 50,
                    child: Image(
                        image: AssetImage("assets/images/mirea_logo.png")),
                  ),
                )
              ],
            ),
            Column(
              children: [
                const Text("МИРЭА",
                    style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center),
                const Text("Войдите в сервис",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  width: 250,
                  height: 55,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 33),
                          child: SizedBox(
                            width: 19,
                            child: Image(
                                image: AssetImage("assets/images/mail.png")),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: SizedBox(
                            width: 150,
                            child: TextField(
                              controller: email,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  label: Text("Email")),
                            ),
                          ),
                        ),
                        // TextField()
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 250,
                  height: 55,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30))),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 33),
                          child: SizedBox(
                            width: 19,
                            child: Image(
                                image:
                                    AssetImage("assets/images/password.png")),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: SizedBox(
                            width: 150,
                            child: TextField(
                              controller: password,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  label: Text("Password")),
                            ),
                          ),
                        ),
                        // TextField()
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                MaterialButton(
                    onPressed: () =>
                        loginWithCredentials(email.text, password.text),
                    child: const SizedBox(
                        width: 240,
                        height: 50,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                color: Color(0xFFFF3366)),
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text("Войти",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  textAlign: TextAlign.center),
                            )))),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
                Visibility(
                    visible: loading,
                    child: LoadingAnimationWidget.threeRotatingDots(
                        color: Colors.white, size: 50))
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> loginWithCredentials(String mail, String password) async {
    setState(() {
      message = "";
      loading = true;
    });
    try {
      MoodleSession session = await MireaAuth.requestAuthFromNetwork(mail, password);
      SDOApp.session = session;
      SDOApp.sharedPreferences.setString(
          'user', jsonEncode(User(login: mail, password: password).toJson()));
      await EduCourses.getMyCourses(session).then((value) {
        SDOApp.base.courses = value;
        SDOApp.updateCoursesBase();

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) =>
                    CoursesListPage(title: '', courses: value)),
            (route) => false);
      });
    } on AuthException {
      setState(() {
        message = 'Невозможно войти';
        loading = false;
      });
    } on CourseException {
      setState(() {
        message = 'Невозможно войти';
        loading = false;
      });
    }
  }
}

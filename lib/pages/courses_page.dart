import 'package:flutter/material.dart';
import 'package:sdomirea/main.dart';
import 'package:sdomirea/sdo_api/auth.dart';
import 'package:sdomirea/sdo_api/courses.dart';
import '../sdo_api/course_details.dart';
import 'course_page.dart';

class CoursesListPage extends StatefulWidget {
  Map<String, CourseData> courses = {};

  CoursesListPage({super.key, required this.title, required this.courses});

  final String title;

  @override
  State<CoursesListPage> createState() => _CoursesListPageState();
}

class _CoursesListPageState extends State<CoursesListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff011627),
        body: Center(
            child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Мои курсы",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.start),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(child: getTextWidgets())
          ],
        )));
  }

  Widget getTextWidgets() {
    List<Widget> list = <Widget>[];
    for (var i = 0; i < widget.courses.length; i++) {
      list.add(MaterialButton(
        onPressed: () => {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CoursePage(
                  title: '',
                  currentCourse: widget.courses.values.toList()[i].course)))
        },
        child: SizedBox(
          width: 300,
          height: 50,
          child: DecoratedBox(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(13)),
                  color: Colors.white),
              child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(children: [
                    SizedBox(
                      width: 250,
                      child: Text(
                          widget.courses.values.toList()[i].course.title,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.black),
                          textAlign: TextAlign.start),
                    ),
                    const SizedBox(
                      width: 20,
                      child: Icon(Icons.call_made_outlined),
                    )
                  ]))),
        ),
      ));
      list.add(const SizedBox(
        height: 20,
      ));
    }
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      children: list,
    );
  }
}

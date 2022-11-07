import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sdomirea/main.dart';
import 'package:sdomirea/sdo_api/auth.dart';
import 'package:sdomirea/sdo_api/course_details.dart';
import 'package:sdomirea/sdo_api/courses.dart';
import 'package:shimmer/shimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../model/user.dart';
import 'package:sdomirea/utils.dart';

class CoursePage extends StatefulWidget {
  Course currentCourse;

  CoursePage({super.key, required this.title, required this.currentCourse});

  final String title;

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  bool isLoaded = false;
  CourseData data = CourseData([], Course("", ""));

  @override
  Widget build(BuildContext context) {
    if (SDOApp.session.isInitialized()) {
      EduCourses.getCourseContent(SDOApp.session, widget.currentCourse)
          .then((value) {
        data = value;

        setState(() {
          isLoaded = true;
        });
      });
    } else {
      data = SDOApp.base.courses[widget.currentCourse.id]!;
    }
    return Scaffold(
      backgroundColor: const Color(0xff011627),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: getCourseData(),
            ),
          )
        ],
      ),
    );
  }

  Widget getCourseData() {
    List<Widget> list = <Widget>[];
    if (data.blocks.isEmpty) {
      list.add(Shimmer.fromColors(
          baseColor: Colors.white,
          highlightColor: const Color(0xDBDBDBFF),
          child: _generateShimmer()));
    }
    for (var i = 0; i < data.blocks.length; i++) {
      list.add(Text(
        widget.currentCourse.title,
        style: const TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      for (var j = 0; j < data.blocks[i].urls.length; j++) {
        list.add(const SizedBox(
          height: 20,
        ));
        AssetImage icon = const AssetImage("assets/images/pdf.png");
        if (data.blocks[i].urls[j].icon == CourseUrlIcon.DOCUMENT) {
          icon = const AssetImage("assets/images/document.png");
        } else if (data.blocks[i].urls[j].icon == CourseUrlIcon.POWERPOINT) {
          icon = const AssetImage("assets/images/powerpoint.png");
        }
        list.add(MaterialButton(
            onPressed: () {
              tryDownload(data.blocks[i].urls[j]);
            },
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Image(
                    image: icon,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                SizedBox(
                    width: 250,
                    child: Text(
                      data.blocks[i].urls[j].name,
                      style: const TextStyle(color: Colors.white),
                    ))
              ],
            )));
      }
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

  Future<void> tryDownload(CourseUrl url) async {
    requestStoragePermission();
    if (SDOApp.base.downloadedCourses.keys.contains(url.url)) {
      OpenFile.open(SDOApp.base.downloadedCourses[url.url]!);
    } else {
      if (!SDOApp.session.isInitialized()) {
        User user = User.fromJson(
            jsonDecode(SDOApp.sharedPreferences.getString('user')!));
        MoodleSession session =
            await MireaAuth.requestAuthFromNetwork(user.login, user.password);
        SDOApp.session = session;
      }
      Directory? appDocDir = await getExternalStorageDirectory();
      String appDocPath = appDocDir!.absolute.path;
      await EduCourses.downloadCourse(url, appDocPath, SDOApp.session, () {},
          (file) {
        SDOApp.base.downloadedCourses[url.url] = file.path;
        SDOApp.updateCoursesBase();
        OpenFile.open(file.path);
      });
    }
  }

  Widget _generateShimmer() {
    List<Widget> widgets = [];
    widgets.add(Row(children: const [
      SizedBox(
          width: 200,
          height: 30,
          child: DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white38)))
    ]));
    for (int i = 0; i < 10; i++) {
      widgets.add(const SizedBox(
        height: 20,
      ));
      widgets.add(MaterialButton(
          onPressed: () => {},
          child: Row(
            children: const [
              SizedBox(
                width: 40,
                child: CircleAvatar(
                  radius: 20,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              SizedBox(
                  width: 250,
                  height: 20,
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white38)))
            ],
          )));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: widgets,
    );
  }
}

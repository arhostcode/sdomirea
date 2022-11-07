import 'dart:io';

import 'package:html/parser.dart' show parse;
import 'package:dio/dio.dart';
import 'package:sdomirea/sdo_api/auth.dart';
import 'package:sdomirea/sdo_api/utils/dio_helper.dart';

import 'course_details.dart';

class EduCourses {
  static Future<Map<String, CourseData>> getMyCourses(
      MoodleSession session) async {
    var dio = generateClient();
    List<Course> courses = <Course>[];

    await dio
        .get("https://online-edu.mirea.ru/my/",
            options:
                Options(headers: {"Cookie": "MoodleSession=${session.key}"}))
        .then((value) {
      var body = parse(value.data);
      if (body.getElementsByClassName("dropdown-menu").isEmpty) {
        throw CourseException();
      }
      body
          .getElementsByClassName("dropdown-menu")[0]
          .children
          .forEach((element) {
        if (element.attributes['href'] != null) {
          if (element.attributes['href']!.contains("?id=")) {
            courses.add(Course(element.attributes["href"]!.split("?id=")[1],
                element.attributes["title"]!));
          }
        }
      });
    });
    Map<String, CourseData> data = {};
    for (var element in courses) {
      data[element.id] = await EduCourses.getCourseContent(session, element);
    }
    return data;
  }

  static Future<CourseData> getCourseContent(
      MoodleSession session, Course course) async {
    var dio = generateClient();

    List<CourseBlock> courseBlocks = [];

    await dio
        .get("https://online-edu.mirea.ru/course/view.php?id=${course.id}",
            options:
                Options(headers: {"Cookie": "MoodleSession=${session.key}"}))
        .then((value) {
      var e = parse(value.data);
      e.getElementsByClassName("topics").forEach((element) {
        var title =
            element.getElementsByClassName("sectionname")[0].children[0].text;
        List<CourseUrl> urls = [];
        element.getElementsByClassName("aalink").forEach((link) {
          var linkTitle =
              link.getElementsByClassName("instancename")[0].innerHtml;
          if (link
              .getElementsByClassName("instancename")[0]
              .children
              .isNotEmpty) {
            linkTitle = linkTitle.replaceAll(
                link
                    .getElementsByClassName("instancename")[0]
                    .children[0]
                    .outerHtml,
                "");
          }
          urls.add(CourseUrl(
              link.attributes['href'] == null ? "" : link.attributes['href']!,
              linkTitle,
              CourseUrlIcon.getIcon(link
                  .getElementsByClassName("activityicon")[0]
                  .attributes["src"]!)));
        });
        courseBlocks.add(CourseBlock(title, urls));
      });
    });

    return CourseData(courseBlocks, course);
  }

  static Future<void> downloadCourse(
      CourseUrl url,
      String dir,
      MoodleSession session,
      Function onReceive,
      Function(File) whenFinished) async {
    Dio dio = generateClient();
    try {
      Response response = await dio.get(
        url.url,
        onReceiveProgress: (a, b) => onReceive,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            validateStatus: (status) {
              return status! < 500;
            },
            headers: {"Cookie": "MoodleSession=${session.key}"}),
      );
      if (response.realUri.toString().endsWith(".pdf") ||
          response.realUri.toString().endsWith(".doc") ||
          response.realUri.toString().endsWith(".docx") ||
          response.realUri.toString().endsWith(".ppt") ||
          response.realUri.toString().endsWith(".pptx")) {
        File file = File(
            "$dir/${url.name}.${response.realUri.toString().split(".")[response.realUri.toString().split(".").length - 1]}");
        var raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        await raf.close();
        whenFinished(file);
      } else {
        throw CourseException();
      }
    } catch (ignored) {}
  }
}

class Course {
  String id = "";
  String title = "";

  Course(this.id, this.title);

  @override
  String toString() {
    return 'Course{id: $id, title: $title}';
  }

  factory Course.fromJson(Map<String, dynamic> parsedJson) {
    return Course(parsedJson['id'] ?? "", parsedJson['title'] ?? "");
  }

  Map toJson() => {'id': id, 'title': title};
}

class CourseException extends IOException {
  @override
  String toString() {
    return "Course can`t be loaded";
  }
}

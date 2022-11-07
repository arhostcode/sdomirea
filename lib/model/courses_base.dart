import 'package:sdomirea/sdo_api/course_details.dart';

class CoursesBase {
  Map<String, CourseData> courses = {};
  Map<String, String> downloadedCourses = {};

  CoursesBase({required this.courses, required this.downloadedCourses});

  factory CoursesBase.fromJson(Map<String, dynamic> parsedJson) {
    Map<String, dynamic> parsedCourses = parsedJson['courses'];
    Map<String, dynamic> parsedDownloads = parsedJson['downloadedCourses'];

    return CoursesBase(courses: parsedCourses.map((key, value) =>
        MapEntry(key, CourseData.fromJson(value as Map<String, dynamic>))), downloadedCourses: parsedDownloads.map((key, value) => MapEntry(key, value.toString())));
  }

  Map<String, dynamic> toJson() {
    return {"courses": courses, "downloadedCourses": downloadedCourses};
  }

  @override
  String toString() {
    return 'CoursesBase{courses: $courses, downloadedCourses: $downloadedCourses}';
  }
}

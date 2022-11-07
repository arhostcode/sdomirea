import 'courses.dart';

class CourseData {
  List<CourseBlock> blocks = [];
  Course course;

  CourseData(this.blocks, this.course);

  @override
  String toString() {
    return 'CourseData{blocks: $blocks, course: $course}';
  }

  Map toJson() => {'course': course, 'blocks': blocks};

  factory CourseData.fromJson(Map<String, dynamic> parsedJson) {
    List<CourseBlock> list = [];
    Course course = Course("", "");

    if (parsedJson['blocks'] != null) {
      List<dynamic> parsedBlocks = parsedJson['blocks'];
      list =
          List.from(parsedBlocks.map((model) => CourseBlock.fromJson(model)));
    }
    if (parsedJson['course'] != null) {
      course = Course.fromJson(parsedJson['course']);
    }

    return CourseData(list, course);
  }
}

class CourseBlock {
  String title = "";
  List<CourseUrl> urls = [];

  CourseBlock(this.title, this.urls);

  @override
  String toString() {
    return 'CourseBlock{title: $title, urls: $urls}';
  }

  Map toJson() => {
        'title': title,
        'urls': urls,
      };

  factory CourseBlock.fromJson(Map<String, dynamic> parsedJson) {
    List<CourseUrl> list = [];

    if (parsedJson['urls'] != null) {
      List<dynamic> parsedUrls = parsedJson['urls'];
      list = List.from(parsedUrls.map((e) => CourseUrl.fromJson(e)));
    }

    return CourseBlock(parsedJson['title'] ?? "", list);
  }
}

class CourseUrl {
  String url = "";
  String name = "";
  CourseUrlIcon icon = CourseUrlIcon.PDF;

  CourseUrl(this.url, this.name, this.icon);

  @override
  String toString() {
    return 'CourseUrl{url: $url, name: $name, icon: $icon}';
  }

  Map toJson() => {'url': url, 'name': name, 'icon': icon.toString()};

  factory CourseUrl.fromJson(Map<String, dynamic> parsedJson) {
    return CourseUrl(parsedJson['url'] ?? "", parsedJson['name'] ?? "",
        CourseUrlIcon.fromString(parsedJson['icon'] ?? "CourseUrlIcon.PDF"));
  }
}

enum CourseUrlIcon {
  POWERPOINT,
  PDF,
  DOCUMENT;

  static CourseUrlIcon getIcon(String url) {
    if (url.endsWith("document")) {
      return DOCUMENT;
    } else if (url.endsWith("powerpoint")) {
      return POWERPOINT;
    } else if (url.endsWith("PDF")) {
      return PDF;
    }
    return PDF;
  }

  static CourseUrlIcon fromString(String s) {
    for (var e in CourseUrlIcon.values) {
      if (e.toString() == s) return e;
    }
    return PDF;
  }
}

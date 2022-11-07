import 'dart:io';

import 'package:html/parser.dart' show parse;
import 'package:dio/dio.dart';
import 'package:sdomirea/sdo_api/utils/dio_helper.dart';

class MireaAuth {
  static Future<MoodleSession> requestAuthFromNetwork(
      String login, String password) async {
    var moodleToken = "";
    var loginToken = "";
    var originalToken = "";

    Dio dio = generateClient();

    await dio.get("https://online-edu.mirea.ru/").then((value) {
      for (var element in value.headers["set-cookie"]!) {
        if (element.contains('MoodleSession=')) {
          moodleToken =
              element.split(";")[0].replaceFirst("MoodleSession=", "");
        }
      }
      var body = parse(value.data);
      body.getElementsByTagName("input").forEach((element) {
        if (element.attributes['name'] == "logintoken") {
          loginToken = element.attributes["value"]!;
        }
      });
    }).onError((error, stackTrace) => throw AuthException());

    await dio
        .post("https://online-edu.mirea.ru/login/index.php",
            data: {
              "username": login,
              "password": password,
              "logintoken": loginToken
            },
            options: Options(
                followRedirects: false,
                headers: {
                  "Cookie": "MoodleSession=$moodleToken",
                  "Content-Type": "application/x-www-form-urlencoded",
                  "Accept":
                      "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
                },
                validateStatus: (status) {
                  return status! < 500;
                }))
        .then((value) {
      if (value.headers["set-cookie"] != null) {
        for (var cookie in value.headers["set-cookie"]!) {
          if (cookie.contains('MoodleSession=')) {
            originalToken =
                cookie.split(";")[0].replaceFirst("MoodleSession=", "");
          }
        }
      } else {
        throw AuthException();
      }
    }).onError((error, stackTrace) => throw AuthException());

    if (originalToken.isEmpty) throw AuthException();

    return MoodleSession(originalToken);
  }
}

class MoodleSession {
  String key = "";

  MoodleSession(this.key);

  static MoodleSession NULL = MoodleSession("");

  bool isInitialized() => key.isNotEmpty;

  @override
  String toString() {
    return 'MoodleSession{key: $key}';
  }
}

class AuthException extends IOException {
  @override
  String toString() {
    return "Can`t auth";
  }
}

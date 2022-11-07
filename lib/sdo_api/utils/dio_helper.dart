import 'package:dio/dio.dart';
import 'package:dio/src/adapters/io_adapter.dart';
import 'dart:io';

Dio generateClient() {
  Dio dio = Dio();
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (var client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  return dio;
}

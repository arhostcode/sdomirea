import 'package:permission_handler/permission_handler.dart';

requestStoragePermission() async {
  if (!await Permission.storage.isGranted) {
    await Permission.storage.request();
  }
}

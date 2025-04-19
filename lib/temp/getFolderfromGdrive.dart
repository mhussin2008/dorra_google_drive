import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [drive.DriveApi.driveReadonlyScope],
);

Future<void> downloadFolder( ) async {
  final folderId="https://drive.google.com/drive/folders/1VWpAQ8MVf-jaJcpFeGRd2i8vHDxmY32h?usp=drive_link";
  final Directory localPath=await getApplicationDocumentsDirectory();
  final GoogleSignInAccount? user = await _googleSignIn.signIn();
  final authHeaders = await user?.authHeaders;
  final httpClient = IOClient();

  final driveApi = drive.DriveApi(httpClient);

  // Get folder contents
  var fileList = await driveApi.files.list(q: "'$folderId' in parents");
  print(fileList);

  // for (var file in fileList.files!) {
  //   if (file.mimeType != 'application/vnd.google-apps.folder') {
  //     var response = await http.get(Uri.parse(file.webContentLink ?? ''));
  //     // Save file locally (implement file saving logic)
  //   }
  // }
}
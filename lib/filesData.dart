import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'links.dart';

class Data {
  static ValueNotifier<String> newProgress = ValueNotifier<String>('');
  static List<String> filesSignature = [];
  // static List<String> fileIdList = [
  //   "https://drive.google.com/file/d/1fRwThIpPdQenhlHxKiR8OAfeSE0WwoF6/view?usp=drive_link",
  //   "https://drive.google.com/file/d/1vQUqNdVPFtBUIWqpkTKgedFR1860pmN0/view?usp=drive_link",
  //   "https://drive.google.com/file/d/1ILq91f_NkOmEnmocnI_gtUqIxsAm0jmf/view?usp=drive_link",
  //   "https://drive.google.com/file/d/1Fa0EIjwIUBW1vhV6GIlCaKlYY0rvjZcA/view?usp=drive_link",
  //   "https://drive.google.com/file/d/1EetE4LHeVap4BYV17Nv4-i3Q3nuLk2rT/view?usp=drive_link"
  // ];

  static List<Uint8List> fileData = List.filled(
    links.links_List.length,
    Uint8List(0),
  ); //Uint8List(0);

  static const String fileName = 'picture';
  static List<bool> fileExists = List<bool>.filled(
    links.links_List.length,
    false,
  );
  static List<bool> fileSignOk = List<bool>.filled(
    links.links_List.length,
    false,
  );
  static bool downloadDone = false;
  static List<String> picturePath = [];
  static int mainCounter = 0;

  static Future<void> downloadFiles() async {
    Dio _dio = Dio();
    String url = '';
    Directory appDocDir = await getApplicationDocumentsDirectory();
    picturePath.clear();
    for (int i = 0; i < links.links_List.length; i++) {
      int p = links.links_List[i].indexOf('/d/');

      int e = links.links_List[i].indexOf('/view?');
      String s = links.links_List[i].substring(p + 3, e);

      url = 'https://drive.google.com/uc?id=$s';
      picturePath.add('${appDocDir.path}/$fileName$i.jpg');

      if (fileExists[i] == false) {
        try {
          //var downloadedData;

          var response = await _dio.download(
            url,
            picturePath[i],
            onReceiveProgress: (received, total) {
              if (total != -1) {
                newProgress.value =
                    'file no: $i ${(received / total * 100).toStringAsFixed(0)}%';
              }
            },
            //data: downloadedData
          );

          print(
            'File downloaded to ${picturePath[i]}  Response=${response.statusMessage}',
          );
          //print(downloadedData);
        } catch (e) {
          print(e);
          print('Error downloading file');
        }
      }
    }
  }

  static Future<void> checkStoredPictures() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    picturePath.clear();
    for (int i = 0; i < links.links_List.length; i++) {
      var file = File('${appDocDir.path}/$fileName$i.jpg');
      picturePath.add('${appDocDir.path}/$fileName$i.jpg');
      fileExists[i] = file.existsSync();
    }

    int storedFilesCount = fileExists.where((test) => test).length;
    print(fileExists[200]);
    print('$storedFilesCount out of ${links.links_List.length} files stored');

    List<bool> checklist = List<bool>.filled(links.links_List.length, true);
    if (listEquals(
          fileExists,
          List<bool>.filled(links.links_List.length, true),
        ) ==
        true) {
      downloadDone = true;
      print('downloadDone=$downloadDone');
    }
  }

  static Future<void> deleteExistingFiles() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    for (int i = 0; i < links.links_List.length; i++) {
      var file = File('${appDocDir.path}/$fileName$i.jpg');
      var tempfileExists = file.existsSync();
      if (tempfileExists == true) {
        await file.delete();
        fileExists[i] = false;

        print('$file was deleted');
      } else {
        print('$file doesnt exist');
      }
    }
    downloadDone = false;
  }

  static Future<String> calculateSHA256(List<int> data) async {
    final sha256Digest = sha256.convert(data);
    return sha256Digest.toString();
  }

  static Future<Uint8List> readFileBytesU(String filePath) async {
    final File file = File(filePath);
    //file.copy('${filePath}n');

    return await file.readAsBytes();
  }

  static Future<Uint8List> readFileBytes(String filePath) async {
    final file = File(filePath);
    return await file.readAsBytes();
  }

  static Future<void> calculateFilesSignature() async {
    filesSignature.clear();
    for (int i = 0; i < fileExists.length; i++) {
      if (fileExists[i]) {
        filesSignature.add(
          await calculateSHA256(await readFileBytes(picturePath[i])),
        );
      }
    }
  }

  static Future<void> saveFilesSignature() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('Signature', filesSignature);
  }

  static Future<void> getSignatures() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //  final preferences = await SharedPreferencesWithCache.create(
    //    cacheOptions: const SharedPreferencesWithCacheOptions(allowList: null),
    //  );
    filesSignature = prefs.getStringList('Signature') ?? [];
    if (filesSignature.isNotEmpty) {
      print(filesSignature);
    } else {
      print('Empty Signature file');
    }
  }

  static Future<void> checkSignatures() async {
    if (filesSignature.isEmpty) {
      print('Empty Signature File');
      return;
    }
    for (int i = 0; i < picturePath.length; i++) {
      if (filesSignature[i] == await calculateSHA256(Data.fileData[i])) {
        fileSignOk[i] = true;
        print('Signature of File # ${i + 1} is ok');
      } else {
        print(
          '''Signature of File # ${i + 1} doesn't match , file may be corrupted''',
        );
      }
    }
  }

  static Future<Uint8List> _readFileByte(String filePath) async {
    Uri myUri = Uri.parse(filePath);
    File audioFile = new File.fromUri(myUri);
    Uint8List bytes = Uint8List(0);
    await audioFile
        .readAsBytes()
        .then((value) {
          bytes = Uint8List.fromList(value);
          print('reading of bytes is completed');
        })
        .catchError((onError) {
          print('Exception Error while reading audio from path:$onError');
        });
    return bytes;
  }

  static loadStoredPictures() async {
    for (int i = 0; i < Data.fileExists.length; i++) {
      if (Data.fileExists[i] == true) {
        Data.fileData[i] = await readFileBytes(Data.picturePath[i]);
      }
    }
  }
}

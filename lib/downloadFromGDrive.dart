import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'filesData.dart';
import 'progressWidget.dart';
class DownloadFileWidget extends StatefulWidget {
  const DownloadFileWidget({super.key});

  @override
  _DownloadFileWidgetState createState() => _DownloadFileWidgetState();
}
class _DownloadFileWidgetState extends State<DownloadFileWidget> {
   @override
  void initState() {
    print('started initState');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Called checkStoredPictures Function');
      await Data.checkStoredPictures();
      await Data.getSignatures();
      await Data.loadStoredPictures();
      await Data.checkSignatures();


      print('Finished checkStoredPictures Function');
      setState(() {
        print('Called Setstate from initState');
      });
    });
    print("//${super.widget.toStringDeep()}");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    print('main Screen Rebuild counter ${Data.mainCounter++}');
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              color: Colors.cyan,
              width: double.infinity,
              height: 400,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const ProgressWidget(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        print(Data.fileExists);
                        print(Data.picturePath);
                      },
                      child: const Text('Debugger')),
                  ElevatedButton(
                    onPressed: () async {
                      await Data.downloadFiles();
                      await Data.checkStoredPictures();
                      await Data.calculateFilesSignature();
                      await Data.saveFilesSignature();
                      setState(() {});
                    },
                    child: const Text('Download Files'),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        await Data.deleteExistingFiles();
                        await Data.checkStoredPictures();

                        setState(() {});
                      },
                      child: const Text('Delete Existing Files')),
                  ElevatedButton(
                      onPressed: () async {
                        await Data.getSignatures();
                        await Data.checkSignatures();
                      },
                      child: const Text('Check Signatures')),
                  ElevatedButton(
                    onPressed: () async {
                      await SystemNavigator.pop();
                      exit(0);
                    },
                    child: const Text('Exit'),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        Data.fileData[0] =
                            await Data.readFileBytesU(Data.picturePath[0]);

                        print(Data.fileData[0].length);
                        setState(() {});
                      },
                      child: Text('get data'))
                ],
              ),
            ),
            Data.fileData[0].isNotEmpty
                ? Image.memory(Data.fileData[0])
                : const Text('Image Not Found'),
            ...{
              for (int i = 0; i < Data.fileExists.length; i++)
                (Data.fileExists[i])
                    //(File(data.picturePath[i]).existsSync())
                    ? Image.file(width: 100, File(Data.picturePath[i]))
                    : const CircleAvatar()
            },
          ],
        ),
      ),
    );
  }

  // Future<void> downloadFiles() async {
  //   Directory appDocDir = await getApplicationDocumentsDirectory();
  //   data.picturePath.clear();
  //   for (int i = 0; i < data.fileIdList.length; i++) {
  //     int p = data.fileIdList[i].indexOf('/d/');
  //
  //     int e = data.fileIdList[i].indexOf('/view?');
  //     String s = data.fileIdList[i].substring(p + 3, e);
  //
  //     url = 'https://drive.google.com/uc?id=${s}';
  //     data.picturePath.add('${appDocDir.path}/${data.fileName}$i.jpg');
  //
  //     if (data.fileExists[i] == false) {
  //       try {
  //         //var downloadedData;
  //
  //         var response = await _dio.download(
  //           url,
  //           data.picturePath[i],
  //           onReceiveProgress: (received, total) {
  //             if (total != -1) {
  //               data.newProgress.value =
  //                   'file no: $i ${(received / total * 100).toStringAsFixed(0)}%';
  //             }
  //           },
  //           //data: downloadedData
  //         );
  //
  //         print(
  //             'File downloaded to ${data.picturePath[i]}  Response=${response.statusMessage}');
  //         //print(downloadedData);
  //       } catch (e) {
  //         print(e);
  //         print('Error downloading file');
  //       }
  //     }
  //   }
  // }
  //
  // Future<void> checkStoredPictures() async {
  //   Directory appDocDir = await getApplicationDocumentsDirectory();
  //   data.picturePath.clear();
  //   for (int i = 0; i < data.fileIdList.length; i++) {
  //     var file = File('${appDocDir.path}/${data.fileName}$i.jpg');
  //     data.picturePath.add('${appDocDir.path}/${data.fileName}$i.jpg');
  //     data.fileExists[i] = file.existsSync();
  //
  //     {
  //       print('$file  exists: ${data.fileName}$i =${data.fileExists[i]}');
  //     }
  //     ;
  //   }
  //
  //   List<bool> checklist = List<bool>.filled(data.fileIdList.length, true);
  //   print('datafile exists=${data.fileExists}');
  //   print('check list=$checklist');
  //   if (listEquals(
  //           data.fileExists, List<bool>.filled(data.fileIdList.length, true)) ==
  //       true) {
  //     data.downloadDone = true;
  //     print('data.downloadDone=${data.downloadDone}');
  //   }
  // }
  //
  // Future<void> deleteExistingFiles() async {
  //   Directory appDocDir = await getApplicationDocumentsDirectory();
  //   for (int i = 0; i < data.fileIdList.length; i++) {
  //     var file = File('${appDocDir.path}/${data.fileName}$i.jpg');
  //     var fileExists = file.existsSync();
  //     if (fileExists == true) {
  //       await file.delete();
  //       data.fileExists[i] = false;
  //
  //       print('$file was deleted');
  //     } else {
  //       print('$file doesnt exist');
  //     }
  //   }
  //   data.downloadDone = false;
  // }
  //
  // Future<String> calculateSHA256(List<int> data) async {
  //   final sha256Digest = sha256.convert(data);
  //   return sha256Digest.toString();
  // }
  //
  // Future<Uint8List> readFileBytesU(String filePath) async {
  //   final file = File(filePath);
  //   file.copy('${filePath}n');
  //   data.fileData.hashCode;
  //   return await file.readAsBytes();
  // }
  //
  // Future<List<int>> readFileBytes(String filePath) async {
  //   final file = File(filePath);
  //   return await file.readAsBytes();
  // }
  //
  // Future<void> calculateFilesSignature() async {
  //   data.filesSignature.clear();
  //   for (int i = 0; i < data.fileExists.length; i++) {
  //     if (data.fileExists[i]) {
  //       data.filesSignature.add(
  //           await calculateSHA256(await readFileBytes(data.picturePath[i])));
  //     }
  //   }
  // }
  //
  // Future<void> saveFilesSignature() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setStringList('Signature', data.filesSignature);
  // }
  //
  // Future<void> getSignatures() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   //  final preferences = await SharedPreferencesWithCache.create(
  //   //    cacheOptions: const SharedPreferencesWithCacheOptions(allowList: null),
  //   //  );
  //   data.filesSignature = prefs.getStringList('Signature') ?? [];
  //   if (data.filesSignature.isNotEmpty) {
  //     print(data.filesSignature);
  //   } else {
  //     print('Empty Signature file');
  //   }
  // }
  //
  // Future<void> checkSignatures() async {
  //   if (data.filesSignature.isEmpty) {
  //     print('Empty Signature File');
  //     return;
  //   }
  //   for (int i = 0; i < data.fileExists.length; i++) {
  //     if (data.filesSignature[i] ==
  //         await calculateSHA256(await readFileBytes(data.picturePath[i]))) {
  //       print('Signature of File # ${i + 1} is ok');
  //     } else {
  //       print(
  //           '''Signature of File # ${i + 1} doesn't match , file may be corrupted''');
  //     }
  //   }
  // }
  //
  // Future<Uint8List> _readFileByte(String filePath) async {
  //   Uri myUri = Uri.parse(filePath);
  //   File audioFile = new File.fromUri(myUri);
  //   Uint8List bytes = Uint8List(0);
  //   await audioFile.readAsBytes().then((value) {
  //     bytes = Uint8List.fromList(value);
  //     print('reading of bytes is completed');
  //   }).catchError((onError) {
  //     print('Exception Error while reading audio from path:$onError');
  //   });
  //   return bytes;
  // }
}

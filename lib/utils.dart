import 'dart:io';

class Utils {
  Future<void> write() async {
    File file = File('C:\\unapec\\nomina.txt');
    await file.writeAsString('');
  }
}

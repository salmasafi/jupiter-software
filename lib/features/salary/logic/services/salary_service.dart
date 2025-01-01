import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class SalaryService {
  final Key _key =
      Key.fromUtf8('my32lengthsupersecretnooneknows1'); // المفتاح للتشفير
  final IV _iv = IV.fromLength(16); // المتجه الابتدائي للتشفير
  late final Encrypter _encrypter;

  SalaryService() {
    _encrypter =
        Encrypter(AES(_key, mode: AESMode.cbc)); // التأكد من استخدام نفس الوضع
  }

  // تشفير
  Future<String> encryptSalary(String salary) async {
    try {
      final encrypted = _encrypter.encrypt(salary, iv: _iv);
      final encodedSalary =
          base64.encode(encrypted.bytes); // استخدام ترميز محدد
      print('Encrypted salary: $encodedSalary'); // طباعة النص المشفر
      return encodedSalary;
    } catch (e) {
      print('Error saving salary: $e');
      return '0';
    }
  }

  // استرجاع وفك تشفير
  Future<String?> decryptSalary(String encryptedSalary) async {
    try {
      final decodedBytes =
          base64.decode(encryptedSalary); // فك الترميز باستخدام نفس الطريقة
      final decryptedSalary =
          _encrypter.decrypt(Encrypted(decodedBytes), iv: _iv);
      print('Decrypted salary: $decryptedSalary'); // طباعة النص المفكوك
      return decryptedSalary;
    } catch (e) {
      print('Error retrieving salary: $e');
      return null;
    }
  }
}

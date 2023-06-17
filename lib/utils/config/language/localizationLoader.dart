import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationLoader {
  static Map<dynamic, dynamic> localizedValues = {};

  static Future<void> load(Locale? locale) async {
    bool loadTR = false; // Later will be set as false
    bool loadEN = false;// Later will be set as false

    if (locale != null) {
      if (locale.languageCode == 'tr') {
        loadTR = true;
      } else if (locale.languageCode == 'en') {
        loadEN = true;
      }
    } else {
      loadTR = true;
      loadEN = true;
    }

    Map<dynamic, dynamic>   enValues = {};
    Map<dynamic, dynamic>   trValues = {};

    if (loadEN) {
      String enJson = await rootBundle.loadString('assets/languages/en.json');
      Map<String, dynamic> enMap = jsonDecode(enJson);
      enValues = enMap;
    }

    if (loadTR) {
      String trJson = await rootBundle.loadString('assets/languages/tr.json');
      Map<String, dynamic> trMap = jsonDecode(trJson);
      trValues = trMap;
    }

    localizedValues = {
      if (loadEN) 'en': enValues,
      if (loadTR) 'tr': trValues,
    };
  }

  static Future<String> getNextString() async {
    return StringIterator.getNextString();
  }

}

class StringIterator {
  static List<String> _strings = ['en', 'tr']; // Burada saklanacak string listesi
  static int _currentIndex = 0; // Şu anki index

  static void setStrings(List<String> strings) {
    _strings = strings; // Listeyi ayarla
    _currentIndex = 0; // İndeksi sıfırla
  }

  static String getNextString() {
    if (_strings.isEmpty) return ""; // Liste boşsa boş bir string döndür
    String currentString = _strings[_currentIndex]; // Mevcut stringi al
    _currentIndex = (_currentIndex + 1) % _strings.length; // İndeksi bir sonraki stringe kaydır, dizi sonuna geldiysek başa döndür
    return currentString;
  }
}

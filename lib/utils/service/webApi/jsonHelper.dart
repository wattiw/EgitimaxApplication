import 'dart:convert';
import 'package:flutter/material.dart';

class JsonHelper {
  static String encode(Object object) {
    try {
      return jsonEncode(object, toEncodable: (dynamic item) {
        if (item is DateTime) {
          return item.toIso8601String();
        } else if (item is BigInt) {
          return item.toString();
        } else if (item is double && (item.isInfinite || item.isNaN)) {
          return item.toString();
        } else {
          return item;
        }
      });
    } catch (e) {
      debugPrint("Error encoding json: $e");
      return "";
    }
  }

  static Map<String, dynamic> decode(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      debugPrint("Error decoding json: $e");
      return {};
    }
  }
}

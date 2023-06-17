import 'package:egitimaxapplication/utils/config/language/localizationLoader.dart';
import 'package:egitimaxapplication/utils/constant/language/appLocalizationConstant.dart';
import 'package:flutter/material.dart';

class AppLocalization {
  static final AppLocalization _singleton = AppLocalization._internal();

  Locale locale;

  AppLocalization._internal()
      : locale = AppLocalizationConstant.DefaultLocale;

  static AppLocalization get instance => _singleton;

  static const LocalizationsDelegate<AppLocalization> delegate =
  _AppLocalizationDelegate();

  static Map<dynamic, dynamic> _localizedValues = {};

  String translate(String? groupName,
      [String? sectionName, String? key]) {
    var concatParams=concatLocalizedValueParams(locale.languageCode,groupName,sectionName,key);

    if (groupName == null || _localizedValues[locale.languageCode] == null) {
      return concatParams;
    }

    if (sectionName == null) {
      return _localizedValues[locale.languageCode]![groupName] ?? concatParams;
    }

    if (key == null) {
      return _localizedValues[locale.languageCode]![groupName]?[sectionName] ?? concatParams;
    }

    return _localizedValues[locale.languageCode]![groupName]?[sectionName]?[key] ?? concatParams;
  }

  String concatLocalizedValueParams(String? languageCode, String? groupName,
      [String? sectionName, String? key]) {
    if (groupName == null) {
      return "null";
    }
    String params = languageCode ?? "";
    params += "/$groupName";
    if (sectionName != null) {
      params += "/$sectionName";
    }
    if (key != null) {
      params += "/$key";
    }
    return params;
  }

  Future<void> load(Locale? _locale) async {
    await LocalizationLoader.load(_locale);
    _localizedValues = LocalizationLoader.localizedValues;
    locale = _locale!;
  }

  static Future<void> init() async {
    Locale? locale = const Locale('tr', 'TR');
    if (WidgetsBinding.instance?.window != null) {
      locale = WidgetsBinding.instance!.window.locale;
    }
    await _singleton.load(locale);
  }


  static Future<void> changeLocale(Locale locale) async {
    await _singleton.load(locale);
  }
}

class _AppLocalizationDelegate
    extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    await AppLocalization.instance.load(locale);
    return AppLocalization.instance;
  }

  @override
  bool shouldReload(_AppLocalizationDelegate old) {
    return false;
  }
}

import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';

extension IntKeyValueListTranslateExtension on   Map<int,String>{


  Map<int,String>  translate()
  {
    Map<int,String> newKeyValueList={};

    for(var entry in entries)
      {
        newKeyValueList[entry.key]=AppLocalization.instance.translate('lib.utils.extension.keyValueListTranslateExtension', 'IntKeyValueListTranslateExtension', entry.value);
      }

    return newKeyValueList;
  }


}

extension BigIntKeyValueListTranslateExtension on Map<BigInt,String> {

  Map<BigInt,String>  translate()
  {
    Map<BigInt,String> newKeyValueList={};

    for(var entry in entries)
    {
      newKeyValueList[entry.key]=AppLocalization.instance.translate('lib.utils.extension.keyValueListTranslateExtension', 'BigIntKeyValueListTranslateExtension', entry.value);
    }

    return newKeyValueList;
  }

}
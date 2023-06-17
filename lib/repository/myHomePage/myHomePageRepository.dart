
import 'package:egitimaxapplication/utils/constant/service/webApi/apiBasicAuthorizationConstant.dart';
import 'package:egitimaxapplication/utils/constant/service/webApi/apiBearerAuthorizationConstant.dart';
import 'package:egitimaxapplication/utils/service/webApi/apiBasicAuthorization.dart';
import 'package:egitimaxapplication/utils/service/webApi/apiBearerAuthorization.dart';

class MyHomePageRepository {
  List<String> _data = ['Item 1', 'Item 2', 'Item 3'];

  // private constructor
  MyHomePageRepository._privateConstructor();

  // singleton instance
  static final MyHomePageRepository _instance =
  MyHomePageRepository._privateConstructor();

  // factory constructor to return the singleton instance
  factory MyHomePageRepository() {
    return _instance;
  }

  Future<List<String>> getData() async {

    await Future.delayed(Duration(seconds: 3));
    return _data;
  }

  Future<int> addData(List<String> data) async {



    await Future.delayed(Duration(seconds: 2));
    return 1;
  }

  Future<int> updateData(List<String> data) async {
    // Örnek olarak, bir API'dan öğeleri alıyormuş gibi yapıyoruz.
    await Future.delayed(Duration(seconds: 2));
    return 0;
  }

  Future<int> deleteData(List<String> data) async {
    // Örnek olarak, bir API'dan öğeleri alıyormuş gibi yapıyoruz.
    await Future.delayed(Duration(seconds: 2));
    return 2;
  }

  Future<int> removeData(List<String> data) async {
    // Örnek olarak, bir API'dan öğeleri alıyormuş gibi yapıyoruz.
    await Future.delayed(Duration(seconds: 2));
    return 99;
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:egitimaxapplication/utils/config/language/appLocalizations.dart';
import 'package:egitimaxapplication/utils/constant/appConstant/generalAppConstant.dart';
import 'package:egitimaxapplication/utils/constant/service/webApi/apiBearerAuthorizationConstant.dart';
import 'package:egitimaxapplication/utils/service/webApi/jsonHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:requests/requests.dart';

class ApiBearerAuthorization {
  final String baseUrl = ApiBearerAuthorizationConstant.baseUrl;
  final String username = ApiBearerAuthorizationConstant.username;
  final String password = ApiBearerAuthorizationConstant.password;
  String authToken = "";
  String urlAuthToken = ApiBearerAuthorizationConstant.urlAuthToken;

  ApiBearerAuthorization();

  Future<String?> uploadVideo(Uint8List? fileContent,
      {String? fileName}) async {
    if (fileContent == null) {
      // Handle the case when no file was selected or an error occurred during file picking
      debugPrint('No file selected or an error occurred');
      return '';
    }

    var uri = Uri.parse('$baseUrl' 'Video/VideoUpload');
    var request = http.MultipartRequest('POST', uri);

    var fileBytes = fileContent.buffer.asUint8List();
    var multipartFile = http.MultipartFile.fromBytes(
      'videoFile',
      fileBytes,
      filename: fileName ?? 'video_file.mp4',
      // Provide a default filename or customize it as needed
      contentType: MediaType(
          'video', 'mp4'), // Adjust the media type based on the file format
    );
    request.files.add(multipartFile);
    request.headers.addAll(
        _headers()); // Make sure you have _headers() implemented correctly

    try {
      var response = await request.send();
      var responseData = await response.stream
          .bytesToString(); // Retrieve the response data as a string
      debugPrint(responseData);
      var parsedData = jsonDecode(responseData);
      var objectId = parsedData['data'][0]['ObjectId'];

      if (response.statusCode == 200) {
        debugPrint('Video saved to NoSql');
        return objectId;
      } else {
        debugPrint('Error: ${response.statusCode} ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      debugPrint('Error uploading video: $error');
      return null;
    }
  }

  Future<Uint8List?> downloadVideo(String videoId) async {
    var url = '$baseUrl' 'Video/VideoDownload/$videoId';

    try {
      var response = await http.get(Uri.parse(url), headers: _headers());

      if (response.statusCode == 200) {
        var contentType = response.headers['content-type'];
        var contentDisposition = response.headers['content-disposition'];

        if (contentDisposition != null) {
          var fileName = contentDisposition
              .split(';')
              .firstWhere((part) => part.trim().startsWith('filename='))
              .split('=')
              .last
              .trim();

          debugPrint('Video downloaded: $fileName');
          return response.bodyBytes;
        } else {
          debugPrint('Content disposition header not found');
          return response.bodyBytes;
        }
      } else {
        debugPrint('Error: ${response.statusCode} ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      debugPrint('Error downloading video: $error');
    }

    return null;
  }

  Future<bool?> deleteVideo(String videoId) async {
    var url = '$baseUrl' 'Video/VideoDelete/$videoId';

    try {
      var response = await http.get(Uri.parse(url), headers: _headers());

      if (response.statusCode == 200) {
        debugPrint('Video deleted');
        return true;
      } else {
        debugPrint('Error: ${response.statusCode} ${response.reasonPhrase}');
        return false;
      }
    } catch (error) {
      debugPrint('Error deleting video: $error');
      return false;
    }

    return null;
  }

  Future<String> getAuthToken() async {
    Map<String, dynamic> data = {"userName": username, "password": password};

    final response = await http.post(Uri.parse(urlAuthToken),
        headers: _headers(), body: json.encode(data));

    authToken = _response(response)['token'];
    return authToken;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      if (authToken.isEmpty) {
        authToken = await getAuthToken();
      }
      var url = Uri.parse(baseUrl + endpoint);
      var response = await Requests.get(url.toString(),
          headers: _headers(), timeoutSeconds: 10);
      //final response =await http.get(Uri.parse(baseUrl + endpoint), headers: _headers());

      return _response(response);
    } catch (e) {
      debugPrint(e.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    if (authToken.isEmpty) {
      authToken = await getAuthToken();
    }

    int retryCount = 0;
    while (retryCount < GeneralAppConstant.HttpRequestReTryCount) {
      try {
        var bodyData = JsonHelper.encode(data);
        var requestData = jsonDecode(bodyData);
        String url = Uri.parse(baseUrl + endpoint).toString();
        var response = await Requests.post(url,
            body: requestData,
            headers: _headers(),
            timeoutSeconds: GeneralAppConstant.HttpRequesTimeOut,
            bodyEncoding: RequestBodyEncoding.JSON);

        //var response = await Requests.post(url.toString(),headers:  _headers(),body: bodyData,timeoutSeconds: 10);
        //final response = await http.post(Uri.parse(baseUrl + endpoint),headers: _headers(), body: bodyData);

        return _response(response);
        return _response(response);
      } catch (e) {
        debugPrint(e.toString());
        retryCount++;
        await Future.delayed(Duration(seconds: 1));
      }
    }

    return {}; // Return an empty map if retries fail
  }

  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      if (authToken.isEmpty) {
        authToken = await getAuthToken();
      }

      var bodyData = JsonHelper.encode(data);
      var requestData = jsonDecode(bodyData);
      String url = Uri.parse(baseUrl + endpoint).toString();
      var response = await Requests.put(url,
          body: requestData,
          headers: _headers(),
          timeoutSeconds: 10,
          bodyEncoding: RequestBodyEncoding.JSON);

      response.raiseForStatus();

      //var response = await Requests.put(url.toString(),headers:  _headers(),body: bodyData,timeoutSeconds: 10);
      //final response = await http.put(Uri.parse(baseUrl + endpoint),headers: _headers(), body: bodyData);

      return _response(response);
    } catch (e) {
      debugPrint(e.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    if (authToken.isEmpty) {
      authToken = await getAuthToken();
    }

    var url = Uri.parse(baseUrl + endpoint);
    var response = await Requests.delete(url.toString(),
        headers: _headers(), timeoutSeconds: 10);
    //final response =await http.delete(Uri.parse(baseUrl + endpoint), headers: _headers());

    return _response(response);
  }

  Map<String, dynamic> _response(http.Response response) {
    debugPrint(response.body.toString());

    var dataX = response.body;

    Map<String, dynamic> responseData = {};

    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body != null && response.body != '') {
        responseData = json.decode(response.body);
        return responseData;
      } else {
        return responseData;
      }
    } else {
      throw Exception(AppLocalization.instance.translate(
          'lib.utils.service.webApi.apiBearerAuthorization',
          '_response',
          'ExceptionMessage'));
    }
  }

  Map<String, String> _headers() {
    return {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials":
          "true", // Required for cookies, authorization headers with HTTPS
      "Access-Control-Allow-Methods": "*",
      "Access-Control-Allow-Headers": "*",
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Authorization': 'Bearer ' + authToken
    };
  }
}

/*
    // API'ye erişmek için yardımcı sınıfı oluşturun ve JWT yetkilendirme belirtecinizi ilettiğinizden emin olun
      ApiBearerAuthorizationHelper api = ApiBearerAuthorizationHelper(authToken: "your_jwt_token_here");

      // API'den veri almak için GET yöntemini kullanın
      Map<String, dynamic> response = await api.get("your_endpoint_here");

      // API'ye veri göndermek için POST yöntemini kullanın
      Map<String, dynamic> data = {"key": "value"};
      Map<String, dynamic> response = await api.post("your_endpoint_here", data);

      // API'deki verileri güncellemek için PUT yöntemini kullanın
      Map<String, dynamic> data = {"key": "updated_value"};
      Map<String, dynamic> response = await api.put("your_endpoint_here", data);

      // API'den veri silmek için DELETE yöntemini kullanın
      Map<String, dynamic> response = await api.delete("your_endpoint_here");
 */

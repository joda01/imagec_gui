import 'package:http/http.dart' as http;
import 'dart:convert';

const String BASE_URL = "http://127.0.0.1:7367";

///
/// \brief Start analyze
///
Future<void> startAnalyze(String analyzeSettings) async {
  final url = Uri.parse('$BASE_URL/api/v1/start');

  final headers = {'Content-Type': 'application/json'};

  final response =
      await http.post(url, headers: headers, body: analyzeSettings);

  if (response.statusCode == 200) {
    // Request successful, parse the response
    final responseData = jsonDecode(response.body);
    print(responseData);
  } else {
    // Request failed, handle the error
    print('Request failed with status: ${response.statusCode}');
  }
}

///
/// \brief Stop analyze
///
Future<void> stopAnalyze() async {
  final url = Uri.parse('$BASE_URL/api/v1/stop');

  final headers = {'Content-Type': 'application/json'};

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    // Request successful, parse the response
    final responseData = jsonDecode(response.body);
    print(responseData);
  } else {
    // Request failed, handle the error
    print('Request failed with status: ${response.statusCode}');
  }
}

///
/// \brief Start analyze
///
Future<Map<String, dynamic>> getAnalyzeStatus() async {
  final url = Uri.parse('$BASE_URL/api/v1/getstate');

  final headers = {'Content-Type': 'application/json'};

  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    // Request successful, parse the response
    final responseData = jsonDecode(response.body);
    return responseData;
  }
  throw Exception(response.statusCode);
  // Request failed, handle the error
  //print('Request failed with status: ${response.statusCode}');
}

///
/// \brief Start analyze
///
Future<(List<dynamic>,String)> listFolders(String startFolder) async {
  final url = Uri.parse('$BASE_URL/api/v1/listfolders');

  final headers = {'Content-Type': 'application/json'};

  final folderRequest = {"path": startFolder};
  final response =
      await http.post(url, headers: headers, body: jsonEncode(folderRequest));

  if (response.statusCode == 200) {
    // Request successful, parse the response
    final decoded = jsonDecode(response.body);
    final responseData =
        decoded["directories"] as List<dynamic>;
        final homePath = decoded["home"] as String;
    return (responseData,homePath);
  }
  throw Exception(response.statusCode);
  // Request failed, handle the error
  //print('Request failed with status: ${response.statusCode}');
}

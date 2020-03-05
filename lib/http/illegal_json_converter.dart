import 'dart:convert';
import 'package:dio/dio.dart';

class IllegalJsonConverter extends Interceptor {
  static final _interceptorAutoJson = "_interceptor_auto_json";

  @override
  onRequest(RequestOptions options) {
    if (options.responseType == ResponseType.json) {
      options.responseType = ResponseType.plain;
      options.extra[_interceptorAutoJson] = true;
    }
    return options;
  }

  @override
  onResponse(Response response) {
    // print('response:' + response.data.toString());
    bool autoToJson = response.request.extra[_interceptorAutoJson];
    if (response.data != null && autoToJson) {
      String respStr = response.data;
      if (respStr.length > 2) {
        if (respStr.startsWith("\"")) {
          respStr =
              respStr.substring(1, respStr.length - 1).replaceAll("\\", "");
          response.data = json.decode(respStr);
        }
      }
    }
    return response;
  }
}

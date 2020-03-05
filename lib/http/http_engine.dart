import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'log_interceptor.dart' as DebugLogger;

import 'package:finance/http/request_entity.dart';

class HttpEngine {
  static const DEBUG = true;
  static final HttpEngine _instance = HttpEngine._internal();

  static int defaultConnectionTimeout = 30 * 1000;
  static const _logPrefix = 'jnapi : ';
  factory HttpEngine() {
    return _instance;
  }

  Dio _dioInstance;

  HttpEngine._internal() {
    _dioInstance = Dio(
      BaseOptions(
        connectTimeout: defaultConnectionTimeout,
      ),
    );
    if (DEBUG) {
      _dioInstance.interceptors
        ..add(
          DebugLogger.LogInterceptor(
            prefix: _logPrefix,
            requestBody: true,
            responseBody: true,
          ),
        ); //开启请求日志
    }
    //..add(IllegalJsonConverter());
  }

  static HttpEngine get instance => _instance;

  static Dio getDioInstance() => HttpEngine()._dioInstance;

  static Future<Response> httpDownload(String url, String downloadPath,
      {ProgressCallback callback}) {
    return HttpEngine()
        ._dioInstance
        .download(url, downloadPath, onReceiveProgress: callback);
  }

  Future<Response<T>> request<T>(RequestEntity entity) async {
    // print(entity.address + entity.path);
    dynamic data;
    Options options = Options(responseType: ResponseType.json);
    if (entity.querys['token'] != null)
      options.headers['Authorization'] = entity.querys['token'];

    Map<String, dynamic> querys;
    switch (entity.type) {
      case RequestType.Get:
        querys = entity.querys;
        options.method = "GET";
        break;
      case RequestType.Post:
        data = entity.querys;
        options.contentType =
            ContentType.parse("application/x-www-form-urlencoded");
        options.method = "POST";
        break;
      case RequestType.PostJson:
        data = jsonEncode(entity.querys);
        if (DEBUG) {
          // print("$_logPrefix post json data : $data");
        }
        options.contentType = ContentType.json;
        options.method = "POST";
        break;
      case RequestType.PostFile:
        data = FormData.from(entity.querys);
        options.method = "POST";
        options.contentType = ContentType.binary;
        break;
    }
    String url = entity.address + entity.path;
    if (data is FormData) {
    } else if (data is String) {
      Map mapData = json.decode(data);
      if (mapData != null) {
        mapData.removeWhere((key, value) => value == null);
        data = mapData;
      }
    }

    if (querys != null) {
      querys.removeWhere((key, value) => value == null);
    }

    return _dioInstance.request<T>(
      url,
      data: data,
      queryParameters: querys,
      options: options.merge(
        responseType: ResponseType.json,
        headers: entity.headers,
      ),
    );
  }
}

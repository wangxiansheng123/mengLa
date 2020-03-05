import 'dart:async';
import 'http_engine.dart';
import 'package:dio/dio.dart';

enum RequestType { Get, Post, PostJson, PostFile }

typedef DataResultCallback<T> = void Function(T resp, dynamic error);

class RequestEntity {
  String address;
  String path;
  Map<String, dynamic> querys;
  RequestType type;
  Map<String, dynamic> headers;

  RequestEntity.create(this.address,
      {Map<String, dynamic> args, Map<String, dynamic> headers}) {
    this.querys = args;
    this.headers = headers;
  }

  RequestEntity.createWithPath(this.address, this.path,
      {Map<String, dynamic> args, Map<String, dynamic> headers}) {
    this.querys = args;
    this.headers = headers;
  }

  RequestEntity asGet() {
    this.type = RequestType.Get;
    return this;
  }

  RequestEntity asPost() {
    this.type = RequestType.Post;
    return this;
  }

  RequestEntity asPostFile() {
    this.type = RequestType.PostFile;
    return this;
  }

  RequestEntity asPostJson() {
    this.type = RequestType.PostJson;
    return this;
  }

  Future<Response<T>> request<T>() async {
    return HttpEngine.instance.request<T>(this);
  }

  void callSimple<T>(DataResultCallback<T> resultCallback) {
    call(_RequestCallbackImpl<T>(resultCallback));
  }

  void call<T>(RequestCallback<T> resultCallback) {
    HttpEngine.instance
        .request<T>(this)
        .then(resultCallback.onResponse)
        .catchError(resultCallback.onError)
        .whenComplete(resultCallback._onComplete);
  }
}

abstract class RequestCallback<T> {
  bool ignoreError = false;

  void onResponse(Response<T> resp) {
    //走到这里说明异步任务自身没有问题
    //接下来处理result callback
    //开始之前先标记或略由于onResult导致的错误
    ignoreError = true;
    onResult(resp, null);
  }

  void onError(dynamic error) {
    if (ignoreError) {
      ignoreError = false;
      //这种情况是由于onResult的callback自身除了问题
      //该情况不需要再次传递告知onResult,直接throw
      throw error;
    }
    //以下的情况是异步任务自身除了问题,所以需要通过onResult执行回调
    onResult(null, error);
  }

  _onComplete() {}

  void onResult(Response<T> resp, dynamic error);
}

class _RequestCallbackImpl<T> extends RequestCallback<T> {
  final DataResultCallback<T> resultCallback;

  _RequestCallbackImpl(this.resultCallback);

  @override
  void onResult(Response<T> resp, error) {
    if (resultCallback != null) {
      resultCallback(resp == null ? null : resp.data, error);
    }
  }
}

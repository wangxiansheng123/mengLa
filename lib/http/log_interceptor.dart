import 'package:dio/dio.dart';

class LogInterceptor extends Interceptor {
  final String prefix;

  LogInterceptor({
    this.prefix = '',
    this.request = true,
    this.requestHeader = true,
    this.requestBody = false,
    this.responseHeader = true,
    this.responseBody = false,
    this.error = true,
    this.logSize = 700,
  });

  /// Print request [Options]
  bool request;

  /// Print request header [Options.headers]
  bool requestHeader;

  /// Print request data [Options.data]
  bool requestBody;

  /// Print [Response.data]
  bool responseBody;

  /// Print [Response.headers]
  bool responseHeader;

  /// Print error message
  bool error;

  /// Log size per print
  final logSize;

  @override
  onRequest(RequestOptions options) async {
    // print('$prefix *** Request ***');
    printKV('$prefix uri', options.uri);

    if (request) {
      printKV('$prefix method', options.method);
      printKV('$prefix contentType', options.contentType?.toString());
      printKV('$prefix responseType', options.responseType?.toString());
      printKV('$prefix followRedirects', options.followRedirects);
      printKV('$prefix connectTimeout', options.connectTimeout);
      printKV('$prefix receiveTimeout', options.receiveTimeout);
      printKV('$prefix extra', options.extra);
    }
    if (requestHeader) {
      StringBuffer stringBuffer = new StringBuffer();
      options.headers.forEach((key, v) => stringBuffer.write('\n  $key:$v'));
      printKV('$prefix header', stringBuffer.toString());
      stringBuffer.clear();
    }
    if (requestBody) {
      // print("$prefix data:");
      printAll(options.data);
    }
    // print("$prefix ");
  }

  @override
  onError(DioError err) {
    if (error) {
      // print('$prefix *** DioError ***:');
      // print('$prefix $err');
      if (err.response != null) {
        _printResponse(err.response);
      }
    }
  }

  @override
  onResponse(Response response) {
    // print("$prefix *** Response ***");
    _printResponse(response);
  }

  void _printResponse(Response response) {
    printKV('$prefix uri', response?.request?.uri);
    if (responseHeader) {
      printKV('$prefix statusCode', response.statusCode);
      if (response.isRedirect) printKV('$prefix redirect', response.realUri);
      // print("$prefix headers:");
      // print(
      //     "$prefix  " + response?.headers?.toString()?.replaceAll("\n", "\n "));
    }
    if (responseBody) {
      // print("$prefix Response Text:");
      printAll("${response.toString()}");
    }
    // print("$prefix ");
  }

  printKV(String key, Object v) {
    // print('$key: $v');
  }

  printAll(msg) {
    msg.toString().split("\n").forEach(_printAll);
  }

  _printAll(String msg) {
    if (msg.length < logSize) {
      // print('$prefix $msg');
      return;
    }
    int groups = (msg.length / logSize).ceil();
    // print('$prefix >>>>>>>>>Log lines: ');
    for (int i = 0; i < groups; ++i) {
      var startIndex = i * logSize;
      var endIndex = i == groups - 1 ? msg.length : startIndex + logSize;
      // print('$prefix --------${i + 1}/$groups-> ' +
      //     msg.substring(startIndex, endIndex));
    }
    // print('$prefix >>>>>>>>>Log lines end');
  }
}

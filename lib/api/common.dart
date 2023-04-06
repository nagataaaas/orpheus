import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:orpheus_client/storage/credentials.dart' as credentials;
import 'package:orpheus_client/api/auth.dart' as auth;
import 'package:orpheus_client/exeptions.dart';

const apiDomain = 'api2.naxos.jp';
const apiPrefix = 'http://$apiDomain'; // sadly, no https
const maxAuthRetryCount = 3;

const defaultHeaders = {
  'Accept': 'application/json',
  'Accept-Encoding': 'gzip, deflate',
  'User-Agent': 'RestSharp/104.4.0.0',
  'Content-Type': 'application/json',
};

Map<String, String> generateAuthHeader(
    String accessKey, String secretKey, String method, String url) {
  var now = DateTime.now().toUtc();
  String signature =
      generateSignature(secretKey, method, now, Uri.parse(url).path);
  return {
    'X-NXS-Date': now.toIso8601String(),
    'Authorization': 'NXS $accessKey:$signature',
  };
}

String generateSignature(
    String secretKey, String method, DateTime dt, String resource) {
  String expiresAt = '${dt.toIso8601String().substring(0, 19)}Z';
  var bytes = utf8.encode('$method\n\n\n$expiresAt\n$resource');
  var hmacSha1 = Hmac(sha1, utf8.encode(secretKey));
  var digest = hmacSha1.convert(bytes);
  return base64.encode(digest.bytes);
}

Future<http.Response> post(
    String path, Map<String, dynamic> body, bool needAuth,
    {Map<String, String> headers = const {}, int retryCount = 0}) async {
  headers = await createHeader(needAuth, headers, path, 'POST');

  var response = await http.post(
    Uri.parse(path),
    headers: headers,
    body: jsonEncode(body),
  );

  if (needAuth &&
      (response.statusCode == HttpStatus.unauthorized ||
          (path.endsWith("/Auth/Login") &&
              response.statusCode == HttpStatus.badRequest))) {
    // we know that "the token is expired" and "accesskey is given".
    // so try extend, and if it fails, login again.
    if (retryCount > maxAuthRetryCount) {
      throw NeedLoginException;
    }
    bool success = await auth.Auth.extend();
    if (!success) {
      // extend failed
      credentials.AccessKey.set(null);
      credentials.SecretKey.set(null);
    }
    return post(path, body, needAuth,
        headers: headers, retryCount: retryCount + 1);
  }
  return response;
}

Future<http.Response> get(
    String path, Map<String, dynamic> query, bool needAuth,
    {Map<String, String> headers = const {}, int retryCount = 0}) async {
  headers = await createHeader(needAuth, headers, path, 'GET');
  Uri url = Uri.parse(path);
  url = url.replace(queryParameters: query);
  var response = await http.get(
    url,
    headers: headers,
  );
  if (needAuth && response.statusCode == HttpStatus.unauthorized) {
    // we know that "the token is expired" and "accesskey is given".
    // so try extend, and if it fails, login again.
    if (retryCount > maxAuthRetryCount) {
      throw NeedLoginException;
    }
    bool success = await auth.Auth.extend();
    if (!success) {
      // extend failed
      credentials.AccessKey.set(null);
      credentials.SecretKey.set(null);
    }
    return get(path, query, needAuth,
        headers: headers, retryCount: retryCount + 1);
  }
  return response;
}

Future<Map<String, String>> createHeader(
    bool needAuth, Map<String, String> headers, String path, method) async {
  headers = {...headers, ...defaultHeaders};
  if (needAuth) {
    if (!await credentials.isLoggedIn()) {
      if (!await credentials.RememberMe.get()) {
        // client must not call needAuth API without login
        throw NeedLoginException;
      }
      // not logged in but saves credentials
      String username = (await credentials.UserName.get())!;
      String password = (await credentials.Password.get())!;
      bool success = await auth.Auth.login(username, password);
      if (!success) {
        // login failed
        throw NeedLoginException;
      }
    }
    headers = {
      ...headers,
      ...generateAuthHeader(await credentials.AccessKey.get(),
          await credentials.SecretKey.get(), method, path)
    };
  }
  return headers;
}

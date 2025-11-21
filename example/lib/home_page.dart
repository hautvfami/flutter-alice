import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_alice/core/alice_http_client_extensions.dart';
import 'package:flutter_alice/core/alice_http_extensions.dart';
// import 'package:overlay_support/overlay_support.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Alice Inspector'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Image.asset('assets/green.png', height: 200),
            const SizedBox(height: 24),
            _textWidget(
              "Click \"TEST\" button to attach Alice interceptor to Dio\n"
              " Click \"Open Alice Inspector\" or green bubble to show inspector.",
            ),
            ElevatedButton(
              child: Text("TEST", style: TextStyle(color: Colors.white)),
              style: _primaryButtonStyle,
              onPressed: _runDioRequests,
            ),
            ElevatedButton(
              style: _secondaryButtonStyle,
              child: Text("Open Alice Inspector"),
              onPressed: alice.showInspector,
            ),

            /// Generate sample request
            const SizedBox(height: 64),
            _textWidget("Click buttons below to generate sample data."),
            ElevatedButton(
              child: Text("Run Dio HTTP Requests"),
              style: _secondaryButtonStyle,
              onPressed: _runDioRequests,
            ),
            ElevatedButton(
              child: Text("Run http/http HTTP Requests"),
              style: _secondaryButtonStyle,
              onPressed: _runHttpHttpRequests,
            ),
            ElevatedButton(
              child: Text("Run HttpClient Requests"),
              style: _secondaryButtonStyle,
              onPressed: _runHttpHttpClientRequests,
            ),
            // ElevatedButton(
            //   child: Text("Run Chopper HTTP Requests"),
            //   onPressed: _runChopperHttpRequests,
            // ),
          ].separatedBy(const SizedBox(height: 8)),
        ),
      ),
    );
  }

  Widget _textWidget(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
    );
  }

  ButtonStyle get _primaryButtonStyle {
    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size(double.infinity, 48)),
      backgroundColor: WidgetStateProperty.all(Colors.green),
      shape: WidgetStateProperty.all(_shape),
      textStyle: WidgetStateProperty.all(
        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  ButtonStyle get _secondaryButtonStyle {
    return _primaryButtonStyle.copyWith(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      foregroundColor: WidgetStateProperty.all(Colors.green),
    );
  }

  RoundedRectangleBorder get _shape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      );

  // void _runChopperHttpRequests() async {
  //   Map<String, dynamic> body = {"title": "foo", "body": "bar", "userId": "1"};
  //   _postsService.getPost("1");
  //   _postsService.postPost(body);
  //   _postsService.putPost("1", body);
  //   _postsService.putPost("1231923", body);
  //   _postsService.putPost("1", null);
  //   _postsService.postPost(null);
  //   _postsService.getPost("123456");
  // }

  void _runDioRequests() async {
    Map<String, dynamic> body = {"title": "foo", "body": "bar", "userId": "1"};
    dio.get(
      "https://api.themoviedb.org/3/search/movie?query=Jack+Reacher",
      queryParameters: {"abc": 123},
      data: {"data": "data"},
      options: Options(headers: {"app-id": 1}),
    );
    dio.get("https://httpbin.org/redirect-to?url=https%3A%2F%2Fhttpbin.org");
    dio.delete("https://httpbin.org/status/500");
    dio.delete("https://httpbin.org/status/400");
    dio.delete("https://httpbin.org/status/300");
    dio.delete("https://httpbin.org/status/200");
    dio.delete("https://httpbin.org/status/100");
    dio.post("https://jsonplaceholder.typicode.com/posts", data: body);
    dio.get("https://jsonplaceholder.typicode.com/posts",
        queryParameters: {"test": 1});
    dio.put("https://jsonplaceholder.typicode.com/posts/1", data: body);
    dio.put("https://jsonplaceholder.typicode.com/posts/1", data: body);
    dio.delete("https://jsonplaceholder.typicode.com/posts/1");
    dio.get("http://jsonplaceholder.typicode.com/test/test");

    dio.get("https://jsonplaceholder.typicode.com/photos");
    dio.get(
        "https://icons.iconarchive.com/icons/paomedia/small-n-flat/256/sign-info-icon.png");
    dio.get(
        "https://images.unsplash.com/photo-1542736705-53f0131d1e98?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80");
    dio.get(
        "https://findicons.com/files/icons/1322/world_of_aqua_5/128/bluetooth.png");
    dio.get(
        "https://upload.wikimedia.org/wikipedia/commons/4/4e/Pleiades_large.jpg");
    dio.get("http://techslides.com/demos/sample-videos/small.mp4");

    dio.get("https://www.cse.wustl.edu/~jain/cis677-97/ftp/e_3dlc2.pdf");

    dio.get("http://dummy.restapiexample.com/api/v1/employees");
    dio.get(
        "https://api.lyrics.ovh/v1/Coldplay/Adventure of a Lifetime?artist=Coldplay&title=Adventure of a Lifetime");
  }

  void _runHttpHttpRequests() async {
    Map<String, dynamic> body = {"title": "foo", "body": "bar", "userId": "1"};
    http
        .post(Uri.parse('https://jsonplaceholder.typicode.com/posts'),
            body: body)
        .interceptWithAlice(alice, body: body);

    http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
        .interceptWithAlice(alice);

    http
        .put(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
            body: body)
        .interceptWithAlice(alice, body: body);

    http
        .patch(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
            body: body)
        .interceptWithAlice(alice, body: body);

    http
        .delete(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
        .interceptWithAlice(alice, body: body);

    http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/test/test'))
        .interceptWithAlice(alice);

    http
        .post(Uri.parse('https://jsonplaceholder.typicode.com/posts'),
            body: body)
        .then((response) {
      alice.onHttpResponse(response, body: body);
    });

    http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
        .then((response) {
      alice.onHttpResponse(response);
    });

    http
        .put(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
            body: body)
        .then((response) {
      alice.onHttpResponse(response, body: body);
    });

    http
        .patch(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
            body: body)
        .then((response) {
      alice.onHttpResponse(response, body: body);
    });

    http
        .delete(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
        .then((response) {
      alice.onHttpResponse(response);
    });

    http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/test/test'))
        .then((response) {
      alice.onHttpResponse(response);
    });
  }

  void _runHttpHttpClientRequests() {
    Map<String, dynamic> body = {"title": "foo", "body": "bar", "userId": "1"};
    httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .interceptWithAlice(alice);

    httpClient
        .postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .interceptWithAlice(alice, body: body, headers: Map());

    httpClient
        .putUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .interceptWithAlice(alice, body: body);

    httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/test/test/"))
        .interceptWithAlice(alice);

    httpClient
        .postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
        .then((request) async {
      alice.onHttpClientRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    httpClient
        .putUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .then((request) async {
      alice.onHttpClientRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    httpClient
        .patchUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .then((request) async {
      alice.onHttpClientRequest(request, body: body);
      request.write(body);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    httpClient
        .deleteUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts/1"))
        .then((request) async {
      alice.onHttpClientRequest(request);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });

    httpClient
        .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/test/test/"))
        .then((request) async {
      alice.onHttpClientRequest(request);
      var httpResponse = await request.close();
      var responseBody = await utf8.decoder.bind(httpResponse).join();
      alice.onHttpClientResponse(httpResponse, request, body: responseBody);
    });
  }
}

extension WidgetListExtension on List<Widget> {
  List<Widget> separatedBy(Widget separator) {
    if (length < 2) return this;
    List<Widget> separatedList = [];
    for (int i = 0; i < length; i++) {
      separatedList.add(this[i]);
      if (i < length - 1) {
        separatedList.add(separator);
      }
    }
    return separatedList;
  }
}

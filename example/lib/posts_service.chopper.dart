// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'posts_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations
class _$PostsService extends PostsService {
  _$PostsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = PostsService;

  @override
  Future<Response<dynamic>> getPost(String id) {
    final $url = 'https://jsonplaceholder.typicode.com/posts/$id';
    final $request = Request('GET', Uri.parse($url), client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postPost(Map<String, dynamic>? body) {
    final $url = 'https://jsonplaceholder.typicode.com/posts/';
    final $body = body;
    final $request =
        Request('POST', Uri.parse($url), client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> putPost(String id, Map<String, dynamic>? body) {
    final $url = 'https://jsonplaceholder.typicode.com/posts/$id';
    final $body = body;
    final $request =
        Request('PUT', Uri.parse($url), client.baseUrl, body: $body);
    return client.send<dynamic, dynamic>($request);
  }
}

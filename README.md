# A ⭐ star on [GitHub repo](https://github.com/hautvfami/flutter-alice) is the greatest motivation for me
# to keep improving this project! 💖
# Alice <img src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/logo.png" width="25px">

[![pub package](https://img.shields.io/pub/v/flutter_alice.svg)](https://pub.dev/packages/flutter_alice)
[![pub package](https://img.shields.io/github/license/hautvfami/flutter-alice.svg?style=flat)](https://github.com/hautvfami/flutter-alice)
[![pub package](https://img.shields.io/badge/platform-flutter-blue.svg)](https://github.com/hautvfami/flutter-alice)

Alice is an HTTP Inspector tool for Flutter which helps debugging http requests. 
It catches and stores http requests and responses, which can be viewed via simple UI. 
It is inspired from Chuck (https://github.com/jgilfelt/chuck) and Chucker (https://github.com/ChuckerTeam/chucker).


Overlay bubble version of Alice: https://github.com/jhomlala/alice

<table>
  <tr>
    <td>
		<img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/1.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/2.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/3.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/4.png">
    </td>
     <td>
       <img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/5.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/6.png">
    </td>
  </tr>
  <tr>
    <td>
	<img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/7.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/8.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/9.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/10.png">
    </td>
    <td>
       <img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/11.png">
    </td>
     <td>
       <img width="250px" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/main/media/12.png">
    </td>
  </tr>

</table>

**Supported Dart http client plugins:**

- Dio
- HttpClient from dart:io package
- Http from http/http package
- Chopper
- Generic HTTP client

**Features:**  
✔️ Detailed logs for each HTTP calls (HTTP Request, HTTP Response)  
✔️ Inspector UI for viewing HTTP calls  
✔️ Statistics  
✔️ Support for top used HTTP clients in Dart  
✔️ Error handling  
✔️ HTTP calls search
✔️ Bubble overlay entry

## Install

1. Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  flutter_alice: ^1.0.1
```

2. Install it

```bash
$ flutter pub get
```

3. Import it

```dart
import 'package:flutter_alice/alice.dart';
```

## Usage
### Alice configuration
1. Create Alice instance:

```dart
// Define a navigator key
final navigatorKey = GlobalKey<NavigatorState>();

// Create Alice with the navigator key
final alice = Alice(navigatorKey: navigatorKey);
```

2. Add navigator key to your application:

```dart
MaterialApp(
  navigatorKey: navigatorKey,
  home: YourHomeWidget(),
)
```

You need to add this navigator key in order to show inspector UI.

3. Optional: To use bubble overlay, wrap your app with OverlaySupport:

```dart
// Don't forget to import overlay_support package
import 'package:overlay_support/overlay_support.dart';

OverlaySupport(
  child: MaterialApp(
    navigatorKey: navigatorKey,
    home: YourHomeWidget(),
  ),
)
```

### HTTP Client configuration
#### For Dio
Add interceptor to your Dio instance:

```dart
final dio = Dio();
dio.interceptors.add(alice.getDioInterceptor());
```

#### For HTTP package
You can use extension methods for cleaner code:

```dart
// Import extensions
import 'package:flutter_alice/core/alice_http_extensions.dart';

// Use extension methods
http
  .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
  .interceptWithAlice(alice);

// For POST requests with body
http
  .post(Uri.parse('https://jsonplaceholder.typicode.com/posts'), body: body)
  .interceptWithAlice(alice, body: body);
```

Or use the standard approach:

```dart
http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts')).then((response) {
  alice.onHttpResponse(response);
});

// For POST requests with body
http.post(Uri.parse('https://jsonplaceholder.typicode.com/posts'), body: body).then((response) {
  alice.onHttpResponse(response, body: body);
});
```

#### For HttpClient from dart:io
You can use extension methods:

```dart
// Import extensions
import 'package:flutter_alice/core/alice_http_client_extensions.dart';

// Use extension methods
httpClient
  .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
  .interceptWithAlice(alice);

// For POST requests with body
httpClient
  .postUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
  .interceptWithAlice(alice, body: body, headers: Map());
```

Or use the standard approach:

```dart
httpClient
  .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
  .then((request) async {
    alice.onHttpClientRequest(request);
    var httpResponse = await request.close();
    var responseBody = await utf8.decoder.bind(httpResponse).join();
    alice.onHttpClientResponse(httpResponse, request, body: responseBody);
  });
```

#### For Chopper
Add interceptor to your ChopperClient:

```dart
final chopper = ChopperClient(
  interceptors: alice.getChopperInterceptor(),
);
```

### Opening the Inspector
You can open the inspector UI in different ways:

```dart
// Open directly
ElevatedButton(
  child: Text("Open Inspector"),
  onPressed: alice.showInspector,
)

// Or call from anywhere in your code
alice.showInspector();
```

# Alice - HTTP Inspector for Flutter 🎁

[![pub package](https://img.shields.io/pub/v/flutter_alice.svg)](https://pub.dev/packages/flutter_alice)
[![pub package](https://img.shields.io/github/license/hautvfami/flutter-alice.svg?style=flat)](https://github.com/hautvfami/flutter-alice)
[![pub package](https://img.shields.io/badge/platform-flutter-blue.svg)](https://github.com/hautvfami/flutter-alice)

**Alice** is a powerful HTTP Inspector tool for Flutter developers. It captures, stores, and displays HTTP requests and responses in a user-friendly interface, making debugging network calls effortless. Alice supports popular Dart HTTP clients like Dio, HttpClient, and the http package.

Perfect for Flutter app development, API debugging, network monitoring, and troubleshooting HTTP issues.

Friendly version of [Alice](https://github.com/jhomlala/alice) by [Jakub](https://github.com/jhomlala).
Inspired from [Chuck](https://github.com/jgilfelt/chuck) and [Chucker](https://github.com/ChuckerTeam/chucker).

## 🚀 Key Features

- **Detailed HTTP Logs**: View complete request and response details
- **Intuitive Inspector UI**: Easy-to-navigate interface for HTTP calls
- **Statistics Dashboard**: Analyze network performance
- **Multi-Client Support**: Works with Dio, HttpClient, and http package
- **Error Handling**: Catch and inspect failed requests
- **Search Functionality**: Quickly find specific HTTP calls
- **Bubble Overlay**: Floating inspector access
- **JSON Viewer**: Built-in JSON response viewer for easy parsing
- **Alice Console**: Log messages for debugging in release environments where console access is limited

## 📸 Demo Video & Screenshots

<table>
  <tr>
    <td width="20%">
      <video width="100%" controls>
        <source src="https://raw.githubusercontent.com/hautvfami/flutter-alice/task/improve/media/ScreenRecording_11-22-2025%2015-55-39_1.webm" type="video/webm">
        Your browser does not support the video tag.
      </video>
    </td>
    <td width="20%"><img width="100%" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/task/improve/media/IMG_7290.PNG"></td>
    <td width="20%"><img width="100%" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/task/improve/media/IMG_7289.PNG"></td>
    <td width="20%"><img width="100%" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/task/improve/media/IMG_7291.PNG"></td>
    <td width="20%"><img width="100%" src="https://raw.githubusercontent.com/hautvfami/flutter-alice/task/improve/media/IMG_7292.PNG"></td>
  </tr>
</table>

[ >> VIDEO](https://raw.githubusercontent.com/hautvfami/flutter-alice/task/improve/media/ScreenRecording_11-22-2025%2015-55-39_1.webm)

## 🛠️ Supported HTTP Clients

- **Dio**: Popular HTTP client for Flutter
- **HttpClient** (dart:io): Built-in Dart HTTP client
- **Http Package**: Standard http/http library
- **Generic HTTP Client**: Flexible integration

## 📦 Installation

1. Add Alice to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_alice: ^2.1.0-beta.1
```

2. Run the following command:

```bash
flutter pub get
```

3. Import Alice in your Dart code:

```dart
import 'package:flutter_alice/alice.dart';
```

## 🚀 Quick Start

### Recommended: Using AliceInspector Widget

For the easiest setup, wrap your app with `AliceInspector`. This automatically configures Alice, adds Dio interceptors, and provides a floating inspector button.

```dart
import 'package:flutter_alice/alice.dart';

final alice = Alice();
final navigatorKey = GlobalKey<NavigatorState>();
final dio = Dio();

void main() {
  alice.log("Alice is running!", color: Colors.yellow);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AliceInspector(
      debug: true,  // Enable debug mode
      dios: [dio],  // List of Dio instances to intercept
      navigatorKey: navigatorKey,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
```

### Alternative: Manual Alice Setup

If you prefer manual control, create an Alice instance and configure it step-by-step.

#### 1. Configure Alice

```dart
// Define a navigator key
final navigatorKey = GlobalKey<NavigatorState>();

// Create Alice instance
final alice = Alice(navigatorKey: navigatorKey);
```

#### 2. Set Up Your App

```dart
MaterialApp(
  navigatorKey: navigatorKey,
  home: YourHomeWidget(),
)
```

#### 3. Integrate HTTP Clients

##### Dio Integration

```dart
final dio = Dio();
dio.interceptors.add(alice.getDioInterceptor());
```

##### Http Package Integration

Using extensions for cleaner code:

```dart
import 'package:flutter_alice/core/alice_http_extensions.dart';

http
  .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
  .interceptWithAlice(alice);

// For POST with body
http
  .post(Uri.parse('https://jsonplaceholder.typicode.com/posts'), body: body)
  .interceptWithAlice(alice, body: body);
```

Or standard approach:

```dart
http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts')).then((response) {
  alice.onHttpResponse(response);
});
```

##### HttpClient Integration

Using extensions:

```dart
import 'package:flutter_alice/core/alice_http_client_extensions.dart';

httpClient
  .getUrl(Uri.parse("https://jsonplaceholder.typicode.com/posts"))
  .interceptWithAlice(alice);
```

Or standard approach:

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

#### 4. Open Inspector

```dart
// Button to open inspector
ElevatedButton(
  child: Text("Open HTTP Inspector"),
  onPressed: alice.showInspector,
)

// Or call from anywhere
alice.showInspector();
```

## 📝 Alice Console

Alice provides a built-in console for logging messages, especially useful in release builds where console access is limited.

```dart
// Log a message with default color
alice.log("This is a log message");

// Log with custom color
alice.log("Error occurred", color: Colors.red);

// View logs in the inspector
alice.showInspector(); // Logs are displayed in the Alice UI
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⭐ Support

If you find Alice helpful, please give it a ⭐ on [GitHub](https://github.com/hautvfami/flutter-alice)! Your support motivates us to keep improving.

For issues or questions, open an issue on GitHub.

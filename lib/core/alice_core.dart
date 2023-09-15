import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_alice/core/debug_pop_up.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_http_error.dart';
import 'package:flutter_alice/model/alice_http_response.dart';
import 'package:flutter_alice/ui/page/alice_calls_list_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rxdart/rxdart.dart';

class AliceCore {
  /// Should user be notified with notification if there's new request catched
  /// by Alice
  final bool showNotification;

  /// Should inspector be opened on device shake (works only with physical
  /// with sensors)
  final bool showInspectorOnShake;

  /// Should inspector use dark theme
  final bool darkTheme;

  /// Rx subject which contains all intercepted http calls
  final BehaviorSubject<List<AliceHttpCall>> callsSubject =
      BehaviorSubject.seeded([]);

  /// Icon url for notification
  final String notificationIcon;

  GlobalKey<NavigatorState>? _navigatorKey;
  Brightness _brightness = Brightness.light;
  bool _isInspectorOpened = false;
  StreamSubscription? _callsSubscription;
  String? _notificationMessage;
  String? _notificationMessageShown;
  bool _notificationProcessing = false;

  static AliceCore? _singleton;

  factory AliceCore(
    _navigatorKey,
    showNotification,
    showInspectorOnShake,
    darkTheme,
    notificationIcon,
  ) {
    _singleton ??= AliceCore._(
      _navigatorKey,
      showNotification,
      showInspectorOnShake,
      darkTheme,
      notificationIcon,
    );
    return _singleton!;
  }

  /// Creates alice core instance
  AliceCore._(
    this._navigatorKey,
    this.showNotification,
    this.showInspectorOnShake,
    this.darkTheme,
    this.notificationIcon,
  ) {
    if (showNotification) {
      _callsSubscription = callsSubject.listen((_) => _onCallsChanged());
    }
    _brightness = darkTheme ? Brightness.dark : Brightness.light;
  }

  /// Dispose subjects and subscriptions
  void dispose() {
    callsSubject.close();
    //_shakeDetector?.stopListening();
    _callsSubscription?.cancel();
  }

  /// Get currently used brightness
  Brightness get brightness => _brightness;

  void _onCallsChanged() async {
    if (callsSubject.value.length > 0) {
      _notificationMessage = _getNotificationMessage();
      if (_notificationMessage != _notificationMessageShown &&
          !_notificationProcessing) {
        await _showLocalNotification();
        _onCallsChanged();
      }
    }
  }

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    this._navigatorKey = navigatorKey;
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void navigateToCallListScreen() {
    var context = getContext();
    if (context == null) {
      print(
          "Cant start Alice HTTP Inspector. Please add NavigatorKey to your application");
      return;
    }
    if (!_isInspectorOpened) {
      _isInspectorOpened = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AliceCallsListScreen(this),
        ),
      ).then((onValue) => _isInspectorOpened = false);
    }
  }

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? getContext() => _navigatorKey?.currentState?.overlay?.context;

  String _getNotificationMessage() {
    List<AliceHttpCall>? calls = callsSubject.value;
    int successCalls = calls
        .where((call) =>
            call.response != null &&
            (call.response?.status ?? 0) >= 200 &&
            (call.response?.status ?? 0) < 300)
        .toList()
        .length;

    int redirectCalls = calls
        .where((call) =>
            call.response != null &&
            (call.response?.status ?? 0) >= 300 &&
            (call.response?.status ?? 0) < 400)
        .toList()
        .length;

    int errorCalls = calls
        .where((call) =>
            call.response != null &&
            (call.response?.status ?? 0) >= 400 &&
            (call.response?.status ?? 0) < 600)
        .toList()
        .length;

    int loadingCalls = calls.where((call) => call.loading).toList().length;

    StringBuffer notificationsMessage = StringBuffer();
    if (loadingCalls > 0) {
      notificationsMessage.write("Loading: $loadingCalls");
      notificationsMessage.write(" | ");
    }
    if (successCalls > 0) {
      notificationsMessage.write("Success: $successCalls");
      notificationsMessage.write(" | ");
    }
    if (redirectCalls > 0) {
      notificationsMessage.write("Redirect: $redirectCalls");
      notificationsMessage.write(" | ");
    }
    if (errorCalls > 0) {
      notificationsMessage.write("Error: $errorCalls");
    }
    return notificationsMessage.toString();
  }

  Future _showLocalNotification() async {
    _notificationProcessing = true;
    String? message = _notificationMessage;
    showDebugAnimNotification();
    _notificationMessageShown = message;
    _notificationProcessing = false;
    return;
  }

  /// Add alice http call to calls subject
  void addCall(AliceHttpCall call) {
    callsSubject.add([call, ...callsSubject.value]);
  }

  /// Add error to exisng alice http call
  void addError(AliceHttpError error, int requestId) {
    AliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }

    selectedCall.error = error;
    callsSubject.add([...callsSubject.value]);
  }

  /// Add response to existing alice http call
  void addResponse(AliceHttpResponse response, int requestId) {
    AliceHttpCall? selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }
    selectedCall.loading = false;
    selectedCall.response = response;
    selectedCall.duration = response.time.millisecondsSinceEpoch -
        selectedCall.request!.time.millisecondsSinceEpoch;

    callsSubject.add([...callsSubject.value]);
  }

  /// Add alice http call to calls subject
  void addHttpCall(AliceHttpCall aliceHttpCall) {
    assert(aliceHttpCall.request != null, "Http call request can't be null");
    assert(aliceHttpCall.response != null, "Http call response can't be null");
    callsSubject.add([...callsSubject.value, aliceHttpCall]);
  }

  /// Remove all calls from calls subject
  void removeCalls() {
    callsSubject.add([]);
  }

  AliceHttpCall? _selectCall(int requestId) =>
      callsSubject.value.firstWhereOrNull((call) => call.id == requestId);

  bool isShowedBubble = false;

  void showDebugAnimNotification() {
    if (isShowedBubble) {
      return;
    }
    var context = getContext();
    if (context == null) {
      return;
    }
    isShowedBubble = true;
    showOverlay((context, t) {
      return Opacity(
        opacity: t,
        child: DebugPopUp(
          callsSubscription: callsSubject.stream,
          onClicked: () {
            navigateToCallListScreen();
          },
          aliceCore: this,
        ),
      );
    }, duration: Duration.zero);
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

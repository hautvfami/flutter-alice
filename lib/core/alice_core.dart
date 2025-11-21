import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_dio_interceptor.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/model/alice_http_error.dart';
import 'package:flutter_alice/model/alice_http_response.dart';
import 'package:flutter_alice/ui/page/alice_calls_list_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

/// This class not exported outside package. It contains core logic
/// for alice inspector.
class AliceCore {
  static AliceCore inst = AliceCore._();

  factory AliceCore({GlobalKey<NavigatorState>? navigatorKey}) {
    if (navigatorKey != null) inst.setNavigatorKey(navigatorKey);
    return inst;
  }

  /// Creates alice core instance
  AliceCore._() {
    _callsSubscription = callsSubject.listen(_onCallsChanged);
  }

  /// Rx subject which contains all intercepted http calls
  final callsSubject = BehaviorSubject.seeded(<AliceHttpCall>[]);

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _isInspectorOpened = false;
  StreamSubscription? _callsSubscription;
  bool isShowedBubble = false;

  final logsSubject = BehaviorSubject<List<String>>.seeded([]);
  List<String> _logs = ['hautv.fami@gmail.com'];
  List<String> get logs => _logs;
  int limitLogs = 1000;

  // Thêm getter cho stream:
  Stream<List<String>> get logsStream => logsSubject.stream;

  /// Get context from navigator key. Used to open inspector route.
  BuildContext? get context => _navigatorKey?.currentState?.overlay?.context;

  /// Get Dio interceptor which should be applied to Dio instance.
  AliceDioInterceptor getDioInterceptor() => AliceDioInterceptor(this);

  /// Set custom navigation key. This will help if there's route library.
  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    this._navigatorKey = navigatorKey;
  }

  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  /// Dispose subjects and subscriptions
  void dispose() {
    callsSubject.close();
    _callsSubscription?.cancel();
  }

  void _onCallsChanged(List<AliceHttpCall> _) {
    if (callsSubject.value.isNotEmpty && !isShowedBubble) {
      showDebugAnimNotification();
    }
  }

  /// Opens Http calls inspector. This will navigate user to the new fullscreen
  /// page where all listened http calls can be viewed.
  void navigateToCallListScreen() {
    if (context == null) {
      print("Cant start Alice HTTP Inspector. Please add NavigatorKey");
      return;
    }
    if (!_isInspectorOpened) {
      _isInspectorOpened = true;
      push(
        (context) => AliceCallsListScreen(this),
      ).then((onValue) => _isInspectorOpened = false);
    }
  }

  /// Add alice http call to calls subject
  void addCall(AliceHttpCall call) {
    callsSubject.add([call, ...callsSubject.value]);
  }

  /// Add error to exisng alice http call
  void addError(AliceHttpError error, int requestId) {
    final selectedCall = _selectCall(requestId);
    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }

    selectedCall.error = error;
    callsSubject.add([...callsSubject.value]);
  }

  /// Add response to existing alice http call
  void addResponse(AliceHttpResponse response, int requestId) {
    final selectedCall = _selectCall(requestId);
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
  void clears() => callsSubject.add([]);

  AliceHttpCall? _selectCall(int requestId) {
    return callsSubject.value.firstWhereOrNull(
      (call) => call.id == requestId,
    );
  }

  @optionalTypeArgs
  Future<T?> push<T extends Object?>(Widget Function(BuildContext) builder) {
    if (context == null) {
      print("Cant start Alice HTTP Inspector. Please add NavigatorKey");
      return Future.value(null);
    }
    return Navigator.push(context!, MaterialPageRoute(builder: builder));
  }

  void showDebugAnimNotification() {
    if (isShowedBubble) return;
    if (context == null) return;

    isShowedBubble = true;
    // showOverlay((context, t) {
    //   return Opacity(
    //     opacity: t,
    //     child: AliceInspector(
    //       // onClicked: navigateToCallListScreen,
    //       aliceCore: this,
    //       limitLogs: limitLogs,
    //     ),
    //   );
    // }, duration: Duration.zero);
  }

  void log(String message, {Color color = Colors.white}) {
    if (_logs.length > limitLogs) _logs.removeLast();
    final colorString = '0x${color.toARGB32().toRadixString(16)}'.toUpperCase();

    print("$message");

    _logs.insert(0, '$colorString$message');
    logsSubject.add(List.from(_logs));
  }

  void clearLogs() {
    _logs.clear();
    logsSubject.add([]);
  }
}

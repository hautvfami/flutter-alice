import 'dart:async';
import 'dart:math';

import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

enum MPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  middleLeft,
  middleRight
}

class DebugPopUp extends StatefulWidget {
  final VoidCallback onClicked;
  final Stream<List<AliceHttpCall>> callsSubscription;

  ///class widget to show overlay bubble describes the number request count and is a place to navigate to alice inspector.
  ///[onClicked] call back when user clicked in debug point
  ///[callsSubscription] the stream to listen how many request in app
  const DebugPopUp({
    Key key,
    @required this.onClicked,
    @required this.callsSubscription,
  }) : super(key: key);

  @override
  _DebugPopUpState createState() => _DebugPopUpState();
}

class _DebugPopUpState extends State<DebugPopUp> {
  ///current position bubble edit this field to change position at start up or after dragging
  MPosition currentPosition = MPosition.middleLeft;

  ///show hint box, if [isShowHint] = true all the hint box should be visible else  -> hide
  bool isShowHint = false;
  StreamController<bool> _hintTargetController = StreamController.broadcast();

  Stream<bool> get showHintTarget => _hintTargetController.stream;

  @override
  void dispose() {
    _hintTargetController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dragWidget =
        _buildDraggyWidget(widget.onClicked, widget.callsSubscription);
    //wrap with SafeArea to support edge screen
    return SafeArea(
      child: Stack(
        children: [
          _targetTopLeft(dragWidget),
          _targetTopRight(dragWidget),
          _targetMiddleRight(dragWidget),
          _targetMiddleLeft(dragWidget),
          _targetBottomLeft(dragWidget),
          _targetBottomRight(dragWidget),
        ],
      ),
    );
  }

  Widget _buildDraggyWidget(
    VoidCallback onClicked,
    Stream<List<AliceHttpCall>> stream,
  ) {
    var widget = Opacity(
      opacity: 0.2,
      child: FloatingActionButton(
        child: StreamBuilder<List<AliceHttpCall>>(
          initialData: [],
          stream: stream,
          builder: (context, snapshot) => Text(
            "${min(snapshot.data?.length ?? 0, 99)}",
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(color: Colors.white),
          ),
        ),
        onPressed: onClicked,
        mini: true,
      ),
    );
    return Draggable<int>(
      child: widget,
      feedback: widget,
      onDragCompleted: () => _hideHintBox(),
      onDragEnd: (d) => _hideHintBox(),
      onDragStarted: () => _showHintBox(),
      onDraggableCanceled: (_, __) => _hideHintBox(),
    );
  }

  /// should be call when user end or cancel dragging to hide all the hint box
  /// by check [isShowHint] = true and then mark [isShowHint] = false after hide
  void _hideHintBox() {
    if (isShowHint) {
      isShowHint = false;
      _hintTargetController.add(isShowHint);
    }
  }

  /// show hint box should be call when we start dragging an object to guide user where is the they should move
  /// only trigger if [isShowHint] = false and mark [isShowHint] = true after all the box is showing
  void _showHintBox() {
    if (!isShowHint) {
      isShowHint = true;
      _hintTargetController.add(isShowHint);
    }
  }

  Positioned _targetMiddleLeft(Widget widget) {
    return Positioned(
      child: Center(
        child: _buildTartGetBox(
          child: DragTarget<int>(
            onWillAccept: (_) => handleOnWillAccept(MPosition.middleLeft),
            builder: (context, List<int> candidateData, rejectedData) {
              if (currentPosition == MPosition.middleLeft) {
                return widget;
              }
              return Container();
            },
          ),
        ),
      ),
      top: 0,
      left: 0,
      bottom: 0,
    );
  }

  Positioned _targetMiddleRight(Widget widget) {
    return Positioned(
      child: Center(
        child: _buildTartGetBox(
          child: DragTarget<int>(
            onWillAccept: (_) => handleOnWillAccept(MPosition.middleRight),
            onAccept: (_) => handleOnAccept(MPosition.middleRight),
            builder: (context, List<int> candidateData, rejectedData) {
              if (currentPosition == MPosition.middleRight) {
                return widget;
              }
              return Container();
            },
          ),
        ),
      ),
      top: 0,
      bottom: 0,
      right: 0,
    );
  }

  Positioned _targetBottomRight(Widget widget) {
    return Positioned(
      child: _buildTartGetBox(
        child: DragTarget<int>(
          onWillAccept: (_) => handleOnWillAccept(MPosition.bottomRight),
          onAccept: (_) => handleOnAccept(MPosition.bottomRight),
          builder: (context, List<int> candidateData, rejectedData) {
            if (currentPosition == MPosition.bottomRight) {
              return widget;
            }
            return Container();
          },
        ),
      ),
      bottom: 0,
      right: 0,
    );
  }

  Positioned _targetBottomLeft(Widget widget) {
    return Positioned(
      child: _buildTartGetBox(
        child: DragTarget<int>(
          onWillAccept: (_) => handleOnWillAccept(MPosition.bottomLeft),
          onAccept: (_) => handleOnAccept(MPosition.bottomLeft),
          builder: (context, List<int> candidateData, rejectedData) {
            if (currentPosition == MPosition.bottomLeft) {
              return widget;
            }
            return Container();
          },
        ),
      ),
      bottom: 0,
      left: 0,
    );
  }

  Positioned _targetTopRight(Widget widget) {
    return Positioned(
      child: _buildTartGetBox(
        child: DragTarget<int>(
          onWillAccept: (_) => handleOnWillAccept(MPosition.topRight),
          onAccept: (_) => handleOnAccept(MPosition.topRight),
          builder: (context, List<int> candidateData, rejectedData) {
            if (currentPosition == MPosition.topRight) {
              return widget;
            }
            return Container();
          },
        ),
      ),
      top: 0,
      right: 0,
    );
  }

  Positioned _targetTopLeft(Widget widget) {
    return Positioned(
      child: _buildTartGetBox(
        child: DragTarget<int>(
          onWillAccept: (_) => handleOnWillAccept(MPosition.topLeft),
          onAccept: (_) => handleOnAccept(MPosition.topLeft),
          builder: (context, List<int> candidateData, rejectedData) {
            if (currentPosition == MPosition.topLeft) {
              return widget;
            }
            return Container();
          },
        ),
      ),
      top: 0,
      left: 0,
    );
  }

  ///create widget wrap drag target and it wil stream the state form [showHintTarget]
  Widget _buildTartGetBox({Widget child}) {
    return StreamBuilder<bool>(
      initialData: false,
      stream: showHintTarget,
      builder: (context, snapshot) {
        if (snapshot.data != null && snapshot.data) {
          return Container(
            width: 32,
            height: 32,
            color: Colors.black38,
            child: child,
          );
        }
        return child;
      },
    );
  }

  ///handle action when user drag object to the target we need accept and update the position
  ///the target will be redraw a new state if the current position is equal with the target position
  bool handleOnWillAccept(MPosition position) {
    currentPosition = position;
    return true;
  }

  ///handle action after [handleOnWillAccept] accept return true user drag object to the target we need accept and update
  ///the position
  ///the target will be redraw a new state if the current position is equal with the target position
  void handleOnAccept(MPosition position) {
    currentPosition = position;
  }
}

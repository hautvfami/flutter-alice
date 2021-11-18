import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

class DebugPopUp extends StatefulWidget {
  final VoidCallback onClicked;
  final Stream<List<AliceHttpCall>> callsSubscription;

  ///class widget to show overlay bubble describes the number request count and is a place to navigate to alice inspector.
  ///[onClicked] call back when user clicked in debug point
  ///[callsSubscription] the stream to listen how many request in app
  const DebugPopUp({
    Key? key,
    required this.onClicked,
    required this.callsSubscription,
  }) : super(key: key);

  @override
  _DebugPopUpState createState() => _DebugPopUpState();
}

class _DebugPopUpState extends State<DebugPopUp> {
  Offset _offset = Offset.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _size = MediaQuery.of(context).size;
    _offset = Offset(_size.width - 50, _size.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    //wrap with SafeArea to support edge screen
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: _offset.dx,
            top: _offset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                _offset += details.delta;
                setState(() {});
              },
              child: _buildDraggyWidget(
                widget.onClicked,
                widget.callsSubscription,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggyWidget(
    VoidCallback onClicked,
    Stream<List<AliceHttpCall>> stream,
  ) {
    return Opacity(
      opacity: 0.6,
      child: FloatingActionButton(
        child: StreamBuilder<List<AliceHttpCall>>(
          initialData: [],
          stream: stream,
          builder: (_, snapshot) {
            final counter = min(snapshot.data?.length ?? 0, 99);
            return Text("$counter");
          },
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: onClicked,
        mini: true,
        tooltip: 'I\'m Alice',
      ),
    );
  }
}

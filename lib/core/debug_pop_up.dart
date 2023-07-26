import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/ui/page/alice_stats_screen.dart';

import 'alice_core.dart';
import 'expandable_fab.dart';

class DebugPopUp extends StatefulWidget {
  final VoidCallback onClicked;
  final Stream<List<AliceHttpCall>> callsSubscription;
  final AliceCore aliceCore;

  ///class widget to show overlay bubble describes the number request count and is a place to navigate to alice inspector.
  ///[onClicked] call back when user clicked in debug point
  ///[callsSubscription] the stream to listen how many request in app
  const DebugPopUp({
    Key? key,
    required this.onClicked,
    required this.callsSubscription,
    required this.aliceCore,
  }) : super(key: key);

  @override
  _DebugPopUpState createState() => _DebugPopUpState();
}

class _DebugPopUpState extends State<DebugPopUp> {
  Offset _offset = Offset.zero;
  final _expandedDistance = 100.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _size = MediaQuery.of(context).size;
    final _rightSide = _expandedDistance + kToolbarHeight + 20;
    _offset = Offset(
      _size.width - _rightSide,
      _size.height / 2 - _expandedDistance,
    );
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
    return ExpandableFab(
      distance: _expandedDistance,
      bigButton: Opacity(
        opacity: 0.6,
        child: FloatingActionButton(
          child: StreamBuilder<List<AliceHttpCall>>(
            initialData: [],
            stream: stream,
            builder: (_, sns) {
              final counter = min(sns.data?.length ?? 0, 99);
              return Text("$counter");
            },
          ),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          onPressed: onClicked,
          mini: true,
          enableFeedback: true,
        ),
      ),
      children: [
        ActionButton(
          onPressed: () => widget.aliceCore.removeCalls(),
          icon: Icon(Icons.delete, color: Colors.white),
        ),
        ActionButton(
          onPressed: _showStatsScreen,
          icon: Icon(Icons.insert_chart, color: Colors.white),
        ),
      ],
    );
  }

  void _showStatsScreen() {
    Navigator.push(
      widget.aliceCore.getContext()!,
      MaterialPageRoute(
        builder: (_) => AliceStatsScreen(widget.aliceCore),
      ),
    );
  }
}

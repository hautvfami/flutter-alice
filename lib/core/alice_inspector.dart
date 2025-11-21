import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alice/core/alice_dio_interceptor.dart';
import 'package:flutter_alice/model/alice_http_call.dart';
import 'package:flutter_alice/ui/page/alice_stats_screen.dart';

import 'alice_core.dart';
import 'expandable_fab.dart';

class AliceInspector extends StatefulWidget {
  final Widget? child;
  final bool debug;
  final List<Dio>? dios;
  final int limitLogs;
  final GlobalKey<NavigatorState>? navigatorKey;

  const AliceInspector({
    Key? key,
    this.child,
    this.debug = true,
    this.dios,
    this.limitLogs = 1000,
    this.navigatorKey,
  }) : super(key: key);

  @override
  _AliceInspectorState createState() => _AliceInspectorState();
}

class _AliceInspectorState extends State<AliceInspector> {
  final aliceCore = AliceCore.inst;
  final _expandedDistance = 80.0;
  late double _rightSide = _expandedDistance + kToolbarHeight + 20;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    aliceCore.limitLogs = widget.limitLogs;
    if (widget.navigatorKey != null) {
      aliceCore.setNavigatorKey(widget.navigatorKey!);
    } else if (aliceCore.navigatorKey == null) {
      print("AliceInspector: NavigatorKey is not set. "
          "Please provide a navigatorKey to AliceInspector or AliceCore.");
      throw Exception(
        'AliceInspector: NavigatorKey is not set. 🤬\n'
        'Please provide a navigatorKey to AliceInspector or AliceCore.\n'
        'navigatorKey: navigatorKey, or alice.setNavigatorKey(navigatorKey)',
      );
    }

    if (widget.dios != null && widget.debug) {
      final interceptor = aliceCore.getDioInterceptor();
      for (final dio in widget.dios!) {
        dio.interceptors.removeWhere((e) => e is AliceDioInterceptor);
        dio.interceptors.add(interceptor);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final _size = MediaQuery.of(context).size;
      setState(() {
        _offset = Offset(
          _size.width - _rightSide,
          _size.height / 3 - _expandedDistance,
        );
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.debug) return widget.child ?? SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          if (widget.child != null) widget.child!,
          Positioned(
            left: _offset.dx,
            top: _offset.dy,
            child: SafeArea(
              child: GestureDetector(
                onPanUpdate: (del) => setState(() => _offset += del.delta),
                child: _buildDraggyWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggyWidget() {
    return ExpandableFab(
      distance: _expandedDistance,
      bigButton: Opacity(
        opacity: 0.6,
        child: FloatingActionButton(
          child: StreamBuilder<List<AliceHttpCall>>(
            initialData: [],
            stream: aliceCore.callsSubject.stream,
            builder: (_, sns) {
              final counter = min(sns.data?.length ?? 0, 99);
              return Text("$counter");
            },
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          onPressed: aliceCore.navigateToCallListScreen,
          mini: true,
          enableFeedback: true,
        ),
      ),
      children: [
        ActionButton(
          onPressed: aliceCore.clears,
          icon: Icon(Icons.delete, color: Colors.white),
        ),
        ActionButton(
          onPressed: () => aliceCore.push((_) => AliceStatsScreen(aliceCore)),
          icon: Icon(Icons.insert_chart, color: Colors.white),
        ),
      ],
    );
  }
}

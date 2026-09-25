import 'package:flutter/material.dart';
import 'package:flutter_alice/theme/theme.dart';
import 'package:flutter_alice/ui/utils/alice_parser.dart';

typedef IsAtBottomCallback = void Function(bool isAtBottom);

class AliceLogsWidget extends StatefulWidget {
  const AliceLogsWidget({
    super.key,
    required this.stream,
  });

  final Stream<List<String>> stream;

  @override
  State<AliceLogsWidget> createState() => _AliceLogsWidgetState();
}

class _AliceLogsWidgetState extends State<AliceLogsWidget> {
  final _controller = ScrollController();
  bool _isAtBottom = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), _scrollToBottomIfNeeded);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollToBottomIfNeeded() {
    if (!_isAtBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) return;
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: widget.stream,
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        _scrollToBottomIfNeeded();
        return NotificationListener<ScrollNotification>(
          onNotification: _onNotification,
          child: ListView.separated(
            controller: _controller,
            padding: const EdgeInsets.all(8),
            itemBuilder: (_, i) {
              final log = AliceParser.logParser(logs[i]);
              final color = Color(log.color);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  log.message,
                  style: AliceStyles.mono.s12.copyWith(color: color),
                ),
              );
            },
            separatorBuilder: (_, i) => const Divider(
              height: 1,
              color: Colors.white24,
            ),
            itemCount: logs.length,
          ),
        );
      },
    );
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification.metrics.maxScrollExtent > 0) {
      final offsetFromBottom =
          notification.metrics.maxScrollExtent - notification.metrics.pixels;
      _isAtBottom = offsetFromBottom <= 50;
    }
    return false;
  }
}

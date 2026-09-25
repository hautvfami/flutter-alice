import 'package:flutter/material.dart';
import 'package:flutter_alice/theme/theme.dart';

class AliceJsonViewer extends StatelessWidget {
  final dynamic jsonObj;
  const AliceJsonViewer({super.key, required this.jsonObj});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: aliceTheme,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Flutter JSON Viewer'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(child: JsonViewer(jsonObj)),
        ),
      ),
    );
  }
}

class JsonViewer extends StatefulWidget {
  final dynamic jsonObj;
  const JsonViewer(this.jsonObj, {super.key});

  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  @override
  Widget build(BuildContext context) {
    final content = widget.jsonObj;
    if (content == null) return const Text('{}');
    if (content is List) return JsonArrayViewer(content, notRoot: false);
    if (content is Map<String, dynamic>) {
      return JsonObjectViewer(content, notRoot: false);
    }
    if (content is Map) {
      return JsonObjectViewer(
        content.map((key, value) => MapEntry(key.toString(), value)),
        notRoot: false,
      );
    }
    return Text(content.toString());
  }
}

class JsonObjectViewer extends StatefulWidget {
  final Map<String, dynamic> jsonObj;
  final bool notRoot;

  const JsonObjectViewer(this.jsonObj, {super.key, this.notRoot = false});

  @override
  JsonObjectViewerState createState() => JsonObjectViewerState();
}

class JsonObjectViewerState extends State<JsonObjectViewer> {
  final Map<String, bool> openFlag = {};

  @override
  Widget build(BuildContext context) {
    if (widget.notRoot) {
      return Container(
        padding: const EdgeInsets.only(left: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _getList(),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _getList(),
    );
  }

  List<Widget> _getList() {
    final List<Widget> list = [];
    for (final entry in widget.jsonObj.entries) {
      final bool ex = isExtensible(entry.value);
      final bool ink = isInkWell(entry.value);
      list.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ex
                ? (openFlag[entry.key] ?? false)
                    ? const Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: Colors.black54,
                      )
                    : const Icon(
                        Icons.arrow_right,
                        size: 20,
                        color: Colors.black54,
                      )
                : const Icon(
                    Icons.arrow_right,
                    color: Colors.black54,
                    size: 20,
                  ),
            (ex && ink)
                ? InkWell(
                    onTap: () => _toggleOpenFlag(entry.key),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : Text(
                    entry.key,
                    style: TextStyle(
                      color: entry.value == null
                          ? Colors.black54
                          : Colors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            const Text(
              ':',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(width: 3),
            getValueWidget(entry)
          ],
        ),
      );
      list.add(const SizedBox(height: 4));
      if (openFlag[entry.key] ?? false) {
        list.add(getContentWidget(entry.value));
      }
    }
    return list;
  }

  static Widget getContentWidget(dynamic content) {
    if (content is List) {
      return JsonArrayViewer(content, notRoot: true);
    } else if (content is Map<String, dynamic>) {
      return JsonObjectViewer(content, notRoot: true);
    } else if (content is Map) {
      return JsonObjectViewer(
        content.map((k, v) => MapEntry(k.toString(), v)),
        notRoot: true,
      );
    }
    return Text(content.toString());
  }

  static bool isInkWell(dynamic content) {
    if (content == null ||
        content is int ||
        content is String ||
        content is bool ||
        content is double) {
      return false;
    } else if (content is List) {
      return content.isNotEmpty;
    }
    return true;
  }

  Widget getValueWidget(MapEntry<String, dynamic> entry) {
    final value = entry.value;
    return switch (value) {
      null => const Expanded(
          child: Text('undefined', style: TextStyle(color: Colors.grey)),
        ),
      num _ => Expanded(
          child: Text(
            value.toString(),
            style: const TextStyle(color: Colors.teal),
          ),
        ),
      String _ => Expanded(
          child: Text(
            '"$value"',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      bool _ => Expanded(
          child: Text(
            value.toString(),
            style: const TextStyle(color: Colors.purple),
          ),
        ),
      List<dynamic> _ when value.isEmpty => const Text(
          'Array[0]',
          style: TextStyle(color: Colors.black54),
        ),
      List<dynamic> _ => InkWell(
          onTap: () => _toggleOpenFlag(entry.key),
          child: Text(
            'Array<${getTypeName(value[0])}>[${value.length}]',
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      _ => InkWell(
          onTap: () => _toggleOpenFlag(entry.key),
          child: const Text('Object', style: TextStyle(color: Colors.black54)),
        ),
    };
  }

  static bool isExtensible(dynamic content) {
    if (content == null ||
        content is int ||
        content is String ||
        content is bool ||
        content is double) {
      return false;
    }
    return true;
  }

  static String getTypeName(dynamic content) {
    return switch (content) {
      int _ => 'int',
      String _ => 'String',
      bool _ => 'bool',
      double _ => 'double',
      List<dynamic> _ => 'List',
      _ => 'Object',
    };
  }

  void _toggleOpenFlag(String key) {
    setState(() {
      openFlag[key] = !(openFlag[key] ?? false);
    });
  }
}

class JsonArrayViewer extends StatefulWidget {
  final List<dynamic> jsonArray;
  final bool notRoot;

  const JsonArrayViewer(this.jsonArray, {super.key, this.notRoot = false});

  @override
  State<JsonArrayViewer> createState() => _JsonArrayViewerState();
}

class _JsonArrayViewerState extends State<JsonArrayViewer> {
  late List<bool> openFlag;

  @override
  Widget build(BuildContext context) {
    if (widget.notRoot) {
      return Container(
        padding: const EdgeInsets.only(left: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _getList(),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _getList(),
    );
  }

  @override
  void initState() {
    super.initState();
    openFlag = List.filled(widget.jsonArray.length, false);
    if (openFlag.isNotEmpty) {
      openFlag[0] = true;
    }
  }

  List<Widget> _getList() {
    final List<Widget> list = [];
    int i = 0;
    for (final dynamic content in widget.jsonArray) {
      final bool ex = JsonObjectViewerState.isExtensible(content);
      final bool ink = JsonObjectViewerState.isInkWell(content);
      list.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ex
              ? openFlag[i]
                  ? Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                      color: Colors.grey[700],
                    )
                  : Icon(Icons.arrow_right, size: 20, color: Colors.grey[700])
              : const Icon(
                  Icons.arrow_right,
                  color: Color.fromARGB(0, 0, 0, 0),
                  size: 20,
                ),
          (ex && ink)
              ? getInkWell(i)
              : Text(
                  '[$i]',
                  style: TextStyle(
                    color: content == null ? Colors.grey : Colors.deepPurple,
                  ),
                ),
          const Text(':', style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 3),
          getValueWidget(content, i)
        ],
      ));
      list.add(const SizedBox(height: 4));
      if (openFlag[i]) {
        list.add(JsonObjectViewerState.getContentWidget(content));
      }
      i++;
    }
    return list;
  }

  Widget getInkWell(int index) {
    return InkWell(
      onTap: () => _toggleOpenFlag(index),
      child: Text(
        '[$index]',
        style: const TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget getValueWidget(dynamic content, int index) {
    return switch (content) {
      null => const Expanded(
          child: Text('undefined', style: TextStyle(color: Colors.grey)),
        ),
      num _ => Expanded(
          child: Text(
            content.toString(),
            style: const TextStyle(color: Colors.teal),
          ),
        ),
      String _ => Expanded(
          child: Text(
            '"$content"',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      bool _ => Expanded(
          child: Text(
            content.toString(),
            style: const TextStyle(color: Colors.purple),
          ),
        ),
      List<dynamic> _ when content.isEmpty => const Text(
          'Array[0]',
          style: TextStyle(color: Colors.grey),
        ),
      List<dynamic> _ => InkWell(
          onTap: () => _toggleOpenFlag(index),
          child: Text(
            'Array<${JsonObjectViewerState.getTypeName(content)}>[${content.length}]',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      _ => InkWell(
          onTap: () => _toggleOpenFlag(index),
          child: const Text('Object', style: TextStyle(color: Colors.black54)),
        ),
    };
  }

  void _toggleOpenFlag(int index) {
    setState(() {
      openFlag[index] = !openFlag[index];
    });
  }
}

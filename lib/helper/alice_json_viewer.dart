library flutter_json_widget;

import 'package:flutter/material.dart';

class AliceJsonViewer extends StatelessWidget {
  final dynamic jsonObj;
  const AliceJsonViewer({super.key, required this.jsonObj});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Flutter JSON Viewer'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: SafeArea(child: JsonViewer(jsonObj)),
      ),
    );
  }
}

class JsonViewer extends StatefulWidget {
  final dynamic jsonObj;
  JsonViewer(this.jsonObj);
  @override
  _JsonViewerState createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  @override
  Widget build(BuildContext context) {
    final content = widget.jsonObj;
    if (content == null) return Text('{}');
    if (content is List) return JsonArrayViewer(content, notRoot: false);
    return JsonObjectViewer(content, notRoot: false);
  }
}

class JsonObjectViewer extends StatefulWidget {
  final Map<String, dynamic> jsonObj;
  final bool notRoot;

  JsonObjectViewer(this.jsonObj, {this.notRoot = false});

  @override
  JsonObjectViewerState createState() => new JsonObjectViewerState();
}

class JsonObjectViewerState extends State<JsonObjectViewer> {
  Map<String, bool> openFlag = Map();

  @override
  Widget build(BuildContext context) {
    if (widget.notRoot) {
      return Container(
        padding: EdgeInsets.only(left: 14.0),
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
    List<Widget> list = [];
    for (MapEntry entry in widget.jsonObj.entries) {
      bool ex = isExtensible(entry.value);
      bool ink = isInkWell(entry.value);
      list.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ex
                ? openFlag[entry.key] ?? false
                    ? Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: Colors.black54,
                      )
                    : Icon(
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
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => _toggleOpenFlag(entry.key),
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
            Text(
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
    } else {
      return JsonObjectViewer(content, notRoot: true);
    }
  }

  static isInkWell(dynamic content) {
    if (content == null) {
      return false;
    } else if (content is int) {
      return false;
    } else if (content is String) {
      return false;
    } else if (content is bool) {
      return false;
    } else if (content is double) {
      return false;
    } else if (content is List) {
      if (content.isEmpty) {
        return false;
      } else {
        return true;
      }
    }
    return true;
  }

  Widget getValueWidget(MapEntry entry) {
    if (entry.value == null) {
      return Expanded(
        child: Text('undefined', style: TextStyle(color: Colors.grey)),
      );
    } else if (entry.value is int) {
      return Expanded(
        child: Text(
          entry.value.toString(),
          style: TextStyle(color: Colors.teal),
        ),
      );
    } else if (entry.value is String) {
      return Expanded(
        child: Text(
          '\"' + entry.value + '\"',
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    } else if (entry.value is bool) {
      return Expanded(
        child: Text(
          entry.value.toString(),
          style: TextStyle(color: Colors.purple),
        ),
      );
    } else if (entry.value is double) {
      return Expanded(
        child: Text(
          entry.value.toString(),
          style: TextStyle(color: Colors.teal),
        ),
      );
    } else if (entry.value is List) {
      if (entry.value.isEmpty) {
        return Text(
          'Array[0]',
          style: TextStyle(color: Colors.black54),
        );
      } else {
        return InkWell(
          child: Text(
            'Array<${getTypeName(entry.value[0])}>[${entry.value.length}]',
            style: TextStyle(color: Colors.black54),
          ),
          onTap: () => _toggleOpenFlag(entry.key),
        );
      }
    }
    return InkWell(
      child: Text('Object', style: TextStyle(color: Colors.black54)),
      onTap: () => _toggleOpenFlag(entry.key),
    );
  }

  static isExtensible(dynamic content) {
    if (content == null) {
      return false;
    } else if (content is int) {
      return false;
    } else if (content is String) {
      return false;
    } else if (content is bool) {
      return false;
    } else if (content is double) {
      return false;
    }
    return true;
  }

  static getTypeName(dynamic content) {
    if (content is int) {
      return 'int';
    } else if (content is String) {
      return 'String';
    } else if (content is bool) {
      return 'bool';
    } else if (content is double) {
      return 'double';
    } else if (content is List) {
      return 'List';
    }
    return 'Object';
  }

  void _toggleOpenFlag(dynamic key) {
    setState(() {
      openFlag[key] = !(openFlag[key] ?? false);
    });
  }
}

class JsonArrayViewer extends StatefulWidget {
  final List<dynamic> jsonArray;

  final bool notRoot;

  JsonArrayViewer(this.jsonArray, {this.notRoot = false});

  @override
  _JsonArrayViewerState createState() => new _JsonArrayViewerState();
}

class _JsonArrayViewerState extends State<JsonArrayViewer> {
  late List<bool> openFlag;

  @override
  Widget build(BuildContext context) {
    if (widget.notRoot) {
      return Container(
        padding: EdgeInsets.only(left: 14.0),
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
    openFlag[0] = true;
  }

  _getList() {
    List<Widget> list = [];
    int i = 0;
    for (dynamic content in widget.jsonArray) {
      bool ex = JsonObjectViewerState.isExtensible(content);
      bool ink = JsonObjectViewerState.isInkWell(content);
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
          Text(':', style: TextStyle(color: Colors.grey)),
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
      child: Text(
        '[$index]',
        style: TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => _toggleOpenFlag(index),
    );
  }

  Widget getValueWidget(dynamic content, int index) {
    if (content == null) {
      return Expanded(
        child: Text('undefined', style: TextStyle(color: Colors.grey)),
      );
    } else if (content is int) {
      return Expanded(
        child: Text(content.toString(), style: TextStyle(color: Colors.teal)),
      );
    } else if (content is String) {
      return Expanded(
        child: Text(
          '\"' + content + '\"',
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    } else if (content is bool) {
      return Expanded(
        child: Text(
          content.toString(),
          style: TextStyle(color: Colors.purple),
        ),
      );
    } else if (content is double) {
      return Expanded(
        child: Text(
          content.toString(),
          style: TextStyle(color: Colors.teal),
        ),
      );
    } else if (content is List) {
      if (content.isEmpty) {
        return Text('Array[0]', style: TextStyle(color: Colors.grey));
      } else {
        return InkWell(
          child: Text(
            'Array<${JsonObjectViewerState.getTypeName(content)}>[${content.length}]',
            style: TextStyle(color: Colors.grey),
          ),
          onTap: () => _toggleOpenFlag(index),
        );
      }
    }
    return InkWell(
      child: Text('Object', style: TextStyle(color: Colors.black54)),
      onTap: () => _toggleOpenFlag(index),
    );
  }

  void _toggleOpenFlag(int index) {
    setState(() {
      openFlag[index] = !openFlag[index];
    });
  }
}

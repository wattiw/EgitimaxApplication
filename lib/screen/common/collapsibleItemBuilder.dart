import 'package:flutter/material.dart';

class CollapsibleItemBuilder extends StatefulWidget {
  final List<CollapsibleItemData> items;
  final double padding;
  final Function(bool) onStateChanged;

  CollapsibleItemBuilder({
    required this.items,
    required this.padding,
    required this.onStateChanged,
  });

  @override
  _CollapsibleItemBuilderState createState() => _CollapsibleItemBuilderState();
}

class _CollapsibleItemBuilderState extends State<CollapsibleItemBuilder> {
  List<bool> _expandedStates = [];

  @override
  void initState() {
    super.initState();
    _initExpandedStates();
  }

  void _initExpandedStates() {
    _expandedStates = List<bool>.filled(widget.items.length, false);
  }

  @override
  Widget build(BuildContext context) {
    if (_expandedStates.length != widget.items.length) {
      _expandedStates = List<bool>.filled(widget.items.length, false);
    }

    for (var item in widget.items) {
      _expandedStates[widget.items.indexOf(item)] = item.isExpanded ?? false;
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.items.length, (index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CollapsibleItem(
              header: widget.items[index].header,
              content: widget.items[index].content,
              padding: widget.padding,
              onStateChanged: (isExpanded) {
                setState(() {
                  _expandedStates[index] = isExpanded;
                  widget.onStateChanged(isExpanded);
                  widget.items[index].onStateChanged(isExpanded);
                });
              },
              isExpanded: _expandedStates[index],
            ),
            const SizedBox(
              height: 5,
            )
          ],
        );
      }),
    );
  }
}

class CollapsibleItem extends StatefulWidget {
  final Widget header;
  final Widget content;
  final double padding;
  final Function(bool) onStateChanged;
  final bool? isExpanded;

  CollapsibleItem({
    required this.header,
    required this.content,
    required this.padding,
    required this.onStateChanged,
    this.isExpanded=false,
  });

  @override
  _CollapsibleItemState createState() => _CollapsibleItemState();
}

class _CollapsibleItemState extends State<CollapsibleItem> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.isExpanded ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListTile(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
                widget.onStateChanged(isExpanded);
              });
            },
            title: widget.header,
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 1),
          isThreeLine: false,
        ),
        const SizedBox(
          height: 5,
        ),
        if (isExpanded)
          Padding(
              padding: EdgeInsets.all(widget.padding), child: Container(alignment: Alignment.centerLeft,child: widget.content)),
      ],
    );
  }
}

class CollapsibleItemData {
  final Widget header;
  final Widget content;
  final double padding;
  final Function(bool) onStateChanged;
  bool? isExpanded;

  CollapsibleItemData({
    required this.header,
    required this.content,
    required this.padding,
    required this.onStateChanged,
    this.isExpanded,
  });
}

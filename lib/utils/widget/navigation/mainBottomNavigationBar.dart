import 'package:flutter/material.dart';

class MainBottomNavigationBar extends StatefulWidget {
  final List<Widget> tabs;

  MainBottomNavigationBar({required this.tabs});

  @override
  _MainBottomNavigationBarWidgetState createState() =>
      _MainBottomNavigationBarWidgetState();
}

class _MainBottomNavigationBarWidgetState
    extends State<MainBottomNavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('Tab $index was pressed');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tabWidth = screenWidth / widget.tabs.length;

    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: widget.tabs.asMap().entries.map((entry) {
              final int index = entry.key;
              final Widget tab = entry.value;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: Container(
                    height: kBottomNavigationBarHeight,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: _selectedIndex == index
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(child: tab),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

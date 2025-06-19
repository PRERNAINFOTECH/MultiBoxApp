import 'package:flutter/material.dart';

class ScrollToTopWrapper extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;

  const ScrollToTopWrapper({
    super.key,
    required this.child,
    required this.scrollController,
  });

  @override
  State<ScrollToTopWrapper> createState() => _ScrollToTopWrapperState();
}

class _ScrollToTopWrapperState extends State<ScrollToTopWrapper> {
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (widget.scrollController.offset > 30 && !_showFab) {
      setState(() => _showFab = true);
    } else if (widget.scrollController.offset <= 30 && _showFab) {
      setState(() => _showFab = false);
    }
  }

  void _scrollToTop() {
    widget.scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showFab)
          Positioned(
            bottom: 50,
            right: 25,
            child: FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: Color.fromARGB(128, 155, 155, 155), // semi-transparent
              foregroundColor: Colors.white, // icon color
              child: const Icon(Icons.arrow_upward),
            ),
          ),
      ],
    );
  }
}

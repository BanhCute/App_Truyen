import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const MarqueeText({
    Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        startAnimation();
      }
    });
  }

  void startAnimation() {
    if (!mounted) return;

    try {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _animationController.forward();

        _animationController.addListener(() {
          if (_scrollController.hasClients) {
            try {
              final scrollPosition = _animationController.value *
                  _scrollController.position.maxScrollExtent;
              if (scrollPosition >= 0) {
                _scrollController.jumpTo(scrollPosition);
              }
            } catch (e) {
              print('Error during scroll: $e');
            }
          }
        });

        _animationController.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _animationController.reset();
            _animationController.forward();
          }
        });
      }
    } catch (e) {
      print('Error starting animation: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          widget.text,
          style: widget.style,
        ),
      ),
    );
  }
}

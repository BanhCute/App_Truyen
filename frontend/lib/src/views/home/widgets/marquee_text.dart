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
        _animationController.repeat();

        _animationController.addListener(() {
          if (_scrollController.hasClients) {
            try {
              _scrollController.jumpTo(
                _animationController.value *
                    _scrollController.position.maxScrollExtent,
              );
            } catch (e) {
              print('Error during scroll: $e');
            }
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

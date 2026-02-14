import 'package:flutter/material.dart';

class CS2Button extends StatefulWidget {
  final String text;
  final double? size;
  final VoidCallback onPressed;

  const CS2Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = 20,
  });

  @override
  State<CS2Button> createState() => _CS2ButtonState();
}

class _CS2ButtonState extends State<CS2Button> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;

    if (_isPressed) {
      bgColor = const Color.fromARGB(255, 90, 90, 90);
    } else if (_isHovered) {
      bgColor = const Color.fromARGB(255, 60, 60, 60);
    } else {
      bgColor = const Color.fromARGB(0, 45, 45, 45);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.zero,
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.size,
              fontFamily: "StratumNo2",
            ),
          ),
        ),
      ),
    );
  }
}

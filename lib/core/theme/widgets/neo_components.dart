import 'package:flutter/material.dart';
import '../neo_brutalism_theme.dart';

/// Reusable Neo-Brutalist Container Card
class NeoCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.backgroundColor = NeoBrutalism.surface,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(NeoBrutalism.borderRadius),
          border: Border.all(
            color: NeoBrutalism.border,
            width: NeoBrutalism.borderWidth,
          ),
          boxShadow: NeoBrutalism.shadow(),
        ),
        child: child,
      ),
    );
  }
}

/// Reusable Neo-Brutalist Button with Click Feedback
class NeoButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const NeoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = NeoBrutalism.primary,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(NeoBrutalism.borderRadius),
          border: Border.all(
            color: NeoBrutalism.border,
            width: NeoBrutalism.borderWidth,
          ),
          boxShadow: _isPressed
              ? NeoBrutalism.shadow(
                  const Offset(0, 0),
                ) // Shadow compresses on click
              : NeoBrutalism.shadow(const Offset(4, 4)),
        ),
        child: Text(
          widget.text.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: Colors.black,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

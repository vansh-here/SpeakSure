import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class HoverContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final Color? color;
  final BoxBorder? border;
  final List<BoxShadow>? hoverShadows;
  final Duration duration;

  const HoverContainer({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.color,
    this.border,
    this.hoverShadows,
    this.duration = const Duration(milliseconds: 180),
  });

  @override
  State<HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<HoverContainer> {
  bool _hovering = false;

  void _setHover(bool value) {
    if (!kIsWeb) return; // hover only on web
    setState(() => _hovering = value);
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.color ?? Theme.of(context).cardColor;
    final hoverShadows = widget.hoverShadows ??
        [
          BoxShadow(
            color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.25 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ];

    Widget content = AnimatedContainer(
      duration: widget.duration,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: widget.borderRadius,
        border: widget.border,
        boxShadow: _hovering ? hoverShadows : null,
      ),
      transform: _hovering
          ? (Matrix4.identity()..translate(0.0, -2.0))
          : Matrix4.identity(),
      child: widget.child,
    );

    if (widget.onTap != null) {
      content = Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: widget.borderRadius),
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: widget.onTap,
          child: content,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: content,
    );
  }
}

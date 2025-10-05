import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = Responsive.isDesktop(context) ? 1280.0 : (Responsive.isTablet(context) ? 960.0 : double.infinity);
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: body,
        ),
      ),
    );
  }
}






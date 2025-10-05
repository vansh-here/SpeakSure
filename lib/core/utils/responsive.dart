import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 && 
           MediaQuery.of(context).size.width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  static double getResponsiveWidth(BuildContext context, {
    double mobile = 1.0,
    double tablet = 0.8,
    double desktop = 0.6,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isMobile(context)) {
      return mobile ?? const EdgeInsets.all(16);
    }
    if (isTablet(context)) {
      return tablet ?? const EdgeInsets.all(24);
    }
    return desktop ?? const EdgeInsets.all(32);
  }

  static int getResponsiveColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  static double getResponsiveFontSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static Widget responsiveBuilder(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }
}





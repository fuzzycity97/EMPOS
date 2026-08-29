import 'package:flutter/material.dart';
import 'breakpoints.dart';

typedef ResponsiveWidgetBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktopMin) {
          return desktop;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobileMax) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}

class AdaptiveValue<T> {
  final T mobile;
  final T? tablet;
  final T desktop;

  const AdaptiveValue({
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  T get(BuildContext context) {
    final type = ResponsiveBreakpoints.getDeviceType(context);
    switch (type) {
      case DeviceScreenType.mobile:
        return mobile;
      case DeviceScreenType.tablet:
        return tablet ?? desktop;
      case DeviceScreenType.desktop:
        return desktop;
    }
  }
}

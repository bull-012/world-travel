import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:world_travel/pages/home_page.dart';
import 'package:world_travel/pages/second_page.dart';

import 'router_wrapper.dart';

/// The Widgetbook app for the World Travel application.
class WidgetbookApp extends StatelessWidget {
  /// Creates a new [WidgetbookApp].
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookFolder(
          name: 'Pages',
          children: [
            WidgetbookComponent(
              name: 'Home',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => const RouterWrapper(
                    child: HomePage(),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'Second Page',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => const RouterWrapper(
                    child: SecondPage(
                      args: SecondPageArgs(title: 'Second Page'),
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'With Custom Title',
                  builder: (context) => const RouterWrapper(
                    child: SecondPage(
                      args: SecondPageArgs(title: 'Custom Title'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: ThemeData.light()),
            WidgetbookTheme(name: 'Dark', data: ThemeData.dark()),
          ],
        ),
        DeviceFrameAddon(
          initialDevice: Devices.ios.iPhone13,
          devices: [
            Devices.ios.iPhoneSE,
            Devices.ios.iPhone12Mini,
            Devices.ios.iPhone12,
            Devices.ios.iPhone12ProMax,
            Devices.ios.iPhone13Mini,
            Devices.ios.iPhone13,
            Devices.ios.iPhone13ProMax,
            Devices.ios.iPad,
            Devices.android.smallPhone,
            Devices.android.mediumPhone,
            Devices.android.bigPhone,
          ],
        ),
      ],
    );
  }
}

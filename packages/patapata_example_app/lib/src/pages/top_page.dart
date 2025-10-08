// Copyright (c) GREE, Inc.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import 'package:flutter/material.dart';
import 'package:patapata_core/patapata_widgets.dart';
import 'package:patapata_example_app/src/pages/device_and_package_info_page.dart';
import 'package:patapata_example_app/src/pages/error_page.dart';
import 'package:patapata_example_app/src/pages/standard_page_example_page.dart';
import 'package:patapata_example_app/src/repository/repository_example1.dart';

import 'config_page.dart';
import 'screen_layout_example_page.dart';
import 'home_page.dart';

/// Material version of the TopPage.
/// You can navigate to a sample screen demonstrating the features of Patapata from this pages.
class TopPage extends StandardPage<void> {
  @override
  String localizationKey = 'pages.top';

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.pl('title')),
      ),
      body: ListView(
        children: [
          Center(
            child: Text(context.pl('body')),
          ),
          TextButton(
            onPressed: () {
              context.go<ConfigPage, void>(null);
            },
            child: Text(context.pl('go_to_config')),
          ),
          TextButton(
            onPressed: () {
              context.go<ScreenLayoutExamplePage, void>(null);
            },
            child: Text(context.pl('go_to_screen_layout')),
          ),
          TextButton(
            onPressed: () {
              context.go<RepositoryExample1, void>(null);
            },
            child: Text(context.pl('go_to_repository_system')),
          ),
          TextButton(
            onPressed: () {
              context.go<StandardPageExamplePage, void>(null);
            },
            child: Text(context.pl('go_to_standard_page')),
          ),
          TextButton(
            onPressed: () {
              context.go<DeviceAndPackageInfoPage, void>(null);
            },
            child: Text(context.pl('go_to_device_and_pakage_info')),
          ),
          TextButton(
            onPressed: () {
              context.go<ErrorSelectPage, void>(null);
            },
            child: Text(context.pl('go_to_error')),
          ),
          TextButton(
            onPressed: () {
              context.go<HomePage, void>(null);
            },
            child: Text(context.pl('go_to_tab')),
          ),
        ],
      ),
    );
  }
}

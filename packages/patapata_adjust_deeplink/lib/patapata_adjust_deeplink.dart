import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:patapata_core/patapata_core.dart';
import 'package:patapata_core/patapata_core_libs.dart';
import 'package:patapata_core/patapata_widgets.dart';

final _logger = Logger('AdjustDeepLinkPlugin');

class AdjustDeepLinkPlugin extends Plugin with StandardAppRoutePluginMixin {
  late final AppLinks _appLinks;
  Uri? _initialLink;

  final _methodChannel = const MethodChannel('dev.patapata.patapata_adjust_deeplink');

  @override
  FutureOr<bool> init(App app) async {
    await super.init(app);

    _methodChannel.setMethodCallHandler(_onMethodChannelCall);

    _appLinks = AppLinks();

    app.getPlugin<StandardAppPlugin>()?.addLinkHandler(_linkHandler);

    _initialLink = await _appLinks.getInitialLink();

    return true;
  }

  @override
  FutureOr<void> dispose() {
    app.getPlugin<StandardAppPlugin>()?.removeLinkHandler(_linkHandler);
    return super.dispose();
  }

  Future<dynamic> _onMethodChannelCall(MethodCall call) async {
    switch (call.method) {
      case 'processAdjustDeepLink':
        final tUri = Uri.parse(call.arguments as String);
        processAdjustDeepLink(tUri);
        break;
      default:
        break;
    }
  }

  bool _linkHandler(Uri link) {
    if (link.queryParameters.containsKey('link')) {
      return true;
    }

    return false;
  }

  @override
  Future<StandardRouteData?> getInitialRouteData() {
    if (_initialLink == null) {
      return SynchronousFuture(null);
    }

    final tParser = app.getPlugin<StandardAppPlugin>()?.parser;

    if (tParser == null) {
      return SynchronousFuture(null);
    }

    final tLink = _getLink(_initialLink!);
    if (tLink == null) {
      return SynchronousFuture(null);
    }

    return tParser.parseRouteInformation(
      RouteInformation(
        uri: tLink,
      ),
    );
  }

  Uri? _getLink(Uri uri) {
    // NOTE: linkのクエリパラメータをURIに変換
    final tLink = uri.queryParameters['link'];
    if (tLink == null) {
      return null;
    }

    return Uri.parse(
      tLink
          // NOTE: FDLのようにlinkのクエリパラメータを使う場合は、[]を削除する
          .replaceAll('[', '')
          .replaceAll(']', ''),
    );
  }

  Future<void> processAdjustDeepLink(Uri uri) async {
    _logger.info('processAdjustDeepLink: $uri');

    final tPlugin = app.getPlugin<StandardAppPlugin>();

    final tParser = tPlugin?.parser;

    if (tParser == null) {
      return;
    }

    final tLink = _getLink(uri);
    if (tLink == null) {
      return SynchronousFuture(null);
    }

    final tConfiguration = await tParser.parseRouteInformation(
      RouteInformation(
        uri: tLink,
      ),
    );

    tPlugin?.delegate?.routeWithConfiguration(tConfiguration);
  }

  Future<String?> generateExternalLink({
    required Uri link,
    required String uriPrefix,
  }) async {
    return "$uriPrefix?link=$link";
  }
}

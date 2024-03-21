// Copyright (c) GREE, Inc.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patapata_core/patapata_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

/// The [App] instance.
@riverpod
App app(AppRef ref) {
  return getApp();
}

/// The current [User].
/// Whenever [User] changes, this provider will be updated.
@riverpod
Raw<User> user(UserRef ref) {
  return ref.disposeAndListenChangeNotifier(ref.read(appProvider).user);
}

/// Access to [RemoteConfig].
/// Whenever [RemoteConfig] changes, this provider will be updated.
@riverpod
Raw<RemoteConfig> remoteConfig(RemoteConfigRef ref) {
  return ref.disposeAndListenChangeNotifier(ref.read(appProvider).remoteConfig);
}

/// Gets a [RemoteConfig] value as a [String].
/// Whenever this [key] changes, this provider will be updated.
@riverpod
String remoteConfigString(RemoteConfigStringRef ref, String key,
    [String defaultValue = Config.defaultValueForString]) {
  return ref.watch(remoteConfigProvider
      .select((v) => v.getString(key, defaultValue: defaultValue)));
}

/// Gets a [RemoteConfig] value as a [int].
/// Whenever this [key] changes, this provider will be updated.
@riverpod
int remoteConfigInt(RemoteConfigIntRef ref, String key,
    [int defaultValue = Config.defaultValueForInt]) {
  return ref.watch(remoteConfigProvider
      .select((v) => v.getInt(key, defaultValue: defaultValue)));
}

/// Gets a [RemoteConfig] value as a [double].
/// Whenever this [key] changes, this provider will be updated.
@riverpod
double remoteConfigDouble(RemoteConfigDoubleRef ref, String key,
    [double defaultValue = Config.defaultValueForDouble]) {
  return ref.watch(remoteConfigProvider
      .select((v) => v.getDouble(key, defaultValue: defaultValue)));
}

/// Gets a [RemoteConfig] value as a [bool].
/// Whenever this [key] changes, this provider will be updated.
@riverpod
bool remoteConfigBool(RemoteConfigBoolRef ref, String key,
    [bool defaultValue = Config.defaultValueForBool]) {
  return ref.watch(remoteConfigProvider
      .select((v) => v.getBool(key, defaultValue: defaultValue)));
}

/// Access to [LocalConfig].
/// Whenever [LocalConfig] changes, this provider will be updated.
@riverpod
Raw<LocalConfig> localConfig(LocalConfigRef ref) {
  return ref.disposeAndListenChangeNotifier(ref.read(appProvider).localConfig);
}

/// Gets a [LocalConfig] value as a [String].
/// Whenever this [key] changes, this provider will be updated.
@riverpod
String localConfigString(LocalConfigStringRef ref, String key,
    [String defaultValue = Config.defaultValueForString]) {
  return ref.watch(localConfigProvider
      .select((v) => v.getString(key, defaultValue: defaultValue)));
}

/// Gets a [LocalConfig] value as a [int].
/// Whenever this [key] changes, this provider will be updated.
@riverpod
int localConfigInt(LocalConfigIntRef ref, String key,
    [int defaultValue = Config.defaultValueForInt]) {
  return ref.watch(localConfigProvider
      .select((v) => v.getInt(key, defaultValue: defaultValue)));
}

/// Gets a [LocalConfig] value as a [double].
/// Whenever this [key] changes, this provider will be updated.
@riverpod
double localConfigDouble(LocalConfigDoubleRef ref, String key,
    [double defaultValue = Config.defaultValueForDouble]) {
  return ref.watch(localConfigProvider
      .select((v) => v.getDouble(key, defaultValue: defaultValue)));
}

/// Gets a [LocalConfig] value as a [bool].
/// Whenever this [key] changes, this provider will be updated.
@riverpod
bool localConfigBool(LocalConfigBoolRef ref, String key,
    [bool defaultValue = Config.defaultValueForBool]) {
  return ref.watch(localConfigProvider
      .select((v) => v.getBool(key, defaultValue: defaultValue)));
}

/// Access to [RemoteMessaging].
/// Whenever [RemoteMessaging] changes, this provider will be updated.
@riverpod
Raw<RemoteMessaging> remoteMessaging(RemoteMessagingRef ref) {
  return ref
      .disposeAndListenChangeNotifier(ref.read(appProvider).remoteMessaging);
}

/// Access to [RemoteMessaging.messages].
/// Whenever a new [RemoteMessage] is receieved via [RemoteMessaging.messages], this provider will be updated.
/// The first execution of this will return the initial message from [RemoteMessaging.getInitialMessage].
@riverpod
Stream<RemoteMessage> remoteMessagingMessages(
    RemoteMessagingMessagesRef ref) async* {
  final tRemoteMessaging = ref.watch(remoteMessagingProvider);

  final tInitialMessage = await tRemoteMessaging.getInitialMessage();

  if (tInitialMessage != null) {
    yield tInitialMessage;
  }

  yield* tRemoteMessaging.messages;
}

/// Access to [RemoteMessaging.tokens].
/// Whenever a new token is receieved via [RemoteMessaging.tokens], this provider will be updated.
/// The first execution of this will return the current token from [RemoteMessaging.getToken].
@riverpod
Stream<String?> remoteMessagingTokens(RemoteMessagingTokensRef ref) async* {
  final tRemoteMessaging = ref.watch(remoteMessagingProvider);

  yield await tRemoteMessaging.getToken();
  yield* tRemoteMessaging.tokens;
}

/// Access to [Analytics].
@riverpod
Analytics analytics(AnalyticsRef ref) {
  return ref.read(appProvider).analytics;
}

/// Access to the global [AnalyticsContext] from [Analytics.globalContext].
@riverpod
AnalyticsContext globalAnalyticsContext(GlobalAnalyticsContextRef ref) {
  return ref.read(analyticsProvider).globalContext;
}

/// Access to a stream of [NetworkInformation].
/// Whenever [NetworkInformation] changes, this provider will be updated.
@riverpod
NetworkInformation networkInformation(NetworkInformationRef ref) {
  final tNetworkPlugin = ref.read(appProvider).getPlugin<NetworkPlugin>()!;

  final tSubscription = tNetworkPlugin.informationStream.listen((event) {
    ref.invalidateSelf();
  });

  ref.onDispose(tSubscription.cancel);

  return tNetworkPlugin.information;
}

/// Access to [PackageInfo].
@riverpod
PackageInfoPlugin packageInfo(PackageInfoRef ref) {
  return ref.read(appProvider).package;
}

/// Access to [DeviceInfo].
@riverpod
DeviceInfoPlugin deviceInfo(DeviceInfoRef ref) {
  return ref.read(appProvider).device;
}

extension _Disposeable on Ref {
  // We can move the previous logic to a Ref extension.
  // This enables reusing the logic between providers
  T disposeAndListenChangeNotifier<T extends ChangeNotifier>(T notifier) {
    onDispose(() {
      notifier.removeListener(notifyListeners);
    });
    notifier.addListener(notifyListeners);
    // We return the notifier to ease the usage a bit
    return notifier;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:world_travel/common/models/build_config.dart';
import 'package:world_travel/common/providers/build_config_provider.dart';
import 'package:world_travel/common/providers/firebase_auth.dart';
import 'package:world_travel/common/providers/firebase_remote_config.dart';
import 'package:world_travel/common/providers/shared_preferences_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef InitializedValues = ({
  List<Override> overrideProviders,
});

final class AppInitializer {
  AppInitializer._();

  static Future<InitializedValues> initialize() async {
    final overrideProviders = await _initializeProviders();

    return (overrideProviders: overrideProviders);
  }

  static Future<List<Override>> _initializeProviders() async {
    final overrides = <Override>[];

    final packageInfo = await PackageInfo.fromPlatform();
    final preferences = await SharedPreferences.getInstance();
    final firebaseAuthInstance = FirebaseAuth.instance;
    final firebaseRemoteConfigInstance = FirebaseRemoteConfig.instance;

    final buildConfig = AppBuildConfig(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      buildSignature: packageInfo.buildSignature,
      installerStore: packageInfo.installerStore,
    );

    overrides.addAll(
      [
        sharedPreferencesProvider.overrideWithValue(preferences),
        buildConfigProvider.overrideWithValue(buildConfig),
        firebaseAuthProvider.overrideWithValue(firebaseAuthInstance),
        firebaseRemoteConfigProvider.overrideWithValue(
          firebaseRemoteConfigInstance,
        ),
      ],
    );
    return overrides;
  }
}
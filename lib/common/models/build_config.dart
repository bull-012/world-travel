abstract interface class BuildConfig {
  abstract final String appName;
  abstract final String packageName;
  abstract final String version;
  abstract final String buildNumber;
  abstract final String buildSignature;
  abstract final String? installerStore;
}

final class AppBuildConfig implements BuildConfig {
  AppBuildConfig({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.buildSignature,
    this.installerStore,
  });

  @override
  String appName;

  @override
  String packageName;

  @override
  String version;

  @override
  String buildNumber;

  @override
  String buildSignature;

  @override
  String? installerStore;
}

final class FakeBuildConfig implements BuildConfig {
  FakeBuildConfig({
    this.appName = 'Quol Fake',
    this.packageName = 'quol.fake',
    this.version = '1.0.0',
    this.buildNumber = '1',
    this.buildSignature = '1',
    this.installerStore = 'fake_store',
  });

  @override
  final String appName;
  @override
  final String packageName;
  @override
  final String version;
  @override
  final String buildNumber;
  @override
  final String buildSignature;
  @override
  final String? installerStore;
}

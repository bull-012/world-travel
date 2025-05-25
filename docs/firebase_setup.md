# Firebase セットアップ

このドキュメントでは、プロジェクトに Firebase を設定する方法について説明します。

## 前提条件

- Firebase プロジェクトが作成されていること
- Flutter プロジェクトが設定されていること

## セットアップ手順

### 1. Firebase プロジェクトの作成

1. [Firebase Console](https://console.firebase.google.com/) にアクセスします
2. 「プロジェクトを追加」をクリックします
3. プロジェクト名を入力し、指示に従ってプロジェクトを作成します

### 2. iOS アプリの追加

1. Firebase プロジェクトのダッシュボードで「iOS」アイコンをクリックしてアプリを追加します
2. iOS バンドル ID を入力します（例: `com.example.worldTravel`） (決まっているならバンドルIDもここで決めましょう)
3. アプリのニックネームと App Store ID（AppStoreConnectに登録する必要あり。オプション）を入力します
4. 「アプリを登録」をクリックします
5. `GoogleService-Info.plist` ファイルをダウンロードします(必ずXcode上で)
6. ダウンロードした `GoogleService-Info.plist` ファイルを iOS プロジェクトの `Runner` ディレクトリに配置します
   - Xcode でプロジェクトを開き、Runner ターゲットを選択します
   - `GoogleService-Info.plist` ファイルを Runner フォルダにドラッグ＆ドロップします
   - 「Copy items if needed」にチェックを入れ、「Add to targets」で「Runner」を選択します

### 3. Android アプリの追加

1. Firebase プロジェクトのダッシュボードで「Android」アイコンをクリックしてアプリを追加します
2. Android パッケージ名を入力します（例: `com.example.world_travel`）
3. アプリのニックネームと SHA-1 キー（オプション）を入力します
4. 「アプリを登録」をクリックします
5. `google-services.json` ファイルをダウンロードします
6. ダウンロードした `google-services.json` ファイルを Android プロジェクトの `android/app` ディレクトリに配置します

### 4. Flutter プロジェクトの設定

1. 必要な依存関係が `pubspec.yaml` に追加されていることを確認します：

```yaml
dependencies:
  firebase_core: ^3.12.1
  firebase_auth: ^5.5.1
  firebase_messaging: ^15.2.4
  firebase_crashlytics: ^4.3.4
  firebase_analytics: ^11.4.4
  firebase_remote_config: ^5.4.2
```

2. 依存関係をインストールします：

```bash
flutter pub get
```

3. `lib/main.dart` で Firebase を初期化します：

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

## Swift Package Manager (SPM) の使用

このプロジェクトでは、CocoaPods の代わりに Swift Package Manager (SPM) を使用して iOS の Firebase SDK を管理しています。

Xcode で SPM を使用して Firebase SDK を追加する方法：

1. Xcode でプロジェクトを開きます
2. File > Swift Packages > Add Package Dependency を選択します
3. Firebase iOS SDK の URL を入力します: `https://github.com/firebase/firebase-ios-sdk.git`
4. 必要な Firebase コンポーネントを選択します（Analytics, Auth, Crashlytics, Messaging, Remote Config など）

## トラブルシューティング

- Firebase の初期化に問題がある場合は、`GoogleService-Info.plist` または `google-services.json` ファイルが正しい場所に配置されていることを確認してください
- iOS ビルドに問題がある場合は、Xcode プロジェクトで Swift Package の依存関係が正しく設定されていることを確認してください
- Android ビルドに問題がある場合は、`android/app/build.gradle` ファイルに Google サービスプラグインが正しく設定されていることを確認してください
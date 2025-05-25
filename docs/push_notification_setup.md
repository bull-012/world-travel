# プッシュ通知セットアップ

このドキュメントでは、プロジェクトにプッシュ通知機能を設定する方法について説明します。

## 前提条件

- Firebase プロジェクトが設定されていること（[Firebase セットアップ](./firebase_setup.md)を参照）
- iOS の場合、Apple Developer アカウントが必要です

## セットアップ手順

### 1. Firebase Cloud Messaging (FCM) の設定

#### iOS の設定

1. Apple Developer アカウントで APNs 証明書を作成します：
   - [Apple Developer Console](https://developer.apple.com/account/resources/certificates/list) にアクセスします
   - 「Certificates, Identifiers & Profiles」セクションに移動します
   - 「Keys」タブを選択し、「+」ボタンをクリックして新しいキーを作成します
   - キー名を入力し、「Apple Push Notifications service (APNs)」にチェックを入れます
   - 「Continue」をクリックし、指示に従って APNs キーを生成します
   - キーをダウンロードして安全に保管します

2. Firebase Console で APNs 証明書をアップロードします：
   - Firebase プロジェクトのダッシュボードで「Cloud Messaging」タブに移動します
   - 「iOS アプリ構成」セクションで「APNs 認証キーをアップロード」をクリックします
   - ダウンロードした APNs キーをアップロードし、Key ID と Team ID を入力します
   - 「アップロード」をクリックします

3. Xcode プロジェクトの設定：
   - Xcode でプロジェクトを開きます
   - 「Signing & Capabilities」タブで「+ Capability」をクリックし、「Push Notifications」を追加します
   - 「Background Modes」も追加し、「Remote notifications」にチェックを入れます

#### Android の設定

1. Firebase Console で Android アプリの設定が完了していることを確認します
2. 特別な設定は必要ありませんが、`android/app/build.gradle` ファイルに Google サービスプラグインが正しく設定されていることを確認してください

### 2. Flutter プロジェクトの設定

1. 必要な依存関係が `pubspec.yaml` に追加されていることを確認します：

```yaml
dependencies:
  firebase_core: ^3.12.1
  firebase_messaging: ^15.2.4
  flutter_local_notifications: ^19.0.0
```

2. 依存関係をインストールします：

```bash
flutter pub get
```

3. プッシュ通知ハンドラーを設定します：

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// バックグラウンドメッセージハンドラー
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('バックグラウンドメッセージを受信しました: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // バックグラウンドメッセージハンドラーを設定
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // 通知権限をリクエスト
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  // FCM トークンを取得
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $fcmToken');
  
  // ローカル通知の初期化
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettingsIOS = DarwinInitializationSettings();
  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // 通知がタップされたときの処理
      print('通知がタップされました: ${response.payload}');
    },
  );
  
  // フォアグラウンドでの通知表示設定
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  
  // フォアグラウンドメッセージハンドラー
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('フォアグラウンドメッセージを受信しました:');
    print('メッセージデータ: ${message.data}');
    
    if (message.notification != null) {
      print('メッセージ通知: ${message.notification}');
      
      // ローカル通知を表示
      final notification = message.notification;
      final android = message.notification?.android;
      
      final androidNotificationDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        icon: android?.smallIcon,
      );
      
      final iosNotificationDetails = DarwinNotificationDetails();
      final notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );
      
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        notification?.title,
        notification?.body,
        notificationDetails,
        payload: message.data['payload'],
      );
    }
  });
  
  runApp(const MyApp());
}
```

### 3. プッシュ通知のテスト

1. Firebase Console でテスト通知を送信します：
   - Firebase プロジェクトのダッシュボードで「Cloud Messaging」タブに移動します
   - 「最初のキャンペーンを作成」または「新しいキャンペーン」をクリックします
   - 「通知」を選択し、タイトルと本文を入力します
   - ターゲットとして登録したアプリを選択します
   - 「確認」をクリックし、「公開」をクリックしてテスト通知を送信します

2. アプリがフォアグラウンドとバックグラウンドの両方の状態でプッシュ通知を受信できることを確認します

## トラブルシューティング

- iOS で通知が届かない場合：
  - APNs 証明書が正しく設定されていることを確認します
  - Xcode プロジェクトで Push Notifications と Background Modes が有効になっていることを確認します
  - デバイスの通知設定でアプリの通知が許可されていることを確認します

- Android で通知が届かない場合：
  - Firebase Console で Android アプリが正しく設定されていることを確認します
  - デバイスの通知設定でアプリの通知が許可されていることを確認します
  - バッテリー最適化設定でアプリが除外されていることを確認します

- FCM トークンが取得できない場合：
  - Firebase の初期化が正しく行われていることを確認します
  - インターネット接続を確認します
  - Firebase プロジェクトの設定を確認します
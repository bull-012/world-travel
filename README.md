# World Travel

このプロジェクトは、Flutter アプリケーションを開発する際のテンプレートプロジェクトです。

## 概要

World Travel は、最新のアーキテクチャパターンと技術を採用した Flutter テンプレートプロジェクトです。このプロジェクトは、新しい Flutter アプリケーションを開発する際の出発点として使用できます。

### 現在の実装状況

✅ **基本機能**
- カウンター機能（非同期操作のデモ）
- 名前入力フォーム（日本語・カナ入力対応）
- ページ間ナビゲーション
- Firebase 統合設定（認証・メッセージング・アナリティクス）
- Widgetbook によるコンポーネントドキュメント

🚧 **開発中の機能**
- 旅行関連の実際の機能実装
- ユーザー認証システムの有効化
- プッシュ通知機能
- リモート設定の活用

## アーキテクチャ

このプロジェクトは、以下のアーキテクチャ原則に基づいています：

### CQRS パターン

CQRS（Command Query Responsibility Segregation）パターンを採用しており、読み取り操作（Query）と書き込み操作（Command）を明確に分離しています。

#### Command の実装例
```dart
// lib/features/profile/command/counter_command.dart
@riverpod
class CounterCommand extends _$CounterCommand {
  @override
  CounterState build() {
    return const CounterState();
  }

  Future<void> incrementCounter() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(counter: state.counter + 1);
  }
}
```

#### Query（Provider）の実装例
```dart
// lib/features/profile/providers/counter_provider.dart
@riverpod
class Counter extends _$Counter {
  @override
  Future<int> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return 0;
  }

  Future<void> increment() async {
    state = const AsyncLoading();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = AsyncData(state.value! + 1);
  }
}
```

このパターンにより、コードの責任が明確に分離され、保守性と拡張性が向上します。

### Riverpod をキャッシュライブラリとして使用

このプロジェクトでは、Riverpod を単なる状態管理ライブラリではなく、キャッシュライブラリとして使用しています。この考え方は React の tanstack query（旧 React Query）に影響を受けています。

#### AsyncValue による状態管理
```dart
// AsyncValue の基本的な使用方法
final dataAsync = ref.watch(dataProvider);

switch (dataAsync) {
  case AsyncData(:final value) => 
    Text('Data: $value'),
  case AsyncLoading() => 
    const CircularProgressIndicator(),
  case AsyncError(:final error) => 
    Text('Error: $error'),
}
```

#### 複数のAsyncValueの組み合わせ
```dart
// lib/common/extensions/async_value_group.dart を使用
final mergedData = AsyncValueGroup.group2(
  nameAsync,
  counterAsync,
);

switch (mergedData) {
  case AsyncData(:final value) => {
    final (name, counter) = value;
    // 両方のデータが揃った時の処理
  }
  // ...
}
```

主な特徴：
- データの非同期取得とキャッシュ
- キャッシュの自動無効化と再検証
- ローディング状態とエラー状態の管理
- サーバー状態とクライアント状態の明確な分離
- 複数の非同期操作の組み合わせ（AsyncValueGroup）

## 主要な技術とライブラリ

### ルーティング: GoRouter

型安全なルーティングのために GoRouter を使用しています。コード生成により型安全性を保証しています。

#### ルート定義の例
```dart
// lib/router/router.dart
@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: [
    TypedGoRoute<SecondRoute>(path: 'second'),
    TypedGoRoute<SampleRoute>(path: 'sample'),
  ],
)
class HomeRoute extends GoRouteData {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}
```

#### 型安全なナビゲーション
```dart
// パラメータ付きナビゲーション
const SampleRoute(
  $extra: SamplePageArgs(title: 'Sample Profile'),
).go(context);

// より簡潔な記述
const SecondRoute(
  $extra: SecondPageArgs(title: 'Page'),
).go(context);
```

主な機能：
- コード生成による型安全性
- 宣言的なルート定義
- ディープリンクのサポート
- パラメータ付きルート
- ネストされたルート
- リダイレクト

### UI コンポーネントドキュメント: Widgetbook

UI コンポーネントのドキュメント化と視覚的なテストのために Widgetbook を使用しています。

#### Widgetbook の構成例
```dart
// widgetbook/widgetbook_app.dart
Widgetbook.material(
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
      devices: [
        Devices.ios.iPhone13,
        Devices.android.mediumPhone,
        // ...
      ],
    ),
  ],
);
```

#### ビルドコマンド
```bash
# Widgetbook のビルド
flutter build web -t widgetbook/main.dart --release
```

これにより、以下が可能になります：
- コンポーネントの独立したプレビュー
- 異なるデバイスサイズでのテスト
- 異なるテーマでのテスト
- ユースケースの文書化
- CI/CD での自動デプロイ

### 依存関係管理: Swift Package Manager (SPM)

iOS プラットフォームでは、CocoaPods の代わりに Swift Package Manager (SPM) を使用して依存関係を管理しています。SPM の利点：

- Xcode との統合
- ビルド時間の短縮
- 依存関係の解決の改善
- Apple のエコシステムとの整合性

### CI/CD パイプライン

コード品質を確保するために、GitHub Actions で以下のチェックを実行しています：

#### コード品質チェック
- コードフォーマットのチェック（`dart format --set-exit-if-changed .`）
- 静的解析（`flutter analyze`）
- 自動生成コードの検証
- テストの実行（`flutter test`）
- 視覚的回帰テスト（VRT with Alchemist）

#### ビルドチェック
- iOS ビルド（`flutter build ios --release --no-codesign`）
- Android ビルド（`flutter build apk`）
- Web ビルド（`flutter build web`）
- Widgetbook ビルド（`flutter build web -t widgetbook/main.dart`）

#### 自動デプロイ
- Widgetbook の自動デプロイ（PR 作成時）
- GitHub Pages へのデプロイ

#### Flutter バージョン管理
- `.fvmrc` ファイルからのバージョン自動読み取り
- FVM を使用した一貫したバージョン管理

## セットアップガイド

### 基本セットアップ

#### 1. 環境要件
```bash
# Flutter バージョン管理 (FVM)
fvm use 3.32.0

# 依存関係のインストール
flutter pub get

# コード生成
dart run build_runner build --delete-conflicting-outputs
```

#### 2. 環境変数の設定

このプロジェクトでは MapBox を使用しているため、環境変数の設定が必要です。

```bash
# 1. サンプルファイルをコピー
cp dart_defines/dev.env.sample dart_defines/dev.env
cp dart_defines/qa.env.sample dart_defines/qa.env
cp dart_defines/prod.env.sample dart_defines/prod.env

# 2. 各ファイルを編集して、実際の MapBox トークンを設定
# MapBox アカウントから以下の2つのトークンを取得：
# - Public Access Token (pk.*): https://account.mapbox.com/access-tokens/
# - Secret Download Token (sk.*): https://account.mapbox.com/access-tokens/
```

**Android 追加設定**:
```bash
# Android ビルド用に MapBox SDK ダウンロードトークンを設定

# local.properties を使用（推奨）
cp android/local.properties.sample android/local.properties

# local.properties を編集して、ファイルの最後に以下を追加：
# MAPBOX_DOWNLOADS_TOKEN=sk.your_secret_token_here

# 注意: local.properties は .gitignore に含まれているため、
# 各開発者が自分の環境で設定する必要があります
```

**重要**: 
- 環境変数ファイル（`.env`）と `local.properties` は Git に含まれません
- 各開発者が自分のトークンを設定する必要があります
- Public Token (pk.*) と Secret Token (sk.*) は異なるトークンです

#### 3. 用意されたコマンド
```bash
# プロジェクト全体のセットアップコマンド
flutter pub get && dart run build_runner build --delete-conflicting-outputs

# コードの品質チェック
dart format . && flutter analyze

# テスト実行
flutter test

# Widgetbook の起動
flutter run -t widgetbook/main.dart
```

#### 4. 開発時の実行
```bash
# 開発環境で実行（環境変数付き）
fvm flutter run --dart-define-from-file=dart_defines/dev.env

# QA環境で実行
fvm flutter run --dart-define-from-file=dart_defines/qa.env
```

#### 5. プラットフォームビルド
```bash
# Android
fvm flutter build apk --dart-define-from-file=dart_defines/qa.env

# iOS
fvm flutter build ios --release --no-codesign --dart-define-from-file=dart_defines/qa.env

# Web
fvm flutter build web --dart-define-from-file=dart_defines/qa.env

# Widgetbook (Web)
fvm flutter build web -t widgetbook/main.dart --release
```

### 特定機能のセットアップ

詳細なセットアップ手順については、以下のドキュメントを参照してください：

- [Firebase セットアップ](./docs/firebase_setup.md)
- [プッシュ通知セットアップ](./docs/push_notification_setup.md)
- [ログイン機能セットアップ](./docs/login_setup.md)

## 開発ワークフロー

### 日常の開発サイクル

#### 1. 機能開発の手順
```bash
# 1. 最新のコードを取得
git pull origin main

# 2. 新しいブランチを作成
git checkout -b feature/new-feature

# 3. コードを変更した後、コード生成を実行
dart run build_runner build --delete-conflicting-outputs

# 4. コード品質チェック
dart format . && flutter analyze

# 5. テスト実行
flutter test

# 6. コミットとプッシュ
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
```

#### 2. Provider ・ Command の追加手順

**Provider の作成**
```dart
// 1. Provider ファイルの作成
// lib/features/[feature]/providers/[name]_provider.dart
@riverpod
class MyDataProvider extends _$MyDataProvider {
  @override
  Future<MyData> build() async {
    // データ取得ロジック
  }
}
```

**Command の作成**
```dart
// 2. Command ファイルの作成
// lib/features/[feature]/command/[name]_command.dart
@riverpod
class MyCommand extends _$MyCommand {
  @override
  MyState build() {
    return const MyState();
  }

  Future<void> executeAction() async {
    // コマンドロジック
  }
}
```

**コード生成の実行**
```bash
# Provider/Command 作成後は必須
dart run build_runner build --delete-conflicting-outputs
```

### フォーム管理のパターン

#### シンプルなフォーム
```dart
// カスタムフックの使用
final nameForm = useSingleNameForm();

// UI での使用
TextField(
  controller: nameForm.nameForm.textEditingController,
  onChanged: nameForm.nameForm.dirty,
  decoration: const InputDecoration(
    labelText: 'Name',
    border: OutlineInputBorder(),
  ),
),

// フォームの値を取得
final currentName = nameForm.name();
```

#### 複雑なフォーム（日本人ユーザー想定）
```dart
// 姓名 + カナのフォーム
final userNameForm = useUserNameForm(
  lastName: '佐藤',
  firstName: '太郎',
  kanaLastName: 'サトウ',
  kanaFirstName: 'タロウ',
);

// 結果の取得
final userName = userNameForm.userName();
final fullName = userName.fullName; // '佐藤 太郎'
final kanaFullName = userName.kanaFullName; // 'サトウ タロウ'
```

### ブランチ戦略

このプロジェクトでは、以下のブランチ戦略を採用しています：

- `main`: 本番環境用のコード
- `develop`: 開発環境用のコード（現在は使用していない）
- `feature/*`: 新機能の開発
- `bugfix/*`: バグ修正
- `hotfix/*`: 緊急のバグ修正

新機能の開発やバグ修正は、`main` ブランチから新しいブランチを作成し、完了後に Pull Request を作成してください。

### コーディング規約

- [very_good_analysis](https://pub.dev/packages/very_good_analysis) の Lint ルールに従ってください
- コードフォーマットは `dart format` を使用してください
- 自動生成コードは常に最新の状態を維持してください（`dart run build_runner build --delete-conflicting-outputs`）
- Provider は `@riverpod` アノテーションを使用し、コード生成に依存してください
- 非同期操作は `AsyncValue` でラップし、ローディング・エラー状態を適切に処理してください

### テスト戦略

#### 単体テスト
```dart
// Provider のテスト例
testWidgets('MyWidget test', (WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        home: MyWidget(),
      ),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.text('Expected Text'), findsOneWidget);
});
```

#### Widgetbook コンポーネント
- 新しい UI コンポーネントには Widgetbook のユースケースを追加してください
- 複数のパターン（デフォルト、エラー状態など）を用意してください
- 視覚的な変更には Alchemist を使用した視覚的回帰テストを追加してください

## プロジェクト構造の詳細

### ディレクトリ構成

```
lib/
├── features/                    # 機能別のディレクトリ
│   ├── profile/               # プロフィール機能
│   │   ├── command/          # 状態変更コマンド
│   │   ├── providers/        # データ取得プロバイダー
│   │   ├── hooks/            # フォーム管理フック
│   │   ├── pages/            # UI ページ
│   │   ├── models/           # データモデル
│   │   └── states/           # 状態クラス
│   └── message/               # メッセージ機能（未実装）
├── common/                     # 共通ユーティリティ
│   ├── providers/             # アプリケーション全体のプロバイダー
│   ├── models/                # 共通モデル
│   ├── extensions/            # Dart 拡張
│   └── utils/                 # ユーティリティ関数
├── pages/                      # ルートページ
└── router/                     # ルーティング設定
```

### 依存性注入パターン

このプロジェクトでは、必須の依存性は `app_initializer.dart` で初期化時に注入されます：

```dart
// 依存性注入の例
@Riverpod(keepAlive: true)
BuildConfig buildConfig(Ref ref) => throw UnimplementedError();

// 初期化時に override
overrides.add(
  buildConfigProvider.overrideWithValue(actualBuildConfig),
);
```

このパターンにより、テスト時にはモック、本番時には実際のインスタンスを注入できます。

### 特殊なユーティリティ

#### AsyncValueGroup Extension
複数の `AsyncValue` を組み合わせるためのユーティリティです。group2 から group10 までの関数が用意されています。

#### Form Management System
`flutter_hooks` と `formz` を組み合わせた高度なフォーム管理システム。日本語特有のバリデーション（カタカナチェックなど）も含まれています。

### パフォーマンス最適化

- **SwiftPM 使用**: iOS では CocoaPods の代わりに SwiftPM を使用し、ビルド時間を短縮
- **Code Generation**: ボイラープレートコードを減らし、メンテナンス性を向上
- **AsyncValue Caching**: 適切なキャッシュ戦略でネットワークリクエストを最小化

## トラブルシューティング

### よくある問題と解決策

#### コード生成エラー
```bash
# エラー: build_runner が失敗した場合
解決策:
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### Provider の `UnimplementedError`
```bash
# エラー: Provider が UnimplementedError を投げる
解決策:
# app_initializer.dart で適切に override されているか確認
# テスト時は ProviderScope で適切に override しているか確認
```

#### iOS ビルドエラー
```bash
# SwiftPM 関連のエラー
解決策:
# Xcode で Product > Clean Build Folder
# または
flutter clean
flutter pub get
cd ios && xcodebuild clean
```

### パフォーマンス最適化のヒント

- `AsyncValue` のキャッシュを適切に管理し、不必要なリビルドを避ける
- `keepAlive: true` を使用して、重要な Provider の状態を維持する
- `AsyncValueGroup` を使用して複数の非同期操作を効率的に管理する

## 貢献

1. このリポジトリをフォークします
2. 新しいブランチを作成します（`git checkout -b feature/amazing-feature`）
3. 変更をコミットします（`git commit -m 'Add some amazing feature'`）
4. ブランチをプッシュします（`git push origin feature/amazing-feature`）
5. Pull Request を作成します

## ライセンス

このプロジェクトは [LICENSE] ファイルに記載されているライセンスの下で配布されています。

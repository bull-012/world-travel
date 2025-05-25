# World Travel

このプロジェクトは、Flutter アプリケーションを開発する際のテンプレートプロジェクトです。

## 概要

World Travel は、最新のアーキテクチャパターンと技術を採用した Flutter テンプレートプロジェクトです。このプロジェクトは、新しい Flutter アプリケーションを開発する際の出発点として使用できます。

## アーキテクチャ

このプロジェクトは、以下のアーキテクチャ原則に基づいています：

### CQRS パターン

CQRS（Command Query Responsibility Segregation）パターンを採用しており、読み取り操作（Query）と書き込み操作（Command）を明確に分離しています。

- **Command**: データの変更を担当するコンポーネント
- **Query**: データの読み取りを担当するコンポーネント

このパターンにより、コードの責任が明確に分離され、保守性と拡張性が向上します。

### Riverpod をキャッシュライブラリとして使用

このプロジェクトでは、Riverpod を単なる状態管理ライブラリではなく、キャッシュライブラリとして使用しています。この考え方は React の tanstack query（旧 React Query）に影響を受けています。

主な特徴：
- データの非同期取得とキャッシュ
- キャッシュの自動無効化と再検証
- ローディング状態とエラー状態の管理
- サーバー状態とクライアント状態の明確な分離

## 主要な技術とライブラリ

### ルーティング: GoRouter

型安全なルーティングのために GoRouter を使用しています。GoRouter は以下の機能を提供します：

- 宣言的なルート定義
- ディープリンクのサポート
- パラメータ付きルート
- ネストされたルート
- リダイレクト

### UI コンポーネントドキュメント: Widgetbook

UI コンポーネントのドキュメント化と視覚的なテストのために Widgetbook を使用しています。これにより、以下が可能になります：

- コンポーネントの独立したプレビュー
- 異なるデバイスサイズでのテスト
- 異なるテーマでのテスト
- ユースケースの文書化

### 依存関係管理: Swift Package Manager (SPM)

iOS プラットフォームでは、CocoaPods の代わりに Swift Package Manager (SPM) を使用して依存関係を管理しています。SPM の利点：

- Xcode との統合
- ビルド時間の短縮
- 依存関係の解決の改善
- Apple のエコシステムとの整合性

### 品質管理: Lint CI

コード品質を確保するために、CI パイプラインで以下のチェックを実行しています：

- コードフォーマットのチェック（dart format）
- 静的解析（flutter analyze）
- 自動生成コードの検証
- テストの実行
- 視覚的回帰テスト（VRT）

## セットアップガイド

詳細なセットアップ手順については、以下のドキュメントを参照してください：

- [Firebase セットアップ](./docs/firebase_setup.md)
- [プッシュ通知セットアップ](./docs/push_notification_setup.md)
- [ログイン機能セットアップ](./docs/login_setup.md)

## 開発ガイドライン

### ブランチ戦略

このプロジェクトでは、以下のブランチ戦略を採用しています：

- `main`: 本番環境用のコード
- `develop`: 開発環境用のコード
- `feature/*`: 新機能の開発
- `bugfix/*`: バグ修正
- `hotfix/*`: 緊急のバグ修正

新機能の開発やバグ修正は、`develop` ブランチから新しいブランチを作成し、完了後に Pull Request を作成してください。

### コーディング規約

- [very_good_analysis](https://pub.dev/packages/very_good_analysis) の Lint ルールに従ってください
- コードフォーマットは `dart format` を使用してください
- 自動生成コードは常に最新の状態を維持してください（`dart run build_runner build --delete-conflicting-outputs`）

### テスト

- 新機能には単体テストを追加してください
- UI コンポーネントには Widgetbook のユースケースを追加してください
- 視覚的な変更には Alchemist を使用した視覚的回帰テストを追加してください

## 貢献

1. このリポジトリをフォークします
2. 新しいブランチを作成します（`git checkout -b feature/amazing-feature`）
3. 変更をコミットします（`git commit -m 'Add some amazing feature'`）
4. ブランチをプッシュします（`git push origin feature/amazing-feature`）
5. Pull Request を作成します

## ライセンス

このプロジェクトは [LICENSE] ファイルに記載されているライセンスの下で配布されています。

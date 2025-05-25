# ログイン機能セットアップ

このドキュメントでは、プロジェクトにログイン機能を設定する方法について説明します。

## 前提条件

- Firebase プロジェクトが設定されていること（[Firebase セットアップ](./firebase_setup.md)を参照）
- Firebase Authentication が有効化されていること

## セットアップ手順

### 1. Firebase Authentication の設定

1. [Firebase Console](https://console.firebase.google.com/) にアクセスします
2. プロジェクトを選択し、左側のメニューから「Authentication」を選択します
3. 「Sign-in method」タブをクリックします
4. 使用したい認証方法を有効にします：
   - メール/パスワード
   - 電話番号
   - Google
   - Apple
   - Facebook
   - Twitter
   - GitHub
   - 匿名認証
   など

### 2. Flutter プロジェクトの設定

1. 必要な依存関係が `pubspec.yaml` に追加されていることを確認します：

```yaml
dependencies:
  firebase_core: ^3.12.1
  firebase_auth: ^5.5.1
  google_sign_in: ^6.1.0  # Google認証を使用する場合
```

2. 依存関係をインストールします：

```bash
flutter pub get
```

### 3. 認証プロバイダーの実装

#### Firebase Auth プロバイダー

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_auth.g.dart';

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
}
```

#### ログイン機能の実装

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_command.g.dart';

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.error,
  });

  final bool isLoading;
  final String? error;

  AuthState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

@riverpod
class AuthCommand extends _$AuthCommand {
  @override
  AuthState build() {
    return const AuthState();
  }

  // メール/パスワードでログイン
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _mapFirebaseAuthErrorToMessage(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'ログインに失敗しました。もう一度お試しください。',
      );
    }
  }

  // メール/パスワードでアカウント作成
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _mapFirebaseAuthErrorToMessage(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'アカウント作成に失敗しました。もう一度お試しください。',
      );
    }
  }

  // ログアウト
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final auth = ref.read(firebaseAuthProvider);
      await auth.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'ログアウトに失敗しました。もう一度お試しください。',
      );
    }
  }

  // Firebase Auth エラーコードを日本語メッセージに変換
  String _mapFirebaseAuthErrorToMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'メールアドレスの形式が正しくありません。';
      case 'user-disabled':
        return 'このユーザーアカウントは無効化されています。';
      case 'user-not-found':
        return 'このメールアドレスに対応するユーザーが見つかりません。';
      case 'wrong-password':
        return 'パスワードが間違っています。';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています。';
      case 'operation-not-allowed':
        return 'この操作は許可されていません。';
      case 'weak-password':
        return 'パスワードが弱すぎます。より強力なパスワードを設定してください。';
      default:
        return '認証エラーが発生しました。もう一度お試しください。';
    }
  }
}
```

### 4. ログイン画面の実装

```dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final authCommand = ref.watch(authCommandProvider.notifier);
    final authState = ref.watch(authCommandProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'パスワード',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            if (authState.error != null) ...[
              const SizedBox(height: 16),
              Text(
                authState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            if (authState.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  authCommand.signInWithEmailAndPassword(
                    emailController.text,
                    passwordController.text,
                  );
                },
                child: const Text('ログイン'),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // アカウント作成画面に遷移
              },
              child: const Text('アカウントを作成'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 5. 認証状態に基づくルーティング

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final authState = ref.watch(authStateChangesProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // authState.value が null の場合は未ログイン
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.location == '/login';
      
      // ログインしていない場合、ログイン画面以外へのアクセスはログイン画面にリダイレクト
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      
      // ログイン済みの場合、ログイン画面へのアクセスはホーム画面にリダイレクト
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      
      // それ以外の場合はリダイレクトなし
      return null;
    },
    routes: [
      // ログイン画面
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // ホーム画面（ログイン必須）
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      // その他のルート...
    ],
  );
}
```

## ソーシャルログインの設定

### Google ログイン

1. Firebase Console で Google ログインを有効にします
2. 必要な依存関係を追加します：`google_sign_in: ^6.1.0`
3. 実装例：

```dart
Future<void> signInWithGoogle() async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    // Google サインインフローを開始
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) {
      // ユーザーがサインインをキャンセルした場合
      state = state.copyWith(isLoading: false);
      return;
    }
    
    // 認証情報を取得
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    // Firebase で認証
    final auth = ref.read(firebaseAuthProvider);
    await auth.signInWithCredential(credential);
    
    state = state.copyWith(isLoading: false);
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: 'Google ログインに失敗しました。もう一度お試しください。',
    );
  }
}
```

## トラブルシューティング

- ログインに失敗する場合：
  - Firebase Console で認証方法が正しく有効化されていることを確認します
  - ネットワーク接続を確認します
  - Firebase プロジェクトの設定を確認します

- ソーシャルログインに問題がある場合：
  - 各プラットフォームの開発者コンソールで正しく設定されていることを確認します
  - リダイレクト URL や OAuth スコープが正しく設定されていることを確認します

- リダイレクトループが発生する場合：
  - GoRouter の redirect ロジックを確認します
  - authStateChanges の監視が正しく機能していることを確認します
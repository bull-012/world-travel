# 🚀 世界旅行アプリ 簡単スタートガイド

アプリエンジニア向けに、**30分で開発を始められる**ガイドです。

---

## 📱 このアプリでできること

- **スポット検索**: 観光地、レストラン、ホテルを地図で検索
- **レビュー投稿**: 写真付きでレビューを共有
- **旅行計画**: AIが最適なルートを提案
- **オフライン対応**: 地図とスポット情報をダウンロード
- **課金機能**: Plus/Premiumプランでプレミアム機能

---

## 🏗️ アーキテクチャ（超シンプル版）

```
Flutter App（あなたが作る部分）
    ↓
Firebase（自動で全部やってくれる）
    ├── Authentication（ログイン）
    ├── Firestore（データベース）
    ├── Storage（画像保存）
    └── Functions（サーバー処理）
```

---

## 🎯 30分セットアップ

### Step 1: Firebase プロジェクト作成（5分）

1. [Firebase Console](https://console.firebase.google.com) にアクセス
2. 「プロジェクトを作成」をクリック
3. プロジェクト名: `world-travel-app`
4. Google Analytics: 有効にする
5. 作成完了！

### Step 2: Flutter に Firebase 追加（10分）

```bash
# Firebase CLI をインストール
npm install -g firebase-tools

# Flutter プロジェクトで実行
cd world_travel
flutterfire configure

# 自動で設定ファイルが生成される！
```

### Step 3: 必要なパッケージ追加（5分）

```yaml
# pubspec.yaml に追加
dependencies:
  # Firebase 基本セット
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  
  # 便利ツール
  cached_network_image: ^3.3.0  # 画像キャッシュ
  geolocator: ^10.1.0           # 位置情報
  image_picker: ^1.0.4          # 写真選択
```

### Step 4: 初期化コード追加（5分）

```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // 自動生成されるファイル

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase初期化（これだけ！）
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}
```

### Step 5: 動作確認（5分）

```dart
// ログインのテスト
Future<void> testLogin() async {
  try {
    // 匿名ログイン（一番簡単）
    final user = await FirebaseAuth.instance.signInAnonymously();
    print('ログイン成功: ${user.user?.uid}');
  } catch (e) {
    print('エラー: $e');
  }
}
```

---

## 📝 基本的なコード例

### 1. スポット一覧を取得

```dart
// 超シンプル版
Stream<List<Spot>> getSpots() {
  return FirebaseFirestore.instance
    .collection('spots')
    .where('status', isEqualTo: 'active')
    .snapshots()
    .map((snapshot) => 
      snapshot.docs.map((doc) => Spot.fromJson(doc.data())).toList()
    );
}

// 使い方
StreamBuilder<List<Spot>>(
  stream: getSpots(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final spot = snapshot.data![index];
          return ListTile(
            title: Text(spot.name),
            subtitle: Text(spot.address),
          );
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

### 2. レビュー投稿

```dart
Future<void> postReview({
  required String spotId,
  required double rating,
  required String comment,
  XFile? photo,
}) async {
  // 画像をアップロード（あれば）
  String? photoUrl;
  if (photo != null) {
    final ref = FirebaseStorage.instance
      .ref('reviews/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(File(photo.path));
    photoUrl = await ref.getDownloadURL();
  }
  
  // レビューを保存
  await FirebaseFirestore.instance
    .collection('spots')
    .doc(spotId)
    .collection('reviews')
    .add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'rating': rating,
      'comment': comment,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
}
```

### 3. 位置情報で近くのスポット検索

```dart
Future<List<Spot>> getNearbySpots() async {
  // 現在地を取得
  final position = await Geolocator.getCurrentPosition();
  
  // Firestoreから全スポット取得（簡易版）
  final snapshot = await FirebaseFirestore.instance
    .collection('spots')
    .get();
  
  // 距離でフィルタリング
  final spots = snapshot.docs
    .map((doc) => Spot.fromJson(doc.data()))
    .where((spot) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        spot.latitude,
        spot.longitude,
      );
      return distance < 5000; // 5km以内
    })
    .toList();
  
  // 距離順にソート
  spots.sort((a, b) {
    final distA = Geolocator.distanceBetween(
      position.latitude, position.longitude,
      a.latitude, a.longitude,
    );
    final distB = Geolocator.distanceBetween(
      position.latitude, position.longitude,
      b.latitude, b.longitude,
    );
    return distA.compareTo(distB);
  });
  
  return spots;
}
```

### 4. 画像の最適化（コスト削減）

```dart
// 画像を表示する時は必ずこれを使う
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  
  const OptimizedImage({
    required this.imageUrl,
    this.width,
    this.height,
  });
  
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      memCacheWidth: width?.toInt() ?? 400,  // メモリ上でリサイズ
      memCacheHeight: height?.toInt() ?? 400,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
```

---

## 💰 課金機能の実装（RevenueCat使用）

### 1. RevenueCat設定（10分）

```yaml
# pubspec.yaml
dependencies:
  purchases_flutter: ^6.0.0
```

```dart
// 初期化
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> initPurchases() async {
  await Purchases.setLogLevel(LogLevel.debug);
  
  PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration("YOUR_GOOGLE_API_KEY");
  } else if (Platform.isIOS) {
    configuration = PurchasesConfiguration("YOUR_APPLE_API_KEY");
  }
  
  await Purchases.configure(configuration);
}
```

### 2. サブスク購入

```dart
Future<void> purchasePremium() async {
  try {
    // 商品を取得
    final offerings = await Purchases.getOfferings();
    final premium = offerings.current?.getPackage('premium');
    
    if (premium != null) {
      // 購入処理
      final purchaseResult = await Purchases.purchasePackage(premium);
      
      // Firestoreに保存
      await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
          'subscription': {
            'plan': 'premium',
            'expiresAt': purchaseResult.customerInfo.expirationDate,
          }
        });
    }
  } catch (e) {
    print('購入エラー: $e');
  }
}
```

### 3. 課金状態チェック

```dart
Future<bool> isPremiumUser() async {
  final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(FirebaseAuth.instance.currentUser!.uid)
    .get();
  
  final subscription = doc.data()?['subscription'];
  if (subscription == null) return false;
  
  final expiresAt = subscription['expiresAt'] as Timestamp;
  return expiresAt.toDate().isAfter(DateTime.now());
}

// 使い方
if (await isPremiumUser()) {
  // プレミアム機能を表示
} else {
  // 課金画面を表示
}
```

---

## 🚨 よくあるエラーと解決法

### 1. 「Permission denied」エラー

```dart
// 原因: Firestoreのセキュリティルール
// 解決: 開発中は以下のルールを使用

// Firestore Console > ルール
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      // 開発中のみ！本番では変更必須
      allow read, write: if request.auth != null;
    }
  }
}
```

### 2. 画像アップロードが遅い

```dart
// 解決: アップロード前にリサイズ
import 'package:image/image.dart' as img;

Future<Uint8List> resizeImage(XFile file) async {
  final bytes = await file.readAsBytes();
  final image = img.decodeImage(bytes)!;
  
  // 最大800pxにリサイズ
  final resized = img.copyResize(
    image,
    width: image.width > 800 ? 800 : image.width,
  );
  
  return img.encodeJpg(resized, quality: 85);
}
```

### 3. Firestoreの読み取りが多すぎる

```dart
// 解決: キャッシュを使う
class SpotCache {
  static final _cache = <String, List<Spot>>{};
  static final _cacheTime = <String, DateTime>{};
  
  static Future<List<Spot>> getSpots(String city) async {
    final key = 'spots_$city';
    
    // キャッシュチェック（1時間有効）
    if (_cache.containsKey(key)) {
      final cachedTime = _cacheTime[key]!;
      if (DateTime.now().difference(cachedTime).inHours < 1) {
        return _cache[key]!;
      }
    }
    
    // Firestoreから取得
    final snapshot = await FirebaseFirestore.instance
      .collection('spots')
      .where('city', isEqualTo: city)
      .get();
    
    final spots = snapshot.docs
      .map((doc) => Spot.fromJson(doc.data()))
      .toList();
    
    // キャッシュに保存
    _cache[key] = spots;
    _cacheTime[key] = DateTime.now();
    
    return spots;
  }
}
```

---

## 📚 もっと詳しく知りたい場合

### データ構造の詳細
→ [API仕様書](./api-specification.md) を参照

### コスト最適化
→ [コスト＆収益分析](./cost-and-revenue-analysis.md) を参照

### バックエンド実装
→ [Firebase Functions実装ガイド](./firebase-functions-implementation.md) を参照

---

## ✅ チェックリスト

開発を始める前の確認：

- [ ] Firebase プロジェクトを作成した
- [ ] Flutter に Firebase を追加した
- [ ] エミュレータで動作確認した
- [ ] テストデータを追加した
- [ ] 画像アップロードをテストした

これで開発準備完了です！🎉
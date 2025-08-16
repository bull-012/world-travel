# Firestore エンタープライズセキュリティルール仕様書 v2.0

## 概要
このドキュメントは、世界旅行アプリケーションのエンタープライズレベル Firestore セキュリティルールを定義します。
多層セキュリティ、RBAC（Role-Based Access Control）、データプライバシー、AI機能対応を包含します。

## エンタープライズセキュリティ原則

1. **ゼロトラスト**: デフォルトですべてを拒否、必要最小限のアクセスのみ許可
2. **多層防御**: 複数のセキュリティ層による包括的保護
3. **動的認可**: コンテキストベースの動的権限制御
4. **データ分類**: データの機密性レベルに応じたアクセス制御
5. **監査ログ**: すべてのアクセス試行の記録と監視
6. **プライバシー保護**: GDPR/CCPA準拠のデータ保護
7. **リアルタイム脅威検出**: 異常アクセスパターンの即座検出

## エンタープライズセキュリティルール実装

### firestore.rules v2.0
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ========================================
    // エンタープライズ共通関数
    // ========================================
    
    // 基本認証チェック
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // 所有権確認
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // ロールベースアクセス制御（RBAC）
    function hasRole(role) {
      return isAuthenticated() && 
        request.auth.token.roles != null &&
        role in request.auth.token.roles;
    }
    
    function isAdmin() {
      return hasRole('admin') || hasRole('super_admin');
    }
    
    function isModerator() {
      return hasRole('moderator') || hasRole('admin') || hasRole('super_admin');
    }
    
    function isVerifiedUser() {
      return isAuthenticated() && 
        request.auth.token.verification_level != null &&
        request.auth.token.verification_level != 'none';
    }
    
    function isPremiumUser() {
      return isAuthenticated() && 
        request.auth.token.subscription != null &&
        request.auth.token.subscription in ['premium', 'pro'];
    }
    
    // 権限チェック関数
    function hasPermission(permission) {
      return isAuthenticated() && 
        request.auth.token.permissions != null &&
        permission in request.auth.token.permissions;
    }
    
    // データクラス分類による保護
    function canAccessDataClass(dataClass) {
      return dataClass == 'public' ||
        (dataClass == 'internal' && isAuthenticated()) ||
        (dataClass == 'restricted' && (isModerator() || hasPermission('access_restricted'))) ||
        (dataClass == 'confidential' && (isAdmin() || hasPermission('access_confidential')));
    }
    
    // 地理的アクセス制御
    function isInAllowedRegion() {
      return request.auth.token.region != null &&
        request.auth.token.region in ['JP', 'US', 'EU', 'APAC'];
    }
    
    // 時間ベースアクセス制御
    function isInBusinessHours() {
      return request.time.hours() >= 6 && request.time.hours() <= 22;
    }
    
    // 異常検出関数
    function isValidRequestRate() {
      // 実際の実装ではCloud Functionsと連携
      return true; // プレースホルダー
    }
    
    function isSuspiciousActivity() {
      // 実際の実装ではML異常検出と連携
      return false; // プレースホルダー
    }
    
    // バリデーション関数群
    function isValidEmail(email) {
      return email.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$');
    }
    
    function isValidLength(text, min, max) {
      return text.size() >= min && text.size() <= max;
    }
    
    function isNotFutureDate(timestamp) {
      return timestamp <= request.time;
    }
    
    function hasRequiredFields(fields) {
      return request.resource.data.keys().hasAll(fields);
    }
    
    function isValidGeohash(geohash) {
      return geohash.size() >= 4 && geohash.size() <= 12 &&
        geohash.matches('^[0-9bcdefghjkmnpqrstuvwxyz]+$');
    }
    
    function isValidCoordinates(lat, lng) {
      return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    }
    
    // プライバシー保護関数
    function isDataMinimized(data) {
      // 最小限のデータのみ含まれているかチェック
      return data.keys().size() <= 20; // 例: 最大20フィールド
    }
    
    function hasValidConsent(consentType) {
      return request.auth.token.consents != null &&
        consentType in request.auth.token.consents &&
        request.auth.token.consents[consentType] == true;
    }
    
    // 高度なセキュリティチェック
    function passesSecurityChecks() {
      return isAuthenticated() &&
        isInAllowedRegion() &&
        isValidRequestRate() &&
        !isSuspiciousActivity();
    }
    
    // 有効なメールアドレスかチェック
    function isValidEmail(email) {
      return email.matches('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$');
    }
    
    // 文字列の長さをチェック
    function isValidLength(text, min, max) {
      return text.size() >= min && text.size() <= max;
    }
    
    // 将来の日付でないことをチェック
    function isNotFutureDate(timestamp) {
      return timestamp <= request.time;
    }
    
    // 必須フィールドが存在するかチェック
    function hasRequiredFields(fields) {
      return request.resource.data.keys().hasAll(fields);
    }
    
    // ========================================
    // Users コレクション - エンタープライズ保護
    // ========================================
    match /users/{userId} {
      // 読み取り: プライバシー設定とデータ分類による制御
      allow read: if passesSecurityChecks() && (
        // 自分のプロファイル
        isOwner(userId) ||
        // 公開プロファイル
        (resource.data.preferences.privacy.profileVisibility == 'public' &&
         canAccessDataClass('public')) ||
        // フレンド限定（フレンド関係の確認）
        (resource.data.preferences.privacy.profileVisibility == 'friends' &&
         isFriend(request.auth.uid, userId)) ||
        // 管理者・モデレーター
        (isModerator() && hasPermission('view_user_profiles')) ||
        // プレミアム機能でのアクセス
        (isPremiumUser() && hasPermission('premium_user_search'))
      );
      
      // 作成: 厳格な初期データ検証
      allow create: if passesSecurityChecks() &&
        isOwner(userId) && 
        hasRequiredFields([
          'profile', 'stats', 'preferences', 'subscription', 
          'algorithms', 'security', 'createdAt'
        ]) &&
        // プロファイル必須フィールド検証
        hasRequiredProFileFields(request.resource.data.profile) &&
        // セキュリティ設定初期化
        isValidSecuritySettings(request.resource.data.security) &&
        // プライバシー設定初期化
        isValidPrivacySettings(request.resource.data.preferences.privacy) &&
        // データ最小化原則
        isDataMinimized(request.resource.data) &&
        // 同意確認
        hasValidConsent('data_processing');
      
      // 更新: 細分化されたフィールドレベル制御
      allow update: if passesSecurityChecks() && isOwner(userId) &&
        // 読み取り専用フィールドの保護
        !canModifyRestrictedFields() &&
        // フィールド別バリデーション
        validateFieldUpdates() &&
        // レート制限（頻繁な更新の防止）
        !exceededUpdateRate() &&
        // センシティブデータ変更時の追加認証
        (!isUpdatingSensitiveData() || hasRecentAuthentication());
      
      // 削除: GDPR準拠の削除権（忘れられる権利）
      allow delete: if passesSecurityChecks() && (
        (isOwner(userId) && hasValidConsent('data_deletion')) ||
        (isAdmin() && hasPermission('delete_user_data')) ||
        // 自動削除（非アクティブアカウント等）
        (hasRole('system') && isValidSystemDeletion())
      );
      
      // プロファイル検証関数
      function hasRequiredProFileFields(profile) {
        return profile.keys().hasAll(['lastName', 'firstName', 'verification']) &&
          isValidLength(profile.lastName, 1, 50) &&
          isValidLength(profile.firstName, 1, 50) &&
          profile.verification.keys().hasAll(['isVerified', 'verificationLevel']);
      }
      
      // セキュリティ設定検証
      function isValidSecuritySettings(security) {
        return security.keys().hasAll(['twoFactorEnabled', 'loginHistory']) &&
          security.loginHistory.size() <= 10; // 最大10件のログイン履歴
      }
      
      // プライバシー設定検証
      function isValidPrivacySettings(privacy) {
        return privacy.keys().hasAll(['profileVisibility', 'allowMessages']) &&
          privacy.profileVisibility in ['public', 'friends', 'private'] &&
          privacy.allowMessages in ['everyone', 'friends', 'none'];
      }
      
      // 制限フィールド変更チェック
      function canModifyRestrictedFields() {
        let restrictedFields = [
          'stats', 'algorithms.personalityVector', 'security.loginHistory',
          'createdAt', 'system'
        ];
        return request.resource.data.diff(resource.data).affectedKeys()
          .hasAny(restrictedFields);
      }
      
      // フィールド更新バリデーション
      function validateFieldUpdates() {
        let changes = request.resource.data.diff(resource.data).affectedKeys();
        
        return (
          // プロファイル更新検証
          (!changes.hasAny(['profile']) || isValidProfileUpdate()) &&
          // 設定更新検証
          (!changes.hasAny(['preferences']) || isValidPreferencesUpdate()) &&
          // セキュリティ設定更新検証
          (!changes.hasAny(['security']) || isValidSecurityUpdate())
        );
      }
      
      // 更新レート制限チェック
      function exceededUpdateRate() {
        // 実際の実装ではCloud Functionsと連携
        return false; // プレースホルダー
      }
      
      // センシティブデータ更新チェック
      function isUpdatingSensitiveData() {
        let sensitiveFields = [
          'security.twoFactorEnabled', 'preferences.privacy',
          'profile.verification', 'subscription'
        ];
        return request.resource.data.diff(resource.data).affectedKeys()
          .hasAny(sensitiveFields);
      }
      
      // 最近の認証確認
      function hasRecentAuthentication() {
        return request.auth.token.auth_time != null &&
          request.time.toMillis() - request.auth.token.auth_time * 1000 < 300000; // 5分以内
      }
      
      // ========================================
      // Users サブコレクション
      // ========================================
      
      // お気に入りスポット
      match /spots/{spotId} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId) &&
          hasRequiredFields(['spotId', 'addedAt']) &&
          request.resource.data.spotId == spotId;
      }
      
      // いいねしたスポット
      match /likedSpots/{spotId} {
        allow read: if isOwner(userId);
        allow write: if isOwner(userId);
      }
    }
    
    // ========================================
    // Spots コレクション
    // ========================================
    match /spots/{spotId} {
      // 読み取り: 誰でも可能（公開スポット）
      allow read: if resource.data.status == 'active' ||
        (isAuthenticated() && resource.data.createdBy == request.auth.uid) ||
        isModerator();
      
      // 作成: 認証済みユーザーのみ
      allow create: if isAuthenticated() &&
        hasRequiredFields(['name', 'address', 'location', 'category', 'status', 'createdBy']) &&
        request.resource.data.createdBy == request.auth.uid &&
        request.resource.data.status == 'pending' && // 新規作成時は承認待ち
        isValidLength(request.resource.data.name, 2, 100) &&
        isValidLength(request.resource.data.address, 5, 200) &&
        request.resource.data.category.size() > 0 &&
        request.resource.data.category.size() <= 5;
      
      // 更新: 作成者またはモデレーターのみ
      allow update: if 
        (isOwner(resource.data.createdBy) && 
         // 作成者は特定フィールドのみ更新可能
         !request.resource.data.diff(resource.data).affectedKeys()
           .hasAny(['createdBy', 'rating', 'reviewCount', 'likeCount'])) ||
        (isModerator() && 
         // モデレーターはステータス変更可能
         request.resource.data.status in ['active', 'inactive', 'rejected']);
      
      // 削除: 作成者または管理者のみ
      allow delete: if isOwner(resource.data.createdBy) || isAdmin();
      
      // ========================================
      // Reviews サブコレクション
      // ========================================
      match /reviews/{reviewId} {
        // 読み取り: 誰でも可能
        allow read: if true;
        
        // 作成: 認証済みユーザーのみ、1スポットにつき1レビューまで
        allow create: if isAuthenticated() &&
          hasRequiredFields(['userId', 'userName', 'rating', 'comment', 'createdAt']) &&
          request.resource.data.userId == request.auth.uid &&
          request.resource.data.rating >= 1 &&
          request.resource.data.rating <= 5 &&
          isValidLength(request.resource.data.comment, 10, 1000) &&
          isNotFutureDate(request.resource.data.createdAt);
        
        // 更新: 本人のみ、作成から24時間以内
        allow update: if isOwner(resource.data.userId) &&
          resource.data.createdAt + duration.value(24, 'h') > request.time &&
          !request.resource.data.diff(resource.data).affectedKeys()
            .hasAny(['userId', 'createdAt']) &&
          request.resource.data.rating >= 1 &&
          request.resource.data.rating <= 5 &&
          isValidLength(request.resource.data.comment, 10, 1000);
        
        // 削除: 本人またはモデレーターのみ
        allow delete: if isOwner(resource.data.userId) || isModerator();
      }
    }
    
    // ========================================
    // Travel Plans コレクション
    // ========================================
    match /travelPlans/{planId} {
      // 読み取り: 公開設定に基づく
      allow read: if 
        resource.data.visibility == 'public' ||
        (isAuthenticated() && 
         (resource.data.userId == request.auth.uid ||
          request.auth.uid in resource.data.participants.members ||
          (resource.data.visibility == 'friends' && 
           isFriend(resource.data.userId, request.auth.uid))));
      
      // 作成: 認証済みユーザーのみ
      allow create: if isAuthenticated() &&
        hasRequiredFields(['userId', 'title', 'destination', 'schedule', 'status', 'visibility']) &&
        request.resource.data.userId == request.auth.uid &&
        request.resource.data.status in ['draft', 'confirmed'] &&
        request.resource.data.visibility in ['private', 'friends', 'public'] &&
        isValidLength(request.resource.data.title, 1, 100) &&
        request.resource.data.schedule.startDate <= request.resource.data.schedule.endDate;
      
      // 更新: 作成者または参加者のみ
      allow update: if isAuthenticated() &&
        (resource.data.userId == request.auth.uid ||
         request.auth.uid in resource.data.participants.members) &&
        !request.resource.data.diff(resource.data).affectedKeys()
          .hasAny(['userId', 'createdAt']);
      
      // 削除: 作成者のみ
      allow delete: if isOwner(resource.data.userId);
    }
    
    // ========================================
    // Checklists コレクション
    // ========================================
    match /checklists/{checklistId} {
      // 読み取り: 作成者のみ
      allow read: if isOwner(resource.data.userId);
      
      // 作成: 認証済みユーザーのみ
      allow create: if isAuthenticated() &&
        hasRequiredFields(['userId', 'title', 'items']) &&
        request.resource.data.userId == request.auth.uid &&
        isValidLength(request.resource.data.title, 1, 100) &&
        request.resource.data.items.size() > 0;
      
      // 更新: 作成者のみ
      allow update: if isOwner(resource.data.userId) &&
        !request.resource.data.diff(resource.data).affectedKeys()
          .hasAny(['userId', 'createdAt']);
      
      // 削除: 作成者のみ
      allow delete: if isOwner(resource.data.userId);
    }
    
    // ========================================
    // Achievements コレクション
    // ========================================
    match /achievements/{achievementId} {
      // 読み取り: 本人のみ
      allow read: if isAuthenticated() &&
        resource.data.userId == request.auth.uid;
      
      // 作成・更新: Cloud Functions経由のみ（直接の書き込み不可）
      allow write: if false;
    }
    
    // ========================================
    // Bookings コレクション
    // ========================================
    match /bookings/{bookingId} {
      // 読み取り: 作成者のみ
      allow read: if isOwner(resource.data.userId);
      
      // 作成: 認証済みユーザーのみ
      allow create: if isAuthenticated() &&
        hasRequiredFields(['userId', 'type', 'status', 'details']) &&
        request.resource.data.userId == request.auth.uid &&
        request.resource.data.type in ['flight', 'hotel', 'activity', 'transportation'] &&
        request.resource.data.status in ['pending', 'confirmed'];
      
      // 更新: 作成者のみ、ステータス変更のみ
      allow update: if isOwner(resource.data.userId) &&
        request.resource.data.diff(resource.data).affectedKeys()
          .hasOnly(['status', 'updatedAt']) &&
        request.resource.data.status in ['confirmed', 'cancelled', 'completed'];
      
      // 削除: 作成者のみ
      allow delete: if isOwner(resource.data.userId);
    }
    
    // ========================================
    // 統計・集計コレクション（読み取り専用）
    // ========================================
    match /statistics/{document=**} {
      allow read: if true;
      allow write: if false; // Cloud Functions経由でのみ更新
    }
    
    // ========================================
    // システムコレクション
    // ========================================
    match /system/{document=**} {
      allow read: if isAdmin();
      allow write: if isAdmin();
    }
    
    // ========================================
    // 友達関係の確認関数
    // ========================================
    function isFriend(userId1, userId2) {
      return exists(/databases/$(database)/documents/users/$(userId1)/friends/$(userId2));
    }
  }
}
```

## セキュリティルールのテスト

### テストコード例
```javascript
// security-rules.test.js
const testing = require('@firebase/rules-unit-testing');
const fs = require('fs');

const projectId = 'world-travel-test';
const firebaseJson = {
  rules: fs.readFileSync('firestore.rules', 'utf8')
};

describe('Firestore Security Rules', () => {
  let testEnv;
  let authenticatedContext;
  let unauthenticatedContext;
  let adminContext;

  beforeAll(async () => {
    testEnv = await testing.initializeTestEnvironment({
      projectId,
      firestore: firebaseJson
    });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
    
    // 認証済みユーザーのコンテキスト
    authenticatedContext = testEnv.authenticatedContext('user123', {
      email: 'user@example.com'
    });
    
    // 未認証ユーザーのコンテキスト
    unauthenticatedContext = testEnv.unauthenticatedContext();
    
    // 管理者のコンテキスト
    adminContext = testEnv.authenticatedContext('admin123', {
      email: 'admin@example.com',
      admin: true
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  describe('Users Collection', () => {
    test('認証済みユーザーは他のユーザー情報を読み取れる', async () => {
      const userDoc = authenticatedContext.firestore()
        .collection('users')
        .doc('other-user');
      
      await testing.assertSucceeds(userDoc.get());
    });

    test('未認証ユーザーはユーザー情報を読み取れない', async () => {
      const userDoc = unauthenticatedContext.firestore()
        .collection('users')
        .doc('any-user');
      
      await testing.assertFails(userDoc.get());
    });

    test('ユーザーは自分のプロファイルを更新できる', async () => {
      const userId = 'user123';
      const userDoc = authenticatedContext.firestore()
        .collection('users')
        .doc(userId);
      
      // 初期データを設定
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc(userId).set({
          profile: {
            lastName: 'Doe',
            firstName: 'John'
          },
          stats: {
            totalReviews: 0
          },
          preferences: {},
          createdAt: new Date()
        });
      });
      
      // プロファイル更新
      await testing.assertSucceeds(
        userDoc.update({
          'profile.bio': 'Updated bio',
          updatedAt: new Date()
        })
      );
    });

    test('ユーザーはstatsフィールドを直接更新できない', async () => {
      const userId = 'user123';
      const userDoc = authenticatedContext.firestore()
        .collection('users')
        .doc(userId);
      
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('users').doc(userId).set({
          profile: {
            lastName: 'Doe',
            firstName: 'John'
          },
          stats: {
            totalReviews: 0
          },
          preferences: {},
          createdAt: new Date()
        });
      });
      
      // stats更新を試みる
      await testing.assertFails(
        userDoc.update({
          'stats.totalReviews': 100
        })
      );
    });
  });

  describe('Spots Collection', () => {
    test('誰でもアクティブなスポットを読み取れる', async () => {
      const spotId = 'spot123';
      
      // テストデータ設定
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('spots').doc(spotId).set({
          name: 'Test Spot',
          status: 'active',
          createdBy: 'someone'
        });
      });
      
      const spotDoc = unauthenticatedContext.firestore()
        .collection('spots')
        .doc(spotId);
      
      await testing.assertSucceeds(spotDoc.get());
    });

    test('未承認スポットは作成者のみ読み取れる', async () => {
      const spotId = 'spot123';
      const creatorId = 'user123';
      
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('spots').doc(spotId).set({
          name: 'Test Spot',
          status: 'pending',
          createdBy: creatorId
        });
      });
      
      // 作成者は読み取れる
      const creatorDoc = authenticatedContext.firestore()
        .collection('spots')
        .doc(spotId);
      await testing.assertSucceeds(creatorDoc.get());
      
      // 他のユーザーは読み取れない
      const otherContext = testEnv.authenticatedContext('other-user');
      const otherDoc = otherContext.firestore()
        .collection('spots')
        .doc(spotId);
      await testing.assertFails(otherDoc.get());
    });

    test('認証済みユーザーは新しいスポットを作成できる', async () => {
      const spotDoc = authenticatedContext.firestore()
        .collection('spots')
        .doc();
      
      await testing.assertSucceeds(
        spotDoc.set({
          name: 'New Spot',
          address: '123 Main St',
          location: { latitude: 35.6762, longitude: 139.6503 },
          category: ['restaurant'],
          status: 'pending',
          createdBy: 'user123',
          rating: 0,
          reviewCount: 0,
          likeCount: 0,
          createdAt: new Date()
        })
      );
    });

    test('スポット作成時にstatusをactiveに設定できない', async () => {
      const spotDoc = authenticatedContext.firestore()
        .collection('spots')
        .doc();
      
      await testing.assertFails(
        spotDoc.set({
          name: 'New Spot',
          address: '123 Main St',
          location: { latitude: 35.6762, longitude: 139.6503 },
          category: ['restaurant'],
          status: 'active', // これは許可されない
          createdBy: 'user123',
          createdAt: new Date()
        })
      );
    });
  });

  describe('Reviews Subcollection', () => {
    const spotId = 'spot123';
    
    beforeEach(async () => {
      // スポットを作成
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('spots').doc(spotId).set({
          name: 'Test Spot',
          status: 'active',
          createdBy: 'someone'
        });
      });
    });

    test('誰でもレビューを読み取れる', async () => {
      const reviewDoc = unauthenticatedContext.firestore()
        .collection('spots').doc(spotId)
        .collection('reviews').doc('review123');
      
      await testing.assertSucceeds(reviewDoc.get());
    });

    test('認証済みユーザーはレビューを投稿できる', async () => {
      const reviewDoc = authenticatedContext.firestore()
        .collection('spots').doc(spotId)
        .collection('reviews').doc();
      
      await testing.assertSucceeds(
        reviewDoc.set({
          userId: 'user123',
          userName: 'John Doe',
          rating: 4.5,
          comment: 'Great place to visit! Highly recommended.',
          createdAt: new Date()
        })
      );
    });

    test('レビューの評価は1-5の範囲でなければならない', async () => {
      const reviewDoc = authenticatedContext.firestore()
        .collection('spots').doc(spotId)
        .collection('reviews').doc();
      
      // 評価が範囲外
      await testing.assertFails(
        reviewDoc.set({
          userId: 'user123',
          userName: 'John Doe',
          rating: 6, // 無効な評価
          comment: 'Great place to visit!',
          createdAt: new Date()
        })
      );
    });

    test('レビューは作成から24時間以内のみ編集可能', async () => {
      const reviewId = 'review123';
      const userId = 'user123';
      const now = new Date();
      const oldDate = new Date(now.getTime() - 25 * 60 * 60 * 1000); // 25時間前
      
      // 古いレビューを作成
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore()
          .collection('spots').doc(spotId)
          .collection('reviews').doc(reviewId)
          .set({
            userId,
            userName: 'John Doe',
            rating: 3,
            comment: 'Original comment',
            createdAt: oldDate
          });
      });
      
      const reviewDoc = authenticatedContext.firestore()
        .collection('spots').doc(spotId)
        .collection('reviews').doc(reviewId);
      
      // 24時間後の編集は失敗
      await testing.assertFails(
        reviewDoc.update({
          comment: 'Updated comment',
          rating: 5
        })
      );
    });
  });

  describe('Travel Plans Collection', () => {
    test('公開プランは誰でも読み取れる', async () => {
      const planId = 'plan123';
      
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('travelPlans').doc(planId).set({
          userId: 'someone',
          title: 'Public Plan',
          visibility: 'public',
          destination: { country: 'Japan' },
          schedule: {
            startDate: new Date(),
            endDate: new Date()
          },
          status: 'confirmed',
          participants: { members: [] }
        });
      });
      
      const planDoc = unauthenticatedContext.firestore()
        .collection('travelPlans')
        .doc(planId);
      
      await testing.assertSucceeds(planDoc.get());
    });

    test('プライベートプランは作成者のみ読み取れる', async () => {
      const planId = 'plan123';
      const creatorId = 'user123';
      
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('travelPlans').doc(planId).set({
          userId: creatorId,
          title: 'Private Plan',
          visibility: 'private',
          destination: { country: 'Japan' },
          schedule: {
            startDate: new Date(),
            endDate: new Date()
          },
          status: 'confirmed',
          participants: { members: [] }
        });
      });
      
      // 作成者は読み取れる
      const creatorDoc = authenticatedContext.firestore()
        .collection('travelPlans')
        .doc(planId);
      await testing.assertSucceeds(creatorDoc.get());
      
      // 他のユーザーは読み取れない
      const otherContext = testEnv.authenticatedContext('other-user');
      const otherDoc = otherContext.firestore()
        .collection('travelPlans')
        .doc(planId);
      await testing.assertFails(otherDoc.get());
    });

    test('参加者は旅行計画を更新できる', async () => {
      const planId = 'plan123';
      const participantId = 'user123';
      
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().collection('travelPlans').doc(planId).set({
          userId: 'creator',
          title: 'Group Plan',
          visibility: 'private',
          destination: { country: 'Japan' },
          schedule: {
            startDate: new Date(),
            endDate: new Date()
          },
          status: 'confirmed',
          participants: { 
            members: [participantId] // user123が参加者
          },
          createdAt: new Date()
        });
      });
      
      const planDoc = authenticatedContext.firestore()
        .collection('travelPlans')
        .doc(planId);
      
      await testing.assertSucceeds(
        planDoc.update({
          title: 'Updated Group Plan',
          updatedAt: new Date()
        })
      );
    });
  });
});
```

## デプロイとバージョン管理

### デプロイコマンド
```bash
# ルールのデプロイ
firebase deploy --only firestore:rules

# エミュレータでのテスト
firebase emulators:start --only firestore

# ルールのテスト実行
npm test -- security-rules.test.js
```

### バージョン管理のベストプラクティス

1. **Git でのバージョン管理**
```bash
firestore.rules
firestore.indexes.json
test/security-rules.test.js
```

2. **環境別ルール管理**
```bash
firestore.rules.dev     # 開発環境用
firestore.rules.staging # ステージング環境用
firestore.rules.prod    # 本番環境用
```

3. **CI/CD パイプライン統合**
```yaml
# .github/workflows/firestore-rules.yml
name: Firestore Rules Test and Deploy

on:
  push:
    paths:
      - 'firestore.rules'
      - 'test/security-rules.test.js'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
      - run: npm install
      - run: npm test -- security-rules.test.js
  
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: w9jds/firebase-action@master
        with:
          args: deploy --only firestore:rules
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## 監視とアラート

### セキュリティルール評価の監視
```javascript
// Cloud Functions での監視
exports.monitorSecurityRules = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const monitoring = require('@google-cloud/monitoring');
    const client = new monitoring.MetricServiceClient();
    
    // セキュリティルール拒否率を取得
    const [timeSeries] = await client.listTimeSeries({
      name: client.projectPath(projectId),
      filter: 'metric.type="firestore.googleapis.com/rules/evaluation_count"',
      interval: {
        endTime: {
          seconds: Date.now() / 1000,
        },
        startTime: {
          seconds: Date.now() / 1000 - 3600,
        },
      },
    });
    
    // 異常な拒否率を検出
    const deniedCount = timeSeries
      .filter(ts => ts.metric.labels.result === 'DENY')
      .reduce((sum, ts) => sum + ts.points[0].value.int64Value, 0);
    
    const totalCount = timeSeries
      .reduce((sum, ts) => sum + ts.points[0].value.int64Value, 0);
    
    const denialRate = deniedCount / totalCount;
    
    if (denialRate > 0.1) { // 10%以上の拒否率
      // アラート送信
      await sendAlert({
        title: 'High Security Rule Denial Rate',
        message: `Denial rate: ${(denialRate * 100).toFixed(2)}%`,
        severity: 'WARNING'
      });
    }
  });
```

## トラブルシューティング

### よくある問題と解決策

1. **"Missing or insufficient permissions" エラー**
   - 認証トークンの有効性を確認
   - セキュリティルールのロジックを再確認
   - Firebase コンソールでルールシミュレータを使用

2. **パフォーマンスの問題**
   - 複雑な条件を単純化
   - exists() 呼び出しを最小限に
   - インデックスの適切な設定

3. **ルールの競合**
   - より具体的なパスを先に定義
   - ワイルドカードの使用を慎重に

## ベストプラクティス

1. **セキュリティファースト**
   - デフォルトで拒否、必要な権限のみ許可
   - クライアント側の検証に依存しない

2. **パフォーマンス最適化**
   - ルールの評価順序を考慮
   - 共通条件を関数化

3. **メンテナンス性**
   - コメントで意図を明確に
   - 定期的なルールレビュー
   - テストカバレッジの維持

4. **監査とコンプライアンス**
   - アクセスログの記録
   - 定期的なセキュリティ監査
   - GDPR等の規制への準拠
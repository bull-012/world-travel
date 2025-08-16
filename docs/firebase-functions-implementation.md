# Firebase Functions エンタープライズ実装ガイド v2.0

## 概要
このドキュメントは、世界旅行アプリのエンタープライズレベル Firebase Functions 実装戦略を定義します。
マイクロサービスアーキテクチャ、AI/ML統合、リアルタイム機能、高度なセキュリティを包含します。

## アーキテクチャ設計

### 1. エンタープライズプロジェクト構造
```
functions/
├── src/
│   ├── index.ts                           # メインエントリーポイント
│   ├── config/
│   │   ├── firebase.ts                    # Firebase初期化
│   │   ├── redis.ts                       # Redis接続設定
│   │   ├── algolia.ts                     # Algolia設定
│   │   ├── ai-services.ts                 # AI/MLサービス設定
│   │   ├── constants.ts                   # 定数定義
│   │   └── environment.ts                 # 環境設定
│   ├── middleware/
│   │   ├── auth.ts                        # 認証・認可ミドルウェア
│   │   ├── validation.ts                  # 高度なバリデーション
│   │   ├── cors.ts                        # CORS設定
│   │   ├── rate-limit.ts                  # 分散レート制限
│   │   ├── security.ts                    # セキュリティヘッダー
│   │   ├── monitoring.ts                  # パフォーマンス監視
│   │   ├── cache.ts                       # キャッシュミドルウェア
│   │   └── i18n.ts                        # 国際化対応
│   ├── controllers/
│   │   ├── auth/
│   │   │   ├── auth.controller.ts         # 認証コントローラー
│   │   │   ├── mfa.controller.ts          # 多要素認証
│   │   │   └── social.controller.ts       # ソーシャルログイン
│   │   ├── users/
│   │   │   ├── users.controller.ts        # ユーザー管理
│   │   │   ├── profile.controller.ts      # プロファイル管理
│   │   │   └── verification.controller.ts # ユーザー認証
│   │   ├── geo/
│   │   │   ├── geo-search.controller.ts   # 地理検索
│   │   │   ├── geohash.controller.ts      # Geohash処理
│   │   │   └── routing.controller.ts      # ルート検索
│   │   ├── spots/
│   │   │   ├── spots.controller.ts        # スポット管理
│   │   │   ├── reviews.controller.ts      # レビュー管理
│   │   │   └── media.controller.ts        # メディア管理
│   │   ├── social/
│   │   │   ├── social.controller.ts       # ソーシャル機能
│   │   │   ├── feed.controller.ts         # フィード管理
│   │   │   └── messaging.controller.ts    # メッセージング
│   │   ├── ai/
│   │   │   ├── recommendations.controller.ts # AI推薦
│   │   │   ├── vision.controller.ts       # 画像AI
│   │   │   ├── nlp.controller.ts          # 自然言語処理
│   │   │   └── analytics.controller.ts    # AI分析
│   │   ├── realtime/
│   │   │   ├── websocket.controller.ts    # WebSocket処理
│   │   │   ├── collaboration.controller.ts # 協調編集
│   │   │   └── tracking.controller.ts     # ライブトラッキング
│   │   └── admin/
│   │       ├── admin.controller.ts        # 管理機能
│   │       ├── moderation.controller.ts   # コンテンツ審査
│   │       └── analytics.controller.ts    # 分析ダッシュボード
│   ├── services/
│   │   ├── core/
│   │   │   ├── auth.service.ts            # 認証サービス
│   │   │   ├── user.service.ts            # ユーザーサービス
│   │   │   ├── cache.service.ts           # キャッシュサービス
│   │   │   └── notification.service.ts    # 通知サービス
│   │   ├── search/
│   │   │   ├── algolia.service.ts         # Algolia統合
│   │   │   ├── geohash.service.ts         # Geohash検索
│   │   │   └── semantic-search.service.ts # セマンティック検索
│   │   ├── ai/
│   │   │   ├── recommendation.service.ts  # 推薦エンジン
│   │   │   ├── vision.service.ts          # 画像AI
│   │   │   ├── nlp.service.ts             # NLP
│   │   │   └── ml-pipeline.service.ts     # ML パイプライン
│   │   ├── media/
│   │   │   ├── image-optimization.service.ts # 画像最適化
│   │   │   ├── video-processing.service.ts   # 動画処理
│   │   │   └── cdn.service.ts                # CDN管理
│   │   ├── social/
│   │   │   ├── feed.service.ts            # フィードサービス
│   │   │   ├── relationship.service.ts    # 関係性管理
│   │   │   └── messaging.service.ts       # メッセージング
│   │   ├── realtime/
│   │   │   ├── websocket.service.ts       # WebSocket管理
│   │   │   ├── pubsub.service.ts          # Pub/Sub
│   │   │   └── collaboration.service.ts   # 協調編集
│   │   ├── external/
│   │   │   ├── maps.service.ts            # 地図API
│   │   │   ├── weather.service.ts         # 天気API
│   │   │   ├── translation.service.ts     # 翻訳API
│   │   │   └── payment.service.ts         # 決済API
│   │   └── analytics/
│   │       ├── tracking.service.ts        # トラッキング
│   │       ├── metrics.service.ts         # メトリクス
│   │       └── reporting.service.ts       # レポート生成
│   ├── models/
│   │   ├── core/
│   │   │   ├── user.model.ts              # ユーザーモデル
│   │   │   ├── spot.model.ts              # スポットモデル
│   │   │   ├── review.model.ts            # レビューモデル
│   │   │   └── plan.model.ts              # 旅行計画モデル
│   │   ├── social/
│   │   │   ├── connection.model.ts        # 接続関係モデル
│   │   │   ├── feed.model.ts              # フィードモデル
│   │   │   └── message.model.ts           # メッセージモデル
│   │   ├── ai/
│   │   │   ├── recommendation.model.ts    # 推薦モデル
│   │   │   ├── analysis.model.ts          # 分析モデル
│   │   │   └── ml-feature.model.ts        # ML特徴量モデル
│   │   └── shared/
│   │       ├── base.model.ts              # 基底モデル
│   │       ├── multi-language.model.ts    # 多言語モデル
│   │       └── geo.model.ts               # 地理モデル
│   ├── utils/
│   │   ├── validation/
│   │   │   ├── joi-schemas.ts             # Joi バリデーションスキーマ
│   │   │   ├── geospatial.ts              # 地理空間バリデーション
│   │   │   └── security.ts                # セキュリティバリデーション
│   │   ├── helpers/
│   │   │   ├── crypto.ts                  # 暗号化ヘルパー
│   │   │   ├── geohash.ts                 # Geohash ヘルパー
│   │   │   ├── datetime.ts                # 日時ヘルパー
│   │   │   └── formatting.ts              # フォーマットヘルパー
│   │   ├── errors/
│   │   │   ├── custom-errors.ts           # カスタムエラー
│   │   │   ├── error-handler.ts           # エラーハンドラー
│   │   │   └── error-reporter.ts          # エラーレポーター
│   │   └── security/
│   │       ├── encryption.ts              # 暗号化
│   │       ├── sanitization.ts            # サニタイゼーション
│   │       └── audit.ts                   # 監査ログ
│   ├── triggers/
│   │   ├── firestore/
│   │   │   ├── user.triggers.ts           # ユーザートリガー
│   │   │   ├── spot.triggers.ts           # スポットトリガー
│   │   │   ├── review.triggers.ts         # レビュートリガー
│   │   │   └── social.triggers.ts         # ソーシャルトリガー
│   │   ├── auth/
│   │   │   ├── user-creation.triggers.ts  # ユーザー作成トリガー
│   │   │   └── user-deletion.triggers.ts  # ユーザー削除トリガー
│   │   ├── storage/
│   │   │   ├── image-upload.triggers.ts   # 画像アップロードトリガー
│   │   │   └── media-processing.triggers.ts # メディア処理トリガー
│   │   └── pubsub/
│   │       ├── ai-processing.triggers.ts  # AI処理トリガー
│   │       ├── batch-jobs.triggers.ts     # バッチジョブトリガー
│   │       └── notification.triggers.ts   # 通知トリガー
│   ├── scheduled/
│   │   ├── ai-training.ts                 # AI モデル訓練
│   │   ├── cache-warming.ts               # キャッシュウォーミング
│   │   ├── data-cleanup.ts                # データクリーンアップ
│   │   ├── analytics-aggregation.ts       # 分析データ集計
│   │   └── backup-management.ts           # バックアップ管理
│   ├── websockets/
│   │   ├── connection-manager.ts          # 接続管理
│   │   ├── message-router.ts              # メッセージルーティング
│   │   ├── room-manager.ts                # ルーム管理
│   │   └── event-handlers.ts              # イベントハンドラー
│   └── scripts/
│       ├── deploy.ts                      # デプロイスクリプト
│       ├── migration.ts                   # マイグレーションスクリプト
│       ├── seed-data.ts                   # シードデータ
│       └── performance-test.ts            # パフォーマンステスト
├── package.json
├── tsconfig.json
├── jest.config.js
├── .env.example
├── .env.development
├── .env.staging
└── .env.production
```

### 2. エンタープライズ package.json
```json
{
  "name": "world-travel-functions-enterprise",
  "version": "2.0.0",
  "description": "エンタープライズレベル世界旅行アプリ Firebase Functions",
  "scripts": {
    "build": "tsc && npm run build:schemas",
    "build:schemas": "node scripts/generate-schemas.js",
    "serve": "npm run build && firebase emulators:start --only functions,firestore,pubsub,storage",
    "serve:production": "npm run build && NODE_ENV=production firebase emulators:start",
    "shell": "npm run build && firebase functions:shell",
    "start": "npm run shell",
    "deploy": "npm run test && npm run build && firebase deploy --only functions",
    "deploy:dev": "firebase use dev && npm run deploy",
    "deploy:staging": "firebase use staging && npm run deploy",
    "deploy:production": "firebase use production && npm run deploy",
    "logs": "firebase functions:log",
    "logs:tail": "firebase functions:log --only=api",
    "test": "jest --passWithNoTests",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:integration": "jest --config jest.integration.config.js",
    "test:load": "artillery run test/load/load-test.yml",
    "lint": "eslint src --ext .ts",
    "lint:fix": "eslint src --ext .ts --fix",
    "format": "prettier --write src/**/*.ts",
    "validate": "npm run lint && npm run test",
    "clean": "rimraf lib",
    "migrate": "node scripts/migrate.js",
    "seed": "node scripts/seed-data.js",
    "backup": "node scripts/backup.js",
    "monitor": "node scripts/monitor.js"
  },
  "engines": {
    "node": "20"
  },
  "main": "lib/index.js",
  "dependencies": {
    // Core Framework
    "express": "^4.18.2",
    "firebase-admin": "^12.0.0",
    "firebase-functions": "^4.8.0",
    
    // Web Framework
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4",
    "express-rate-limit": "^7.1.5",
    "express-slow-down": "^2.0.1",
    
    // Validation & Security
    "joi": "^17.11.0",
    "express-validator": "^7.0.1",
    "sanitize-html": "^2.11.0",
    "crypto-js": "^4.2.0",
    "jsonwebtoken": "^9.0.2",
    "speakeasy": "^2.0.0",
    
    // Data Processing
    "busboy": "^1.6.0",
    "sharp": "^0.33.1",
    "ffmpeg-static": "^5.2.0",
    "pdf-parse": "^1.1.1",
    
    // Database & Cache
    "redis": "^4.6.11",
    "ioredis": "^5.3.2",
    
    // Search & Analytics
    "algoliasearch": "^4.22.1",
    "ngeohash": "^0.6.3",
    
    // AI/ML Services
    "@google-cloud/aiplatform": "^3.13.0",
    "@google-cloud/vision": "^4.0.2",
    "@google-cloud/translate": "^8.0.2",
    "@google-cloud/natural-language": "^6.0.2",
    "@tensorflow/tfjs-node": "^4.15.0",
    
    // External APIs
    "axios": "^1.6.2",
    "node-fetch": "^3.3.2",
    "ws": "^8.14.2",
    "socket.io": "^4.7.4",
    
    // Utilities
    "dayjs": "^1.11.10",
    "lodash": "^4.17.21",
    "uuid": "^9.0.1",
    "mime-types": "^2.1.35",
    "validator": "^13.11.0",
    
    // Monitoring & Logging
    "@google-cloud/logging": "^11.0.0",
    "@google-cloud/monitoring": "^4.0.0",
    "@google-cloud/trace-agent": "^7.1.2",
    "@google-cloud/profiler": "^6.0.2",
    
    // Task Queue
    "@google-cloud/tasks": "^4.0.2",
    "@google-cloud/pubsub": "^4.0.7",
    
    // Internationalization
    "i18next": "^23.7.6",
    "i18next-fs-backend": "^2.3.1"
  },
  "devDependencies": {
    // TypeScript
    "@types/express": "^4.17.21",
    "@types/cors": "^2.8.17",
    "@types/compression": "^1.7.5",
    "@types/busboy": "^1.5.3",
    "@types/lodash": "^4.14.202",
    "@types/uuid": "^9.0.7",
    "@types/mime-types": "^2.1.4",
    "@types/validator": "^13.11.7",
    "@types/ws": "^8.5.10",
    "@types/crypto-js": "^4.2.1",
    "@types/jsonwebtoken": "^9.0.5",
    "@types/speakeasy": "^2.0.10",
    
    // Testing
    "@types/jest": "^29.5.8",
    "@types/supertest": "^2.0.16",
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "firebase-functions-test": "^3.1.0",
    "artillery": "^2.0.3",
    
    // Code Quality
    "@typescript-eslint/eslint-plugin": "^6.14.0",
    "@typescript-eslint/parser": "^6.14.0",
    "eslint": "^8.55.0",
    "eslint-config-prettier": "^9.1.0",
    "eslint-plugin-import": "^2.29.0",
    "prettier": "^3.1.0",
    
    // Build Tools
    "typescript": "^5.3.3",
    "ts-node": "^10.9.1",
    "nodemon": "^3.0.2",
    "rimraf": "^5.0.5",
    
    // Utilities
    "dotenv": "^16.3.1"
  },
  "peerDependencies": {
    "firebase": "^10.7.1"
  }
}
```
```

## 実装例

### 1. エントリーポイント (index.ts)
```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import express from 'express';
import cors from 'cors';

// Firebase Admin初期化
admin.initializeApp();

// Express app初期化
const app = express();

// ミドルウェア
import { corsOptions } from './config/cors';
import { authMiddleware } from './middleware/auth';
import { rateLimiter } from './middleware/rateLimit';

app.use(cors(corsOptions));
app.use(express.json());
app.use(rateLimiter);

// ルート
import authRoutes from './routes/auth.routes';
import userRoutes from './routes/user.routes';
import spotRoutes from './routes/spot.routes';
import reviewRoutes from './routes/review.routes';
import planRoutes from './routes/plan.routes';
import bookingRoutes from './routes/booking.routes';

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/users', authMiddleware, userRoutes);
app.use('/api/spots', spotRoutes);
app.use('/api/reviews', authMiddleware, reviewRoutes);
app.use('/api/travel-plans', authMiddleware, planRoutes);
app.use('/api/bookings', authMiddleware, bookingRoutes);

// エラーハンドリング
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: {
      code: err.code || 'INTERNAL_SERVER_ERROR',
      message: err.message || 'Something went wrong',
      details: err.details
    },
    timestamp: new Date().toISOString(),
    path: req.path
  });
});

// HTTP Function
export const api = functions
  .region('asia-northeast1')
  .runWith({
    timeoutSeconds: 60,
    memory: '1GB'
  })
  .https.onRequest(app);

// Firestore Triggers
export { userTriggers } from './triggers/user.triggers';
export { reviewTriggers } from './triggers/review.triggers';
export { achievementTriggers } from './triggers/achievement.triggers';

// Scheduled Functions
export { dailyBackup } from './scheduled/backup';
export { weeklyReports } from './scheduled/reports';
```

### 2. 認証ミドルウェア (middleware/auth.ts)
```typescript
import { Request, Response, NextFunction } from 'express';
import * as admin from 'firebase-admin';

export interface AuthRequest extends Request {
  user?: admin.auth.DecodedIdToken;
}

export const authMiddleware = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: {
          code: 'AUTH001',
          message: 'Authorization header missing or invalid'
        }
      });
    }

    const token = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(token);
    
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(401).json({
      error: {
        code: 'AUTH002',
        message: 'Invalid or expired token'
      }
    });
  }
};

// オプショナル認証（認証なしでもアクセス可能）
export const optionalAuth = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split('Bearer ')[1];
      const decodedToken = await admin.auth().verifyIdToken(token);
      req.user = decodedToken;
    }
    
    next();
  } catch (error) {
    // エラーが発生しても続行
    next();
  }
};
```

### 3. スポットコントローラー (controllers/spots.controller.ts)
```typescript
import { Request, Response } from 'express';
import { validationResult } from 'express-validator';
import * as admin from 'firebase-admin';
import { SpotService } from '../services/spot.service';
import { StorageService } from '../services/storage.service';
import { AuthRequest } from '../middleware/auth';

const db = admin.firestore();
const spotService = new SpotService();
const storageService = new StorageService();

export class SpotsController {
  // スポット一覧取得
  async getSpots(req: Request, res: Response) {
    try {
      const {
        category,
        country,
        city,
        lat,
        lng,
        radius = 10,
        sort = 'rating',
        limit = 20,
        offset = 0
      } = req.query;

      let query = db.collection('spots')
        .where('status', '==', 'active');

      // カテゴリフィルター
      if (category) {
        query = query.where('category', 'array-contains', category);
      }

      // 国・都市フィルター
      if (country) {
        query = query.where('metadata.country', '==', country);
      }
      if (city) {
        query = query.where('metadata.city', '==', city);
      }

      // ソート
      const sortField = this.getSortField(sort as string);
      query = query.orderBy(sortField, 'desc');

      // ページネーション
      query = query.limit(Number(limit)).offset(Number(offset));

      const snapshot = await query.get();
      const spots = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      // 位置情報による絞り込み（クライアントサイド）
      let filteredSpots = spots;
      if (lat && lng) {
        filteredSpots = spotService.filterByDistance(
          spots,
          Number(lat),
          Number(lng),
          Number(radius)
        );
      }

      // 総数を取得
      const totalSnapshot = await db.collection('spots')
        .where('status', '==', 'active')
        .count()
        .get();
      const total = totalSnapshot.data().count;

      res.json({
        spots: filteredSpots,
        total,
        hasMore: Number(offset) + Number(limit) < total
      });
    } catch (error) {
      console.error('Error fetching spots:', error);
      res.status(500).json({
        error: {
          code: 'SRV001',
          message: 'Failed to fetch spots'
        }
      });
    }
  }

  // スポット詳細取得
  async getSpotById(req: Request, res: Response) {
    try {
      const { spotId } = req.params;

      const spotDoc = await db.collection('spots').doc(spotId).get();
      
      if (!spotDoc.exists) {
        return res.status(404).json({
          error: {
            code: 'RES001',
            message: 'Spot not found'
          }
        });
      }

      const spot = {
        id: spotDoc.id,
        ...spotDoc.data()
      };

      // レビューを取得
      const reviewsSnapshot = await db.collection('spots')
        .doc(spotId)
        .collection('reviews')
        .orderBy('createdAt', 'desc')
        .limit(10)
        .get();

      const reviews = reviewsSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      // 近隣スポットを取得
      const nearby = await spotService.getNearbySpots(
        spot.location.latitude,
        spot.location.longitude,
        5 // 5km以内
      );

      res.json({
        spot,
        reviews,
        nearby: nearby.filter(s => s.id !== spotId).slice(0, 5)
      });
    } catch (error) {
      console.error('Error fetching spot:', error);
      res.status(500).json({
        error: {
          code: 'SRV001',
          message: 'Failed to fetch spot details'
        }
      });
    }
  }

  // スポット作成
  async createSpot(req: AuthRequest, res: Response) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          error: {
            code: 'VAL001',
            message: 'Validation failed',
            details: errors.array()
          }
        });
      }

      const { name, address, location, category, details, media } = req.body;
      const userId = req.user!.uid;

      // 画像をアップロード
      let photoUrls: string[] = [];
      if (media?.photos) {
        photoUrls = await Promise.all(
          media.photos.map((photo: string) => 
            storageService.uploadImage(photo, `spots/${Date.now()}`)
          )
        );
      }

      // Geocoding（必要に応じて）
      const geoPoint = new admin.firestore.GeoPoint(
        location.lat,
        location.lng
      );

      const spotData = {
        name,
        address,
        location: geoPoint,
        category,
        rating: 0,
        reviewCount: 0,
        likeCount: 0,
        media: {
          photos: photoUrls,
          videos: [],
          thumbnail: photoUrls[0] || ''
        },
        details,
        metadata: {
          country: await spotService.getCountryFromCoords(location.lat, location.lng),
          city: await spotService.getCityFromCoords(location.lat, location.lng),
          region: '',
          tags: []
        },
        status: 'pending', // 管理者承認待ち
        createdBy: userId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      };

      const spotRef = await db.collection('spots').add(spotData);

      res.status(201).json({
        spot: {
          id: spotRef.id,
          ...spotData
        }
      });
    } catch (error) {
      console.error('Error creating spot:', error);
      res.status(500).json({
        error: {
          code: 'SRV001',
          message: 'Failed to create spot'
        }
      });
    }
  }

  // スポットにいいね
  async likeSpot(req: AuthRequest, res: Response) {
    try {
      const { spotId } = req.params;
      const userId = req.user!.uid;

      const result = await db.runTransaction(async (transaction) => {
        const spotRef = db.collection('spots').doc(spotId);
        const userSpotRef = db.collection('users').doc(userId)
          .collection('likedSpots').doc(spotId);

        const spotDoc = await transaction.get(spotRef);
        if (!spotDoc.exists) {
          throw new Error('Spot not found');
        }

        const userSpotDoc = await transaction.get(userSpotRef);
        const isLiked = userSpotDoc.exists;

        if (isLiked) {
          // いいねを取り消し
          transaction.delete(userSpotRef);
          transaction.update(spotRef, {
            likeCount: admin.firestore.FieldValue.increment(-1)
          });
        } else {
          // いいねを追加
          transaction.set(userSpotRef, {
            likedAt: admin.firestore.FieldValue.serverTimestamp()
          });
          transaction.update(spotRef, {
            likeCount: admin.firestore.FieldValue.increment(1)
          });
        }

        return {
          liked: !isLiked,
          likeCount: spotDoc.data()!.likeCount + (isLiked ? -1 : 1)
        };
      });

      res.json(result);
    } catch (error) {
      console.error('Error liking spot:', error);
      res.status(500).json({
        error: {
          code: 'SRV001',
          message: 'Failed to like spot'
        }
      });
    }
  }

  private getSortField(sort: string): string {
    switch (sort) {
      case 'rating':
        return 'rating';
      case 'likes':
        return 'likeCount';
      case 'reviews':
        return 'reviewCount';
      default:
        return 'createdAt';
    }
  }
}
```

### 4. レビュートリガー (triggers/review.triggers.ts)
```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

// レビュー作成時のトリガー
export const onReviewCreated = functions
  .region('asia-northeast1')
  .firestore
  .document('spots/{spotId}/reviews/{reviewId}')
  .onCreate(async (snapshot, context) => {
    const { spotId } = context.params;
    const review = snapshot.data();

    try {
      // スポットの評価を更新
      await updateSpotRating(spotId);

      // ユーザーの統計を更新
      await updateUserStats(review.userId, 'reviews');

      // 実績チェック
      await checkAchievements(review.userId, 'review');

      // 通知送信（スポット作成者へ）
      const spotDoc = await db.collection('spots').doc(spotId).get();
      if (spotDoc.exists) {
        const spot = spotDoc.data()!;
        if (spot.createdBy !== review.userId) {
          await sendNotification(
            spot.createdBy,
            'New Review',
            `${review.userName} reviewed your spot "${spot.name}"`
          );
        }
      }
    } catch (error) {
      console.error('Error in review trigger:', error);
    }
  });

// レビュー削除時のトリガー
export const onReviewDeleted = functions
  .region('asia-northeast1')
  .firestore
  .document('spots/{spotId}/reviews/{reviewId}')
  .onDelete(async (snapshot, context) => {
    const { spotId } = context.params;
    const review = snapshot.data();

    try {
      // スポットの評価を再計算
      await updateSpotRating(spotId);

      // ユーザーの統計を更新
      await db.collection('users').doc(review.userId).update({
        'stats.totalReviews': admin.firestore.FieldValue.increment(-1)
      });
    } catch (error) {
      console.error('Error in review delete trigger:', error);
    }
  });

// スポットの評価を更新
async function updateSpotRating(spotId: string) {
  const reviewsSnapshot = await db.collection('spots')
    .doc(spotId)
    .collection('reviews')
    .get();

  if (reviewsSnapshot.empty) {
    await db.collection('spots').doc(spotId).update({
      rating: 0,
      reviewCount: 0
    });
    return;
  }

  const ratings = reviewsSnapshot.docs.map(doc => doc.data().rating);
  const averageRating = ratings.reduce((sum, rating) => sum + rating, 0) / ratings.length;

  await db.collection('spots').doc(spotId).update({
    rating: Math.round(averageRating * 10) / 10,
    reviewCount: ratings.length
  });
}

// ユーザー統計を更新
async function updateUserStats(userId: string, type: string) {
  const updates: any = {};
  
  switch (type) {
    case 'reviews':
      updates['stats.totalReviews'] = admin.firestore.FieldValue.increment(1);
      break;
    case 'spots':
      updates['stats.spotsVisited'] = admin.firestore.FieldValue.increment(1);
      break;
  }

  await db.collection('users').doc(userId).update(updates);
}

// 実績チェック
async function checkAchievements(userId: string, action: string) {
  const userDoc = await db.collection('users').doc(userId).get();
  if (!userDoc.exists) return;

  const userStats = userDoc.data()!.stats;

  // レビュー数による実績
  if (userStats.totalReviews === 1) {
    await unlockAchievement(userId, 'first_review');
  } else if (userStats.totalReviews === 10) {
    await unlockAchievement(userId, 'reviewer_10');
  } else if (userStats.totalReviews === 50) {
    await unlockAchievement(userId, 'reviewer_50');
  }
}

// 実績解除
async function unlockAchievement(userId: string, achievementId: string) {
  const achievementRef = db.collection('achievements')
    .doc(`${userId}_${achievementId}`);

  const achievementDoc = await achievementRef.get();
  if (!achievementDoc.exists) {
    await achievementRef.set({
      userId,
      achievementId,
      isUnlocked: true,
      unlockedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // 通知送信
    await sendNotification(
      userId,
      'Achievement Unlocked!',
      `You've unlocked a new achievement!`
    );
  }
}

// 通知送信
async function sendNotification(userId: string, title: string, body: string) {
  // FCMトークンを取得
  const userDoc = await db.collection('users').doc(userId).get();
  if (!userDoc.exists) return;

  const fcmToken = userDoc.data()!.fcmToken;
  if (!fcmToken) return;

  // FCM経由で通知送信
  await admin.messaging().send({
    token: fcmToken,
    notification: {
      title,
      body
    },
    data: {
      type: 'achievement',
      timestamp: new Date().toISOString()
    }
  });
}
```

### 5. バリデーション (utils/validators.ts)
```typescript
import { body, query, param } from 'express-validator';

export const spotValidators = {
  create: [
    body('name')
      .notEmpty().withMessage('Name is required')
      .isLength({ min: 2, max: 100 }).withMessage('Name must be 2-100 characters'),
    body('address')
      .notEmpty().withMessage('Address is required'),
    body('location.lat')
      .isFloat({ min: -90, max: 90 }).withMessage('Invalid latitude'),
    body('location.lng')
      .isFloat({ min: -180, max: 180 }).withMessage('Invalid longitude'),
    body('category')
      .isArray({ min: 1 }).withMessage('At least one category is required')
      .custom((categories) => {
        const validCategories = ['restaurant', 'cafe', 'tourism', 'shopping', 'entertainment', 'hotel', 'other'];
        return categories.every((cat: string) => validCategories.includes(cat));
      }).withMessage('Invalid category')
  ],

  list: [
    query('limit')
      .optional()
      .isInt({ min: 1, max: 100 }).withMessage('Limit must be 1-100'),
    query('offset')
      .optional()
      .isInt({ min: 0 }).withMessage('Offset must be >= 0'),
    query('radius')
      .optional()
      .isFloat({ min: 0.1, max: 50 }).withMessage('Radius must be 0.1-50 km')
  ]
};

export const reviewValidators = {
  create: [
    body('rating')
      .isFloat({ min: 1, max: 5 }).withMessage('Rating must be 1-5'),
    body('comment')
      .notEmpty().withMessage('Comment is required')
      .isLength({ min: 10, max: 1000 }).withMessage('Comment must be 10-1000 characters')
  ]
};

export const userValidators = {
  register: [
    body('email')
      .isEmail().withMessage('Invalid email'),
    body('password')
      .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).withMessage('Password must contain uppercase, lowercase and number'),
    body('profile.lastName')
      .notEmpty().withMessage('Last name is required'),
    body('profile.firstName')
      .notEmpty().withMessage('First name is required')
  ]
};
```

### 6. エラーハンドリング (utils/errors.ts)
```typescript
export class AppError extends Error {
  constructor(
    public code: string,
    public message: string,
    public status: number = 500,
    public details?: any
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class ValidationError extends AppError {
  constructor(message: string, details?: any) {
    super('VAL001', message, 400, details);
  }
}

export class AuthError extends AppError {
  constructor(message: string, code: string = 'AUTH001') {
    super(code, message, 401);
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super('RES001', `${resource} not found`, 404);
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super('RES003', message, 409);
  }
}

export class RateLimitError extends AppError {
  constructor() {
    super('RATE001', 'Rate limit exceeded', 429);
  }
}
```

## デプロイと運用

### デプロイコマンド
```bash
# 開発環境
firebase use dev
firebase deploy --only functions

# 本番環境
firebase use production
firebase deploy --only functions

# 特定の関数のみデプロイ
firebase deploy --only functions:api,functions:userTriggers
```

### 環境変数設定
```bash
# 環境変数を設定
firebase functions:config:set \
  smtp.host="smtp.gmail.com" \
  smtp.port="587" \
  smtp.user="your-email@gmail.com" \
  smtp.password="your-password" \
  api.key="your-api-key"

# 環境変数を確認
firebase functions:config:get

# ローカルでの環境変数使用
firebase functions:config:get > .runtimeconfig.json
```

### モニタリング
```typescript
// パフォーマンス監視
import { performance } from 'perf_hooks';

export const measurePerformance = (name: string) => {
  return (target: any, propertyKey: string, descriptor: PropertyDescriptor) => {
    const originalMethod = descriptor.value;

    descriptor.value = async function(...args: any[]) {
      const start = performance.now();
      try {
        const result = await originalMethod.apply(this, args);
        const duration = performance.now() - start;
        
        // Cloud Monitoringにメトリクスを送信
        await sendMetrics({
          name: `${name}.${propertyKey}`,
          duration,
          timestamp: new Date()
        });
        
        return result;
      } catch (error) {
        const duration = performance.now() - start;
        
        // エラーメトリクスを送信
        await sendMetrics({
          name: `${name}.${propertyKey}.error`,
          duration,
          error: true,
          timestamp: new Date()
        });
        
        throw error;
      }
    };

    return descriptor;
  };
};
```

## テスト

### ユニットテスト例
```typescript
import { Test } from '@nestjs/testing';
import { SpotsController } from '../controllers/spots.controller';
import { SpotService } from '../services/spot.service';

describe('SpotsController', () => {
  let controller: SpotsController;
  let service: SpotService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      controllers: [SpotsController],
      providers: [
        {
          provide: SpotService,
          useValue: {
            getSpots: jest.fn(),
            getSpotById: jest.fn(),
            createSpot: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<SpotsController>(SpotsController);
    service = module.get<SpotService>(SpotService);
  });

  describe('getSpots', () => {
    it('should return an array of spots', async () => {
      const result = {
        spots: [],
        total: 0,
        hasMore: false
      };
      
      jest.spyOn(service, 'getSpots').mockResolvedValue(result);

      expect(await controller.getSpots({} as any, {} as any)).toBe(result);
    });
  });
});
```
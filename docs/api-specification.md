# 世界旅行アプリ エンタープライズ API 仕様書 v2.0

## 概要
このドキュメントは、世界旅行アプリケーションのエンタープライズレベル Firebase Architecture と API 仕様を定義します。
Geohash地理検索、Algolia統合、画像最適化、多言語対応、Redisキャッシング、リアルタイム機能、ソーシャル機能、AI分析・レコメンデーション基盤を包含します。

## アーキテクチャ概要
- **データベース**: Firestore (メイン) + Redis (キャッシュ層)
- **検索**: Algolia + Firestore Geohash
- **画像処理**: Cloud Storage + CDN + 最適化パイプライン
- **リアルタイム**: WebSocket/SSE + Firestore リアルタイムリスナー
- **AI/ML**: Vertex AI + カスタムレコメンデーションエンジン
- **国際化**: 多言語スキーマ + 地域別最適化

## 目次
1. [Firestore データベース構造](#firestore-データベース構造)
2. [キャッシング・パフォーマンス戦略](#キャッシングパフォーマンス戦略)
3. [Geohash地理検索システム](#geohash地理検索システム)
4. [Algolia統合検索](#algolia統合検索)
5. [画像最適化パイプライン](#画像最適化パイプライン)
6. [多言語対応アーキテクチャ](#多言語対応アーキテクチャ)
7. [リアルタイム機能](#リアルタイム機能)
8. [ソーシャル機能](#ソーシャル機能)
9. [AI分析・レコメンデーション](#ai分析レコメンデーション)
10. [Firebase Functions API エンドポイント](#firebase-functions-api-エンドポイント)
11. [認証・セキュリティ](#認証セキュリティ)
12. [エラーハンドリング](#エラーハンドリング)
13. [パフォーマンス・スケーラビリティ](#パフォーマンススケーラビリティ)

---

## Firestore データベース構造

### 1. users コレクション
ユーザープロファイル情報とソーシャル機能を包含

```typescript
interface User {
  uid: string;                    // Firebase Auth UID
  profile: {
    lastName: string;
    firstName: string;
    kanaLastName: string;
    kanaFirstName: string;
    displayName: string;
    photoURL?: string;
    bio?: string;
    birthDate?: Timestamp;
    gender?: 'male' | 'female' | 'other' | 'private';
    location?: {
      country: string;
      city: string;
      coordinates?: GeoPoint;
    };
    website?: string;
    socialLinks: {
      instagram?: string;
      twitter?: string;
      facebook?: string;
    };
    verification: {
      isVerified: boolean;
      verificationLevel: 'none' | 'email' | 'phone' | 'identity' | 'premium';
      verifiedAt?: Timestamp;
    };
  };
  stats: {
    countriesVisited: number;
    spotsVisited: number;
    totalReviews: number;
    totalLikes: number;
    totalFollowers: number;
    totalFollowing: number;
    totalPosts: number;
    engagementScore: number;      // AI算出エンゲージメントスコア
    travelScore: number;          // 旅行経験スコア
    helpfulnessScore: number;     // レビューの有用性スコア
    joinedAt: Timestamp;
    lastActiveAt: Timestamp;
    streakDays: number;           // 連続ログイン日数
  };
  preferences: {
    language: string;
    currency: string;
    timezone: string;
    units: 'metric' | 'imperial';
    privacy: {
      profileVisibility: 'public' | 'friends' | 'private';
      showLocation: boolean;
      showStats: boolean;
      allowMessages: 'everyone' | 'friends' | 'none';
      allowRecommendations: boolean;
    };
    notifications: {
      email: boolean;
      push: boolean;
      marketing: boolean;
      social: boolean;            // フォロー、いいね等
      recommendations: boolean;   // AIレコメンデーション
      travelReminders: boolean;   // 旅行リマインダー
    };
    travel: {
      preferredBudget: 'budget' | 'mid' | 'luxury';
      travelStyle: 'adventure' | 'culture' | 'relaxation' | 'foodie' | 'nature';
      mobility: 'walking' | 'cycling' | 'driving' | 'public_transport';
      groupSize: 'solo' | 'couple' | 'family' | 'group';
      interests: string[];        // カテゴリー配列
    };
  };
  subscription: {
    plan: 'free' | 'premium' | 'pro';
    status: 'active' | 'cancelled' | 'expired';
    expiresAt?: Timestamp;
    features: string[];           // 利用可能機能リスト
  };
  algorithms: {
    contentPreferences: {         // AIコンテンツ推薦用
      categories: { [key: string]: number };  // カテゴリー重み
      locations: { [key: string]: number };   // 地域重み
      priceRanges: { [key: string]: number }; // 価格帯重み
    };
    personalityVector: number[];  // AI用パーソナリティベクトル
    seasonalPreferences: {        // 季節性嗜好
      spring: number;
      summer: number;
      autumn: number;
      winter: number;
    };
    lastRecommendationUpdate: Timestamp;
  };
  security: {
    twoFactorEnabled: boolean;
    lastPasswordChange?: Timestamp;
    suspiciousActivity: boolean;
    loginHistory: {
      ip: string;
      userAgent: string;
      timestamp: Timestamp;
    }[];
  };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 2. spots コレクション
地理検索・多言語対応・AI分析機能を持つ観光スポット情報

```typescript
interface Spot {
  id: string;
  
  // 基本情報（多言語対応）
  name: MultiLanguageString;
  description: MultiLanguageString;
  shortDescription: MultiLanguageString;  // 検索結果用短縮版
  
  // 地理情報
  location: {
    coordinates: GeoPoint;        // Firestore GeoPoint
    geohash: string;             // Geohash for efficient geo queries
    geohashPrefixes: string[];   // 複数精度のGeohashプレフィックス
    address: MultiLanguageString;
    postalCode?: string;
    plus_code?: string;          // Google Plus Code
    what3words?: string;         // What3Words address
  };
  
  // カテゴリ・分類
  category: {
    primary: string;             // メインカテゴリ
    secondary: string[];         // サブカテゴリ
    tags: string[];             // タグ（多言語対応のため言語コード付き）
    accessibility: string[];     // アクセシビリティ情報
    amenities: string[];        // 設備・サービス
  };
  
  // 評価・統計
  metrics: {
    rating: number;             // 平均評価
    reviewCount: number;
    likeCount: number;
    viewCount: number;          // 閲覧数
    bookmarkCount: number;      // ブックマーク数
    checkInCount: number;       // チェックイン数
    qualityScore: number;       // AI算出品質スコア
    popularityScore: number;    // 人気度スコア
    trendingScore: number;      // トレンドスコア（時間減衰）
    seasonalityScore: {         // 季節性スコア
      spring: number;
      summer: number;
      autumn: number;
      winter: number;
    };
  };
  
  // メディア（最適化対応）
  media: {
    photos: {
      original: string;         // オリジナル画像URL
      optimized: {              // 最適化画像
        thumbnail: string;      // 150x150
        small: string;          // 400x300
        medium: string;         // 800x600
        large: string;          // 1200x900
        webp?: string;          // WebP形式
      };
      alt: MultiLanguageString;  // 画像説明（多言語）
      credit?: string;          // 撮影者クレジット
      uploadedBy: string;       // アップロードユーザー
      uploadedAt: Timestamp;
    }[];
    videos: {
      url: string;
      thumbnail: string;
      duration: number;
      format: string;
      uploadedBy: string;
      uploadedAt: Timestamp;
    }[];
    virtual_tour?: {            // バーチャルツアー
      type: '360' | 'street_view' | '3d_model';
      url: string;
      preview: string;
    };
  };
  
  // 詳細情報
  details: {
    hours: {
      [key: string]: {          // 曜日別
        open: string;
        close: string;
        is24h: boolean;
        isClosed: boolean;
      };
    };
    pricing: {
      currency: string;
      range: 'free' | 'budget' | 'mid' | 'luxury';
      adult?: number;
      child?: number;
      senior?: number;
      group?: number;
      notes: MultiLanguageString;
    };
    contact: {
      phone?: string;
      email?: string;
      website?: string;
      socialMedia: {
        facebook?: string;
        instagram?: string;
        twitter?: string;
      };
    };
    practical: {
      duration?: number;        // 推奨滞在時間（分）
      bestTimeToVisit: string[]; // 最適訪問時期
      crowdLevel: 'low' | 'medium' | 'high' | 'varies';
      reservationRequired: boolean;
      languages: string[];      // 対応言語
      paymentMethods: string[]; // 支払い方法
    };
  };
  
  // 地域・分類情報
  location_meta: {
    country: string;
    countryCode: string;        // ISO 3166-1 alpha-2
    state?: string;
    city: string;
    district?: string;
    neighborhood?: string;
    timezone: string;
    climate: string;            // 気候帯
    continent: string;
  };
  
  // AI・レコメンデーション用データ
  ai_features: {
    contentVector: number[];    // コンテンツベクトル（類似性計算用）
    semanticTags: string[];     // AI生成セマンティックタグ
    sentiment: {                // レビュー感情分析
      positive: number;
      neutral: number;
      negative: number;
    };
    recommendations: {
      similar_spots: string[];   // 類似スポットID
      complementary_spots: string[]; // 組み合わせ推奨スポット
      seasonal_alternatives: {
        [season: string]: string[];
      };
    };
    last_analysis: Timestamp;
  };
  
  // 運営・管理
  moderation: {
    status: 'pending' | 'approved' | 'rejected' | 'inactive' | 'flagged';
    approvedBy?: string;
    approvedAt?: Timestamp;
    rejectionReason?: string;
    flags: {
      type: string;
      reportedBy: string;
      reportedAt: Timestamp;
      reason: string;
    }[];
  };
  
  // 検索・発見性
  search_optimization: {
    keywords: string[];         // 検索キーワード
    boost_score: number;        // 検索ブーストスコア
    featured: boolean;          // 注目スポット
    promoted: boolean;          // プロモーション対象
    algolia_indexed: boolean;   // Algolia同期済み
    last_indexed: Timestamp;
  };
  
  // メタデータ
  system: {
    version: number;            // スキーマバージョン
    createdBy: string;          // 作成者UID
    verifiedBy?: string;        // 検証者UID
    lastModifiedBy: string;     // 最終更新者UID
    dataSource: 'user' | 'import' | 'api' | 'scraping';
    confidence: number;         // データ信頼度
    createdAt: Timestamp;
    updatedAt: Timestamp;
  };
}

// 多言語文字列型
interface MultiLanguageString {
  default: string;              // デフォルト言語（通常は作成者の言語）
  en?: string;                  // 英語
  ja?: string;                  // 日本語
  ko?: string;                  // 韓国語
  zh?: string;                  // 中国語（簡体字）
  zh_TW?: string;              // 中国語（繁体字）
  es?: string;                  // スペイン語
  fr?: string;                  // フランス語
  de?: string;                  // ドイツ語
  [key: string]: string | undefined; // その他の言語コード
}
```

### 3. reviews サブコレクション
spots/{spotId}/reviews - AI分析・多言語対応レビューシステム

```typescript
interface Review {
  id: string;
  userId: string;
  userName: string;
  userPhotoURL?: string;
  userVerificationLevel: string;
  
  // レビュー内容
  content: {
    rating: {
      overall: number;            // 1-5 総合評価
      aspects: {                  // 項目別評価
        atmosphere: number;
        service: number;
        value: number;
        accessibility: number;
        cleanliness: number;
      };
    };
    text: MultiLanguageString;    // 多言語コメント
    title?: MultiLanguageString;  // レビュータイトル
    tags: string[];              // ユーザー設定タグ
    visitPurpose: 'leisure' | 'business' | 'transit' | 'other';
    groupType: 'solo' | 'couple' | 'family' | 'friends' | 'group';
    season: 'spring' | 'summer' | 'autumn' | 'winter';
  };
  
  // メディア
  media: {
    photos: {
      url: string;
      optimized: {
        thumbnail: string;
        medium: string;
      };
      caption?: MultiLanguageString;
      uploadedAt: Timestamp;
    }[];
    videos?: {
      url: string;
      thumbnail: string;
      duration: number;
      uploadedAt: Timestamp;
    }[];
  };
  
  // 訪問情報
  visit: {
    date: Timestamp;
    duration?: number;            // 滞在時間（分）
    crowdLevel: 'empty' | 'quiet' | 'moderate' | 'busy' | 'crowded';
    weather?: string;
    timeOfDay: 'morning' | 'afternoon' | 'evening' | 'night';
    repeatVisit: boolean;
  };
  
  // AI分析結果
  ai_analysis: {
    sentiment: {
      score: number;              // -1 to 1
      confidence: number;
      emotions: {
        joy: number;
        surprise: number;
        anger: number;
        fear: number;
        sadness: number;
      };
    };
    topics: string[];            // AI抽出トピック
    keywords: string[];          // キーワード抽出
    helpfulness_score: number;   // 有用性AI予測
    quality_score: number;       // 品質スコア
    authenticity_score: number;  // 真正性スコア
    language_detected: string;   // 検出言語
    last_analyzed: Timestamp;
  };
  
  // エンゲージメント
  engagement: {
    helpful: number;             // 役立った数
    notHelpful: number;          // 役立たなかった数
    replies: number;             // 返信数
    shares: number;              // シェア数
    bookmarks: number;           // ブックマーク数
    helpfulUsers: string[];      // 役立ったユーザーID（重複防止）
  };
  
  // モデレーション
  moderation: {
    status: 'approved' | 'pending' | 'flagged' | 'rejected';
    autoFlags: string[];         // AI自動検出フラグ
    userReports: {
      reportedBy: string;
      reason: string;
      reportedAt: Timestamp;
    }[];
    moderatedBy?: string;
    moderatedAt?: Timestamp;
    rejectionReason?: string;
  };
  
  // メタデータ
  metadata: {
    version: number;
    editHistory: {
      editedAt: Timestamp;
      changes: string[];
    }[];
    source: 'mobile' | 'web' | 'api';
    location?: GeoPoint;         // レビュー投稿位置
    device?: string;
    ip_hash?: string;            // ハッシュ化IP（スパム検出用）
  };
  
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 4. travelPlans コレクション
AI最適化・リアルタイム共有旅行計画システム

```typescript
interface TravelPlan {
  id: string;
  userId: string;
  
  // 基本情報
  basic: {
    title: MultiLanguageString;
    description: MultiLanguageString;
    coverImage?: string;
    theme: 'adventure' | 'relaxation' | 'culture' | 'food' | 'nature' | 'urban' | 'custom';
    tags: string[];
  };
  
  // 目的地情報
  destination: {
    primary: {
      country: string;
      countryCode: string;
      city: string;
      coordinates: GeoPoint;
      timezone: string;
    };
    secondary?: {
      country: string;
      city: string;
      coordinates: GeoPoint;
    }[];
    boundingBox?: {
      northeast: GeoPoint;
      southwest: GeoPoint;
    };
  };
  
  // スケジュール
  schedule: {
    startDate: Timestamp;
    endDate: Timestamp;
    duration: number;           // 日数
    flexibility: 'rigid' | 'moderate' | 'flexible';
    timePreferences: {
      earlyRiser: boolean;
      lateNighter: boolean;
      packedSchedule: boolean;
    };
  };
  
  // 予算
  budget: {
    total: number;
    currency: string;
    breakdown: {
      accommodation: {
        budgeted: number;
        spent: number;
        bookings: string[];    // booking IDs
      };
      transportation: {
        budgeted: number;
        spent: number;
        bookings: string[];
      };
      food: {
        budgeted: number;
        spent: number;
        dailyAverage: number;
      };
      activities: {
        budgeted: number;
        spent: number;
        bookings: string[];
      };
      shopping: {
        budgeted: number;
        spent: number;
      };
      emergency: {
        budgeted: number;
        spent: number;
      };
    };
    trackingEnabled: boolean;
    alerts: {
      overBudgetThreshold: number; // パーセンテージ
      dailySpendingLimit: number;
    };
  };
  
  // 参加者・共有
  collaboration: {
    owner: string;
    participants: {
      userId: string;
      role: 'viewer' | 'editor' | 'admin';
      joinedAt: Timestamp;
      permissions: {
        editItinerary: boolean;
        manageBudget: boolean;
        addParticipants: boolean;
        bookActivities: boolean;
      };
    }[];
    invitations: {
      email: string;
      role: string;
      invitedAt: Timestamp;
      status: 'pending' | 'accepted' | 'declined';
    }[];
    shareSettings: {
      publicShare: boolean;
      shareCode?: string;
      allowComments: boolean;
      allowCopy: boolean;
    };
  };
  
  // 詳細日程
  itinerary: {
    day: number;
    date: Timestamp;
    location: {
      city: string;
      accommodation?: {
        name: string;
        address: string;
        coordinates: GeoPoint;
        bookingId?: string;
      };
    };
    activities: {
      id: string;
      startTime?: string;
      endTime?: string;
      duration?: number;        // 分
      spotId?: string;
      customLocation?: {
        name: string;
        coordinates: GeoPoint;
        address: string;
      };
      title: string;
      description?: string;
      category: string;
      priority: 'must' | 'want' | 'optional';
      status: 'planned' | 'confirmed' | 'completed' | 'cancelled';
      cost?: {
        amount: number;
        currency: string;
        paid: boolean;
      };
      bookingInfo?: {
        provider: string;
        confirmationNumber: string;
        bookingId?: string;
      };
      notes?: string;
      assignedTo: string[];     // 参加者割り当て
      transportation?: {
        method: 'walking' | 'driving' | 'transit' | 'taxi' | 'other';
        duration: number;
        cost?: number;
        details?: string;
      };
    }[];
    weather?: {
      condition: string;
      temperature: {
        high: number;
        low: number;
        unit: 'C' | 'F';
      };
      precipitation: number;
      lastUpdated: Timestamp;
    };
    dailyBudget?: {
      planned: number;
      actual: number;
    };
  }[];
  
  // AI 最適化・推薦
  ai_optimization: {
    enabled: boolean;
    preferences: {
      pace: 'slow' | 'moderate' | 'fast';
      interests: string[];
      mobility: string[];
      budgetPriority: 'low' | 'medium' | 'high';
    };
    suggestions: {
      spots: {
        spotId: string;
        reason: string;
        confidence: number;
        suggestedDay?: number;
      }[];
      optimizations: {
        type: 'time' | 'cost' | 'distance' | 'experience';
        description: string;
        impact: 'low' | 'medium' | 'high';
        applied: boolean;
      }[];
      alerts: {
        type: 'weather' | 'closure' | 'event' | 'congestion';
        message: string;
        severity: 'info' | 'warning' | 'critical';
        affectedDays: number[];
        createdAt: Timestamp;
      }[];
    };
    lastOptimized: Timestamp;
  };
  
  // ステータス・メタデータ
  status: 'draft' | 'planning' | 'confirmed' | 'active' | 'completed' | 'cancelled';
  visibility: 'private' | 'friends' | 'public';
  completion: {
    percentage: number;
    completedActivities: string[];
    missedActivities: string[];
  };
  
  // 実行時追跡
  realtime: {
    currentActivity?: string;
    location?: GeoPoint;
    lastCheckIn?: Timestamp;
    liveTracking: boolean;
    emergencyContacts: {
      name: string;
      phone: string;
      relationship: string;
    }[];
  };
  
  // システム
  system: {
    version: number;
    template?: string;         // 使用テンプレートID
    clonedFrom?: string;       // 複製元プランID
    analytics: {
      views: number;
      likes: number;
      shares: number;
      clones: number;
    };
    backup: {
      lastBackup: Timestamp;
      versions: number;
    };
  };
  
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 5. checklists コレクション
旅行チェックリスト

```typescript
interface Checklist {
  id: string;
  userId: string;
  planId?: string;              // 関連する旅行計画
  title: string;
  items: {
    id: string;
    question: string;
    category: string;           // 'planning' | 'documents' | 'belongings' etc.
    isCompleted: boolean;
    completedAt?: Timestamp;
    notes?: string;
  }[];
  templateId?: string;          // テンプレート使用時
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 6. achievements コレクション
ユーザーの実績・称号

```typescript
interface Achievement {
  id: string;
  userId: string;
  achievementId: string;        // 実績マスターID
  title: string;
  description: string;
  type: 'travel' | 'adventure' | 'social' | 'special';
  progress: number;
  maxProgress: number;
  isUnlocked: boolean;
  unlockedAt?: Timestamp;
  metadata: {
    icon: string;
    color: string;
    requirement: string;
  };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 7. bookings コレクション
予約情報

```typescript
interface Booking {
  id: string;
  userId: string;
  planId?: string;
  type: 'flight' | 'hotel' | 'activity' | 'transportation';
  status: 'pending' | 'confirmed' | 'cancelled' | 'completed';
  details: {
    provider: string;
    confirmationNumber?: string;
    price: {
      amount: number;
      currency: string;
    };
    dates: {
      checkIn?: Timestamp;
      checkOut?: Timestamp;
      departure?: Timestamp;
      arrival?: Timestamp;
    };
    // Type-specific fields
    flight?: {
      airline: string;
      flightNumber: string;
      from: string;
      to: string;
      class: string;
    };
    hotel?: {
      name: string;
      address: string;
      roomType: string;
      guests: number;
    };
  };
  documents: string[];          // Storage URLs for tickets/confirmations
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

### 8. userSpots サブコレクション
users/{userId}/spots - ユーザーのお気に入りスポット

```typescript
interface UserSpot {
  spotId: string;
  addedAt: Timestamp;
  visited: boolean;
  visitedAt?: Timestamp;
  notes?: string;
  tags: string[];
}
```

### 5. 新コレクション群（エンタープライズ機能）

#### 5.1 social_connections コレクション
ソーシャル機能の関係性管理

```typescript
interface SocialConnection {
  id: string;
  fromUserId: string;
  toUserId: string;
  type: 'follow' | 'friend' | 'block' | 'mute';
  status: 'pending' | 'accepted' | 'rejected';
  metadata: {
    source: 'search' | 'recommendation' | 'mutual' | 'import';
    mutualFriends: number;
    commonInterests: string[];
  };
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
```

#### 5.2 social_feed コレクション
ソーシャルフィード・アクティビティストリーム

```typescript
interface FeedItem {
  id: string;
  userId: string;
  type: 'spot_review' | 'plan_shared' | 'achievement' | 'check_in' | 'photo' | 'recommendation';
  content: {
    title: MultiLanguageString;
    description?: MultiLanguageString;
    media?: {
      type: 'image' | 'video';
      url: string;
      thumbnail?: string;
    }[];
    related: {
      spotId?: string;
      planId?: string;
      reviewId?: string;
      achievementId?: string;
    };
  };
  engagement: {
    likes: number;
    comments: number;
    shares: number;
    likedBy: string[];
  };
  privacy: {
    visibility: 'public' | 'friends' | 'private';
    allowComments: boolean;
    allowShares: boolean;
  };
  algorithm: {
    score: number;
    boost: boolean;
    promoted: boolean;
    tags: string[];
  };
  createdAt: Timestamp;
  expiresAt?: Timestamp;
}
```

#### 5.3 realtime_sessions コレクション
リアルタイム機能のセッション管理

```typescript
interface RealtimeSession {
  id: string;
  type: 'live_tracking' | 'group_chat' | 'collaborative_planning' | 'live_review';
  participants: {
    userId: string;
    role: 'host' | 'participant' | 'observer';
    status: 'active' | 'away' | 'disconnected';
    joinedAt: Timestamp;
    lastSeen: Timestamp;
  }[];
  data: {
    planId?: string;
    spotId?: string;
    location?: GeoPoint;
    metadata: { [key: string]: any };
  };
  settings: {
    privacy: 'public' | 'friends' | 'private';
    maxParticipants: number;
    autoExpire: boolean;
  };
  status: 'active' | 'paused' | 'ended';
  createdAt: Timestamp;
  expiresAt: Timestamp;
}
```

#### 5.4 ml_recommendations コレクション
AI/MLレコメンデーション結果

```typescript
interface MLRecommendation {
  id: string;
  userId: string;
  type: 'spot' | 'plan' | 'user' | 'activity' | 'content';
  algorithm: {
    model: string;
    version: string;
    confidence: number;
    explanation: string[];
  };
  recommendations: {
    itemId: string;
    score: number;
    reasons: string[];
    metadata: { [key: string]: any };
  }[];
  context: {
    location?: GeoPoint;
    time: Timestamp;
    season: string;
    weather?: string;
    userState: string;
  };
  performance: {
    shown: boolean;
    clicked: string[];
    conversions: string[];
    feedback: {
      type: 'like' | 'dislike' | 'not_interested' | 'irrelevant';
      itemId: string;
      timestamp: Timestamp;
    }[];
  };
  expiresAt: Timestamp;
  createdAt: Timestamp;
}
```

#### 5.5 geohash_index コレクション
効率的地理検索のためのインデックス

```typescript
interface GeohashIndex {
  id: string;              // geohash prefix
  level: number;           // precision level (1-12)
  bounds: {
    north: number;
    south: number;
    east: number;
    west: number;
  };
  spots: {
    spotId: string;
    coordinates: GeoPoint;
    category: string;
    rating: number;
    popularity: number;
  }[];
  stats: {
    totalSpots: number;
    avgRating: number;
    categories: { [category: string]: number };
    lastUpdated: Timestamp;
  };
  metadata: {
    parent?: string;       // parent geohash
    children: string[];    // child geohashes
    neighbors: string[];   // neighboring geohashes
  };
}
```

---

## キャッシング・パフォーマンス戦略

### Redis キャッシング層

#### キャッシュ戦略
```typescript
interface CacheStrategy {
  // ホットデータ（高頻度アクセス）
  hotData: {
    userProfiles: {
      ttl: 3600;           // 1時間
      pattern: 'user:profile:{userId}';
      invalidation: 'write-through';
    };
    spotBasics: {
      ttl: 7200;           // 2時間
      pattern: 'spot:basic:{spotId}';
      invalidation: 'write-behind';
    };
    reviews: {
      ttl: 1800;           // 30分
      pattern: 'spot:reviews:{spotId}:page:{page}';
      invalidation: 'time-based';
    };
  };
  
  // 検索結果キャッシュ
  searchCache: {
    geoQueries: {
      ttl: 900;            // 15分
      pattern: 'geo:{geohash}:radius:{radius}:category:{category}';
      compression: 'gzip';
    };
    textSearch: {
      ttl: 1800;           // 30分
      pattern: 'search:{query_hash}:filters:{filter_hash}';
      maxSize: '10MB';
    };
  };
  
  // セッション・リアルタイム
  sessions: {
    userSessions: {
      ttl: 86400;          // 24時間
      pattern: 'session:{userId}';
      persistence: 'memory-only';
    };
    realtimeSessions: {
      ttl: 3600;           // 1時間
      pattern: 'realtime:{sessionId}';
      pubsub: true;
    };
  };
}
```

#### パフォーマンス最適化

```typescript
interface PerformanceOptimization {
  // バッチ処理
  batchOperations: {
    batchSize: 100;
    maxWaitTime: 50;       // ms
    compression: 'lz4';
  };
  
  // プリロード戦略
  preload: {
    userContext: string[];      // ユーザーログイン時にプリロード
    geoContext: string[];       // 位置情報取得時にプリロード
    planContext: string[];      // 旅行計画アクセス時にプリロード
  };
  
  // CDN統合
  cdn: {
    images: {
      provider: 'CloudFlare';
      cacheControl: 'public, max-age=31536000';
      formats: ['webp', 'avif', 'jpeg'];
    };
    api: {
      ttl: 300;             // 5分
      staleWhileRevalidate: 600; // 10分
    };
  };
}
```

---

## Geohash地理検索システム

### Geohash実装戦略

```typescript
interface GeohashSystem {
  // 精度レベル設定
  precisionLevels: {
    city: 4;           // ~40km
    district: 6;       // ~2.5km
    neighborhood: 8;   // ~150m
    building: 10;      // ~10m
    precise: 12;       // ~60cm
  };
  
  // 検索最適化
  searchOptimization: {
    radiusQueries: {
      small: {         // <1km
        maxGeohashes: 9;
        precision: 8;
      };
      medium: {        // 1-10km
        maxGeohashes: 25;
        precision: 6;
      };
      large: {         // >10km
        maxGeohashes: 49;
        precision: 4;
      };
    };
    
    // インデックス戦略
    indexing: {
      compound: [
        ['location.geohash', 'category.primary', 'metrics.rating'],
        ['location.geohashPrefixes', 'moderation.status', 'metrics.popularityScore'],
        ['location_meta.country', 'category.primary', 'metrics.qualityScore']
      ];
    };
  };
}
```

### 地理検索API

```typescript
interface GeoSearchAPI {
  // 近隣検索
  nearbySearch: {
    endpoint: '/api/geo/nearby';
    parameters: {
      lat: number;
      lng: number;
      radius: number;        // meters
      categories?: string[];
      filters?: GeoFilter;
      sort?: 'distance' | 'rating' | 'popularity';
      limit?: number;
    };
    response: {
      spots: SpotWithDistance[];
      metadata: SearchMetadata;
    };
  };
  
  // エリア検索
  areaSearch: {
    endpoint: '/api/geo/area';
    parameters: {
      bounds: {
        northeast: { lat: number; lng: number };
        southwest: { lat: number; lng: number };
      };
      zoom: number;
      clustering?: boolean;
    };
  };
  
  // ルート沿い検索
  routeSearch: {
    endpoint: '/api/geo/route';
    parameters: {
      waypoints: { lat: number; lng: number }[];
      corridor: number;      // corridor width in meters
      categories?: string[];
    };
  };
}
```

---

## Algolia統合検索

### 検索インデックス設計

```typescript
interface AlgoliaIndexes {
  // メインスポット検索
  spots: {
    indexName: 'prod_spots';
    attributes: [
      'name',
      'description', 
      'category',
      'location_meta',
      'details.practical.languages',
      'search_optimization.keywords'
    ];
    searchableAttributes: [
      'name.default,name.en,name.ja',
      'description.default,description.en,description.ja',
      'category.primary,category.secondary',
      'search_optimization.keywords'
    ];
    ranking: [
      'desc(metrics.qualityScore)',
      'desc(metrics.popularityScore)',
      'geo(location.coordinates)',
      'desc(metrics.rating)',
      'asc(name.default)'
    ];
    facets: [
      'category.primary',
      'location_meta.country',
      'location_meta.city',
      'details.pricing.range',
      'category.accessibility'
    ];
  };
  
  // ユーザー検索
  users: {
    indexName: 'prod_users';
    attributes: [
      'profile.displayName',
      'profile.bio',
      'stats',
      'preferences.travel'
    ];
    privacy: {
      filterByVisibility: true;
      attributesToRetrieve: ['profile.displayName', 'profile.photoURL', 'stats.travelScore'];
    };
  };
  
  // 旅行計画検索
  plans: {
    indexName: 'prod_travel_plans';
    attributes: [
      'basic.title',
      'basic.description',
      'destination',
      'basic.theme'
    ];
    conditionalSearch: {
      publicPlansOnly: true;
    };
  };
}
```

### 高度な検索機能

```typescript
interface AdvancedSearch {
  // セマンティック検索
  semanticSearch: {
    endpoint: '/api/search/semantic';
    features: {
      intentRecognition: boolean;
      contextualSuggestions: boolean;
      multilangualQuery: boolean;
      typoTolerance: 'strict' | 'moderate' | 'flexible';
    };
  };
  
  // ビジュアル検索
  visualSearch: {
    endpoint: '/api/search/visual';
    imageAnalysis: {
      objectDetection: boolean;
      sceneRecognition: boolean;
      landmarkRecognition: boolean;
      textExtraction: boolean;
    };
  };
  
  // 音声検索
  voiceSearch: {
    endpoint: '/api/search/voice';
    languages: ['ja', 'en', 'ko', 'zh'];
    features: {
      realtime: boolean;
      contextAware: boolean;
      slangRecognition: boolean;
    };
  };
}
```

---

## 画像最適化パイプライン

### 自動画像処理

```typescript
interface ImageOptimizationPipeline {
  // アップロード時処理
  uploadProcessing: {
    validation: {
      maxSize: '50MB';
      allowedFormats: ['jpeg', 'png', 'webp', 'heic'];
      minDimensions: { width: 300, height: 300 };
      maxDimensions: { width: 8000, height: 8000 };
    };
    
    processing: {
      autoRotation: boolean;
      faceDetection: boolean;
      qualityAnalysis: boolean;
      duplicateDetection: boolean;
      contentModeration: boolean;
    };
    
    outputs: {
      thumbnail: { width: 150, height: 150, quality: 85 };
      small: { width: 400, height: 300, quality: 80 };
      medium: { width: 800, height: 600, quality: 75 };
      large: { width: 1200, height: 900, quality: 70 };
      webp: { enabled: true, quality: 80 };
      avif: { enabled: true, quality: 75 };
    };
  };
  
  // AI画像分析
  aiAnalysis: {
    sceneDetection: {
      enabled: boolean;
      confidence: number;
      categories: string[];
    };
    objectDetection: {
      enabled: boolean;
      objects: string[];
      landmarks: boolean;
    };
    qualityAssessment: {
      sharpness: boolean;
      lighting: boolean;
      composition: boolean;
      overallScore: boolean;
    };
  };
  
  // CDN最適化
  cdnOptimization: {
    provider: 'CloudFlare Images';
    features: {
      automaticFormat: boolean;
      smartCropping: boolean;
      adaptiveQuality: boolean;
      lazyLoading: boolean;
    };
    
    delivery: {
      globalPops: boolean;
      http2Push: boolean;
      brotliCompression: boolean;
      webpSupport: boolean;
    };
  };
}
```

---

## 多言語対応アーキテクチャ

### 国際化システム

```typescript
interface InternationalizationSystem {
  // サポート言語
  supportedLanguages: {
    primary: ['en', 'ja'];
    secondary: ['ko', 'zh', 'zh_TW', 'es', 'fr', 'de'];
    experimental: ['th', 'vi', 'id', 'tl'];
  };
  
  // 自動翻訳
  autoTranslation: {
    provider: 'Google Translate API';
    triggers: {
      contentCreation: boolean;
      missingTranslations: boolean;
      userRequest: boolean;
    };
    
    quality: {
      humanReview: boolean;
      confidenceThreshold: 0.8;
      postEditing: boolean;
    };
    
    caching: {
      enabled: boolean;
      ttl: 2592000;        // 30 days
      versioning: boolean;
    };
  };
  
  // 地域化
  localization: {
    currency: {
      detection: 'geo' | 'user_preference' | 'ip';
      conversion: {
        api: 'exchangerate-api.com';
        caching: 3600;     // 1 hour
        fallback: 'USD';
      };
    };
    
    dateTime: {
      formats: {
        'ja': 'YYYY年MM月DD日';
        'en': 'MMM DD, YYYY';
        'ko': 'YYYY년 MM월 DD일';
        'zh': 'YYYY年MM月DD日';
      };
      timezone: {
        autoDetect: boolean;
        override: boolean;
      };
    };
    
    units: {
      distance: {
        'US': 'miles';
        'GB': 'miles';
        'default': 'kilometers';
      };
      temperature: {
        'US': 'fahrenheit';
        'default': 'celsius';
      };
    };
  };
}
```

---

## リアルタイム機能

### WebSocket/SSE統合

```typescript
interface RealtimeSystem {
  // WebSocket エンドポイント
  websocket: {
    endpoint: 'wss://api.world-travel.com/ws';
    authentication: 'jwt-token';
    heartbeat: 30000;      // 30秒
    reconnection: {
      maxRetries: 5;
      backoffMultiplier: 1.5;
      initialDelay: 1000;
    };
  };
  
  // チャンネル定義
  channels: {
    userActivity: 'user:{userId}';
    planCollaboration: 'plan:{planId}';
    locationTracking: 'location:{userId}';
    socialFeed: 'feed:{userId}';
    globalNotifications: 'global';
  };
  
  // イベント種別
  events: {
    user: [
      'status_changed',
      'location_updated', 
      'activity_started',
      'notification_received'
    ];
    plan: [
      'participant_joined',
      'itinerary_updated',
      'comment_added',
      'activity_completed'
    ];
    social: [
      'new_follower',
      'review_liked',
      'plan_shared',
      'achievement_unlocked'
    ];
  };
}
```

### リアルタイム協調編集

```typescript
interface CollaborativeEditing {
  // 旅行計画の同時編集
  planEditing: {
    lockingStrategy: 'optimistic';
    conflictResolution: 'last-write-wins';
    operationalTransform: boolean;
    maxConcurrentEditors: 10;
    
    operations: {
      addActivity: { day: number; activity: Activity };
      updateActivity: { activityId: string; changes: Partial<Activity> };
      deleteActivity: { activityId: string };
      reorderActivities: { day: number; order: string[] };
      updateBudget: { category: string; amount: number };
    };
  };
  
  // リアルタイム位置共有
  locationSharing: {
    precision: 'exact' | 'approximate' | 'city';
    updateInterval: 30000;    // 30秒
    batteryOptimization: boolean;
    geoFencing: {
      enabled: boolean;
      radius: number;         // meters
      notifications: boolean;
    };
  };
}
```

---

## ソーシャル機能

### ソーシャルネットワーク機能

```typescript
interface SocialFeatures {
  // フォロー・フレンド機能
  relationships: {
    followSystem: {
      asymmetric: boolean;    // 一方向フォロー
      followBackSuggestions: boolean;
      mutualFriendThreshold: 3;
    };
    
    privacy: {
      defaultVisibility: 'public' | 'friends' | 'private';
      blockingEnabled: boolean;
      reportingEnabled: boolean;
    };
    
    discovery: {
      suggestionsAlgorithm: 'collaborative_filtering' | 'content_based' | 'hybrid';
      contactsImport: boolean;
      locationBasedSuggestions: boolean;
    };
  };
  
  // フィード・タイムライン
  socialFeed: {
    algorithms: {
      chronological: { weight: 0.3 };
      engagement: { weight: 0.4 };
      relevance: { weight: 0.3 };
    };
    
    contentTypes: [
      'new_review',
      'plan_published',
      'achievement_earned',
      'spot_visited',
      'photo_shared',
      'recommendation_posted'
    ];
    
    engagement: {
      likes: boolean;
      comments: boolean;
      shares: boolean;
      saves: boolean;
    };
  };
  
  // グループ・コミュニティ
  communities: {
    creation: {
      userCanCreate: boolean;
      moderationRequired: boolean;
      maxMembers: 10000;
    };
    
    types: [
      'travel_buddy',
      'destination_specific',
      'interest_based',
      'local_guide'
    ];
    
    features: {
      events: boolean;
      polls: boolean;
      sharedPlans: boolean;
      groupChat: boolean;
    };
  };
}
```

### ソーシャル API

```typescript
interface SocialAPI {
  // ユーザー関係性
  relationships: {
    follow: {
      endpoint: 'POST /api/social/follow';
      parameters: { targetUserId: string };
    };
    unfollow: {
      endpoint: 'DELETE /api/social/follow/{targetUserId}';
    };
    followers: {
      endpoint: 'GET /api/social/followers';
      parameters: { userId?: string; limit?: number; cursor?: string };
    };
    following: {
      endpoint: 'GET /api/social/following';
      parameters: { userId?: string; limit?: number; cursor?: string };
    };
  };
  
  // フィード管理
  feed: {
    timeline: {
      endpoint: 'GET /api/social/feed';
      parameters: { 
        algorithm?: 'chronological' | 'smart';
        limit?: number;
        cursor?: string;
      };
    };
    post: {
      endpoint: 'POST /api/social/post';
      parameters: {
        type: string;
        content: any;
        privacy: 'public' | 'friends' | 'private';
      };
    };
  };
}
```

---

## AI分析・レコメンデーション

### AI/MLアーキテクチャ

```typescript
interface AIMLArchitecture {
  // 推薦システム
  recommendationEngine: {
    models: {
      collaborative: {
        algorithm: 'matrix_factorization';
        features: ['user_interactions', 'ratings', 'preferences'];
        updateFrequency: 'daily';
      };
      
      contentBased: {
        algorithm: 'cosine_similarity';
        features: ['spot_attributes', 'user_profile', 'historical_behavior'];
        vectorDimensions: 512;
      };
      
      deep: {
        algorithm: 'neural_collaborative_filtering';
        architecture: 'transformer';
        embeddingSize: 128;
        trainingSchedule: 'weekly';
      };
    };
    
    ensemble: {
      weights: {
        collaborative: 0.4;
        contentBased: 0.3;
        deep: 0.3;
      };
      dynamicWeighting: boolean;
    };
  };
  
  // 自然言語処理
  nlpServices: {
    reviewAnalysis: {
      sentiment: 'bert-multilingual';
      topics: 'lda';
      keywords: 'tfidf';
      emotions: 'emotion-bert';
    };
    
    translation: {
      model: 'google-translate-v3';
      fallback: 'azure-translator';
      qualityThreshold: 0.85;
    };
    
    textGeneration: {
      descriptions: 'gpt-3.5-turbo';
      recommendations: 'claude-3-haiku';
      summaries: 'bart-large';
    };
  };
  
  // 画像・視覚AI
  visionServices: {
    objectDetection: 'yolo-v8';
    sceneClassification: 'resnet-152';
    landmarkRecognition: 'google-vision-api';
    qualityAssessment: 'nima';
    similaritySearch: 'clip-vit-l14';
  };
  
  // 個人化
  personalization: {
    userEmbedding: {
      dimensions: 256;
      updateTriggers: ['new_review', 'plan_created', 'activity_completed'];
      decayRate: 0.95;     // 時間減衰率
    };
    
    contextAware: {
      location: boolean;
      timeOfDay: boolean;
      season: boolean;
      weather: boolean;
      companions: boolean;
    };
  };
}
```

### レコメンデーション API

```typescript
interface RecommendationAPI {
  // スポット推薦
  spotRecommendations: {
    endpoint: 'GET /api/recommendations/spots';
    parameters: {
      userId?: string;
      location?: { lat: number; lng: number };
      radius?: number;
      categories?: string[];
      context?: {
        travelStyle?: string;
        groupSize?: string;
        budget?: string;
        timeOfDay?: string;
      };
      algorithm?: 'collaborative' | 'content' | 'hybrid' | 'deep';
      limit?: number;
    };
    response: {
      recommendations: {
        spotId: string;
        score: number;
        confidence: number;
        reasons: string[];
        metadata: {
          distance?: number;
          estimatedCost?: number;
          estimatedDuration?: number;
        };
      }[];
      metadata: {
        algorithm: string;
        modelVersion: string;
        generatedAt: string;
        expiresAt: string;
      };
    };
  };
  
  // 旅行計画推薦
  planRecommendations: {
    endpoint: 'POST /api/recommendations/plans';
    parameters: {
      destination: {
        country: string;
        city?: string;
        coordinates?: { lat: number; lng: number };
      };
      preferences: {
        duration: number;
        budget?: number;
        interests: string[];
        travelStyle: string;
        groupSize: number;
      };
      constraints?: {
        startDate?: string;
        endDate?: string;
        mustInclude?: string[];
        exclude?: string[];
      };
    };
  };
  
  // 動的レコメンデーション
  dynamicRecommendations: {
    endpoint: 'GET /api/recommendations/dynamic';
    realtime: boolean;
    contextAware: boolean;
    personalized: boolean;
  };
}
```

### AI分析ダッシュボード

```typescript
interface AnalyticsDashboard {
  // ユーザー行動分析
  userAnalytics: {
    engagement: {
      dailyActiveUsers: number;
      sessionDuration: number;
      screenTime: { [screen: string]: number };
      featureUsage: { [feature: string]: number };
    };
    
    travel: {
      destinationTrends: { [destination: string]: number };
      seasonalPatterns: { [season: string]: any };
      budgetDistribution: { [range: string]: number };
      groupSizeDistribution: { [size: string]: number };
    };
    
    content: {
      reviewSentiment: { positive: number; negative: number; neutral: number };
      topCategories: { [category: string]: number };
      photoAnalysis: { [tag: string]: number };
    };
  };
  
  // ビジネス分析
  businessIntelligence: {
    revenue: {
      subscription: { [plan: string]: number };
      advertising: { [type: string]: number };
      partnerships: { [partner: string]: number };
    };
    
    performance: {
      apiLatency: { [endpoint: string]: number };
      errorRates: { [service: string]: number };
      cacheHitRates: { [cache: string]: number };
    };
    
    growth: {
      userAcquisition: { [channel: string]: number };
      retention: { [cohort: string]: number };
      churn: { [segment: string]: number };
    };
  };
}
```

---

## Firebase Functions API エンドポイント

### 認証 API v2.0

#### POST /api/v2/auth/register
エンハンス新規ユーザー登録
```typescript
// Request
{
  method: 'email' | 'google' | 'apple' | 'facebook';
  credentials: {
    email?: string;
    password?: string;
    idToken?: string;          // Social login token
    accessToken?: string;      // Social login access token
  };
  profile: {
    lastName: string;
    firstName: string;
    kanaLastName?: string;
    kanaFirstName?: string;
    displayName?: string;
    photoURL?: string;
    birthDate?: string;
    location?: {
      country: string;
      city?: string;
    };
  };
  preferences?: {
    language: string;
    currency: string;
    timezone: string;
    travel: {
      interests: string[];
      travelStyle: string;
      preferredBudget: string;
    };
  };
  marketingConsent: boolean;
  termsAccepted: boolean;
  privacyPolicyAccepted: boolean;
}

// Response
{
  uid: string;
  email: string;
  tokens: {
    accessToken: string;
    refreshToken: string;
    expiresIn: number;
  };
  user: User;
  onboarding: {
    completed: boolean;
    nextSteps: string[];
  };
}
```

#### POST /api/v2/auth/login
多要素対応ログイン
```typescript
// Request
{
  method: 'email' | 'google' | 'apple' | 'facebook' | 'phone';
  credentials: {
    email?: string;
    password?: string;
    phone?: string;
    verificationCode?: string;
    idToken?: string;
    accessToken?: string;
  };
  mfa?: {
    token: string;
    method: 'sms' | 'email' | 'totp';
  };
  deviceInfo?: {
    deviceId: string;
    platform: string;
    appVersion: string;
    osVersion: string;
  };
}

// Response
{
  uid: string;
  tokens: {
    accessToken: string;
    refreshToken: string;
    expiresIn: number;
  };
  user: User;
  requiresMfa?: {
    methods: string[];
    challengeId: string;
  };
  newDevice?: {
    requiresVerification: boolean;
    verificationMethod: string;
  };
}
```

#### POST /api/v2/auth/mfa/setup
多要素認証セットアップ
```typescript
// Request
{
  method: 'sms' | 'email' | 'totp';
  contact?: string;          // phone or email
}

// Response
{
  setupId: string;
  qrCode?: string;           // TOTP用
  backupCodes: string[];
  verificationRequired: boolean;
}
```

#### POST /api/v2/auth/social/link
ソーシャルアカウント連携
```typescript
// Request
{
  provider: 'google' | 'apple' | 'facebook' | 'twitter';
  idToken: string;
  accessToken?: string;
}

// Response
{
  linked: boolean;
  provider: string;
  email?: string;
}
```

### ユーザー API v2.0

#### GET /api/v2/users/:userId
拡張ユーザー情報取得
```typescript
// Query Parameters
{
  fields?: string[];         // 取得フィールド指定
  lang?: string;            // 言語設定
  includeStats?: boolean;
  includeRecommendations?: boolean;
}

// Response
{
  user: User;
  achievements?: Achievement[];
  stats?: UserStats;
  recommendations?: {
    spots: Spot[];
    users: User[];
    plans: TravelPlan[];
  };
  privacy: {
    isOwnProfile: boolean;
    visibleFields: string[];
  };
}
```

#### PUT /api/v2/users/:userId
高度なプロファイル更新
```typescript
// Request
{
  profile?: Partial<UserProfile>;
  preferences?: Partial<UserPreferences>;
  privacy?: Partial<PrivacySettings>;
  algorithms?: {
    updatePreferences: boolean;
    recalculateRecommendations: boolean;
  };
}

// Response
{
  user: User;
  changes: {
    modified: string[];
    requiresReAuth: boolean;
    affectsRecommendations: boolean;
  };
}
```

#### POST /api/v2/users/:userId/verify
ユーザー認証・検証
```typescript
// Request
{
  type: 'email' | 'phone' | 'identity' | 'premium';
  documents?: {
    type: string;
    url: string;
  }[];
  reason?: string;
}

// Response
{
  verificationId: string;
  status: 'pending' | 'approved' | 'rejected';
  estimatedProcessingTime: number;
}
```

### 地理検索 API v2.0

#### GET /api/v2/geo/search
統合地理検索
```typescript
// Query Parameters
{
  q?: string;               // テキスト検索クエリ
  lat?: number;
  lng?: number;
  radius?: number;          // meters
  geohash?: string;         // 直接geohash指定
  bbox?: string;            // bounding box "sw_lat,sw_lng,ne_lat,ne_lng"
  
  // フィルター
  categories?: string[];
  priceRange?: string[];
  rating?: number;          // 最小評価
  accessibility?: string[];
  languages?: string[];
  
  // ソート・ページング
  sort?: 'relevance' | 'distance' | 'rating' | 'popularity' | 'recent';
  algorithm?: 'hybrid' | 'geo_only' | 'text_only';
  limit?: number;
  offset?: number;
  cursor?: string;
  
  // 高度な機能
  clustering?: boolean;
  includeImages?: boolean;
  includeReviews?: boolean;
  personalizeResults?: boolean;
}

// Response
{
  results: {
    spots: SpotWithDistance[];
    clusters?: GeoCluster[];
    suggestions?: SearchSuggestion[];
  };
  metadata: {
    total: number;
    searchTime: number;
    algorithm: string;
    geohashesQueried: string[];
    filters: any;
  };
  pagination: {
    hasMore: boolean;
    nextCursor?: string;
    nextOffset?: number;
  };
}
```

#### GET /api/v2/geo/nearby
高性能近隣検索
```typescript
// Query Parameters
{
  lat: number;
  lng: number;
  radius: number;
  categories?: string[];
  limit?: number;
  includeDistance?: boolean;
  includeEta?: boolean;     // 到着予定時間
  transportMode?: 'walking' | 'driving' | 'transit' | 'cycling';
}

// Response
{
  spots: (Spot & {
    distance: number;
    bearing?: number;
    eta?: {
      walking: number;
      driving: number;
      transit?: number;
    };
  })[];
  center: { lat: number; lng: number };
  searchRadius: number;
}
```

#### POST /api/v2/geo/route-search
ルート沿い検索
```typescript
// Request
{
  waypoints: {
    lat: number;
    lng: number;
    stopover?: boolean;
  }[];
  corridorWidth: number;     // meters
  categories?: string[];
  maxDetour?: number;        // max detour in meters
  preferences?: {
    prioritizeHighRated: boolean;
    avoidCrowds: boolean;
    budgetRange?: string;
  };
}

// Response
{
  routeSpots: {
    spotId: string;
    position: { lat: number; lng: number };
    distanceFromRoute: number;
    segmentIndex: number;
    detourTime: number;
  }[];
  route: {
    distance: number;
    duration: number;
    polyline: string;
  };
  optimizedWaypoints?: {
    lat: number;
    lng: number;
    suggestedStops: string[];
  }[];
}
```

### スポット API v2.0

#### GET /api/v2/spots
拡張スポット検索
```typescript
// Query Parameters
{
  // 基本検索
  q?: string;
  categories?: string[];
  location?: string;        // "lat,lng" or city name
  radius?: number;
  
  // 高度なフィルター
  rating?: number;
  priceRange?: string[];
  amenities?: string[];
  accessibility?: string[];
  languages?: string[];
  
  // 時間・季節フィルター
  openNow?: boolean;
  openAt?: string;          // ISO timestamp
  season?: 'spring' | 'summer' | 'autumn' | 'winter';
  
  // AI・パーソナライゼーション
  personalizeFor?: string;  // userId
  travelStyle?: string;
  groupSize?: number;
  budget?: string;
  
  // ソート・表示
  sort?: 'relevance' | 'distance' | 'rating' | 'popularity' | 'trending';
  includePreview?: boolean;
  includeRecommendations?: boolean;
  lang?: string;
  
  // ページング
  limit?: number;
  offset?: number;
  cursor?: string;
}

// Response
{
  spots: Spot[];
  facets?: {
    categories: { [key: string]: number };
    priceRanges: { [key: string]: number };
    ratings: { [key: string]: number };
    locations: { [key: string]: number };
  };
  recommendations?: {
    featured: Spot[];
    trending: Spot[];
    nearbyAlternatives: Spot[];
  };
  metadata: SearchMetadata;
  pagination: PaginationInfo;
}
```

#### POST /api/v2/spots
AI支援スポット作成
```typescript
// Request
{
  basic: {
    name: MultiLanguageString;
    description: MultiLanguageString;
    category: {
      primary: string;
      secondary?: string[];
    };
  };
  location: {
    coordinates: { lat: number; lng: number };
    address: MultiLanguageString;
    what3words?: string;
  };
  details?: SpotDetails;
  media?: {
    photos: File[];
    videos?: File[];
  };
  
  // AI機能
  aiAssistance?: {
    autoTranslate: boolean;
    generateDescription: boolean;
    suggestCategories: boolean;
    optimizeImages: boolean;
  };
  
  // 投稿設定
  visibility: 'public' | 'friends' | 'private';
  moderationRequired: boolean;
}

// Response
{
  spot: Spot;
  processing: {
    imageOptimization: boolean;
    translation: boolean;
    aiAnalysis: boolean;
    estimatedCompleteTime: number;
  };
  suggestions?: {
    categoryAlternatives: string[];
    similarSpots: string[];
    optimizationTips: string[];
  };
}
```

#### POST /api/v2/spots/:spotId/ai-enhance
AI による既存スポット拡張
```typescript
// Request
{
  enhancements: {
    autoTranslate: boolean;
    generateMissingInfo: boolean;
    optimizeImages: boolean;
    addTags: boolean;
    suggestSimilar: boolean;
  };
  targetLanguages?: string[];
}

// Response
{
  enhancements: {
    translations: { [lang: string]: any };
    generatedContent: { [field: string]: any };
    optimizedImages: { [url: string]: string };
    suggestedTags: string[];
    similarSpots: string[];
  };
  applied: boolean;
  estimatedImprovementScore: number;
}
```

### 新機能 API v2.0

#### ソーシャル API
```typescript
// フォロー・アンフォロー
POST /api/v2/social/follow         // ユーザーフォロー
DELETE /api/v2/social/follow/:id   // フォロー解除
GET /api/v2/social/followers       // フォロワー一覧
GET /api/v2/social/following       // フォロー中一覧

// ソーシャルフィード
GET /api/v2/social/feed           // パーソナライズフィード
POST /api/v2/social/posts         // 投稿作成
PUT /api/v2/social/posts/:id      // 投稿編集
DELETE /api/v2/social/posts/:id   // 投稿削除

// エンゲージメント
POST /api/v2/social/like          // いいね
POST /api/v2/social/comment       // コメント
POST /api/v2/social/share         // シェア
POST /api/v2/social/report        // 報告
```

#### リアルタイム API
```typescript
// WebSocket接続
WS /api/v2/realtime/connect       // WebSocket接続

// ライブトラッキング
POST /api/v2/realtime/tracking/start    // 位置トラッキング開始
PUT /api/v2/realtime/tracking/update    // 位置更新
POST /api/v2/realtime/tracking/stop     // トラッキング停止

// 協調編集
POST /api/v2/realtime/collaborate/:planId  // 協調編集開始
PUT /api/v2/realtime/operations           // 編集操作送信
GET /api/v2/realtime/conflicts            // 競合解決
```

#### AI/ML API
```typescript
// レコメンデーション
GET /api/v2/ai/recommendations/spots     // スポット推薦
GET /api/v2/ai/recommendations/plans     // プラン推薦
GET /api/v2/ai/recommendations/users     // ユーザー推薦
POST /api/v2/ai/recommendations/feedback // フィードバック送信

// 画像分析
POST /api/v2/ai/vision/analyze          // 画像分析
POST /api/v2/ai/vision/search           // 画像検索
POST /api/v2/ai/vision/enhance          // 画像最適化

// 自然言語処理
POST /api/v2/ai/nlp/translate           // 翻訳
POST /api/v2/ai/nlp/sentiment           // 感情分析
POST /api/v2/ai/nlp/generate            // テキスト生成
POST /api/v2/ai/nlp/summarize           // 要約
```

#### 高度な検索 API
```typescript
// セマンティック検索
GET /api/v2/search/semantic             // 意味検索
POST /api/v2/search/visual              // ビジュアル検索
POST /api/v2/search/voice               // 音声検索
GET /api/v2/search/suggestions          // 検索候補

// Algolia統合
GET /api/v2/algolia/search              // Algolia検索
GET /api/v2/algolia/facets              // ファセット検索
POST /api/v2/algolia/insights           // 分析データ送信
```

### スポット API

#### GET /api/spots
スポット一覧取得
```typescript
// Query Parameters
{
  category?: string;
  country?: string;
  city?: string;
  lat?: number;
  lng?: number;
  radius?: number;      // km
  sort?: 'rating' | 'likes' | 'reviews' | 'distance';
  limit?: number;
  offset?: number;
}

// Response
{
  spots: Spot[];
  total: number;
  hasMore: boolean;
}
```

#### GET /api/spots/:spotId
スポット詳細取得
```typescript
// Response
{
  spot: Spot;
  reviews: Review[];
  nearby: Spot[];
}
```

#### POST /api/spots
スポット作成
```typescript
// Request
{
  name: string;
  address: string;
  location: {
    lat: number;
    lng: number;
  };
  category: string[];
  details: SpotDetails;
  media?: {
    photos: File[];
  };
}

// Response
{
  spot: Spot;
}
```

#### POST /api/spots/:spotId/like
スポットにいいね
```typescript
// Response
{
  liked: boolean;
  likeCount: number;
}
```

### レビュー API

#### GET /api/spots/:spotId/reviews
レビュー一覧取得
```typescript
// Query Parameters
{
  sort?: 'newest' | 'oldest' | 'helpful' | 'rating';
  limit?: number;
  offset?: number;
}

// Response
{
  reviews: Review[];
  total: number;
  averageRating: number;
}
```

#### POST /api/spots/:spotId/reviews
レビュー投稿
```typescript
// Request
{
  rating: number;
  comment: string;
  photos?: File[];
  visitedAt?: string;
}

// Response
{
  review: Review;
  spotRating: number;
}
```

### 旅行計画 API

#### GET /api/travel-plans
旅行計画一覧取得
```typescript
// Query Parameters
{
  userId?: string;
  status?: string;
  upcoming?: boolean;
}

// Response
{
  plans: TravelPlan[];
  total: number;
}
```

#### POST /api/travel-plans
旅行計画作成
```typescript
// Request
{
  title: string;
  description: string;
  destination: Destination;
  schedule: Schedule;
  budget: Budget;
  participants?: string[];
}

// Response
{
  plan: TravelPlan;
}
```

#### PUT /api/travel-plans/:planId
旅行計画更新
```typescript
// Request
{
  // Partial<TravelPlan>
}

// Response
{
  plan: TravelPlan;
}
```

#### POST /api/travel-plans/:planId/itinerary
日程追加
```typescript
// Request
{
  day: number;
  activities: Activity[];
}

// Response
{
  plan: TravelPlan;
}
```

### チェックリスト API

#### GET /api/checklists
チェックリスト取得
```typescript
// Query Parameters
{
  userId?: string;
  planId?: string;
}

// Response
{
  checklists: Checklist[];
}
```

#### POST /api/checklists
チェックリスト作成
```typescript
// Request
{
  title: string;
  planId?: string;
  templateId?: string;
  items?: ChecklistItem[];
}

// Response
{
  checklist: Checklist;
}
```

#### PUT /api/checklists/:checklistId/items/:itemId
チェックリストアイテム更新
```typescript
// Request
{
  isCompleted: boolean;
  notes?: string;
}

// Response
{
  item: ChecklistItem;
}
```

### 実績 API

#### GET /api/users/:userId/achievements
実績一覧取得
```typescript
// Response
{
  achievements: Achievement[];
  unlockedCount: number;
  totalCount: number;
}
```

#### POST /api/achievements/check
実績達成チェック
```typescript
// Request
{
  userId: string;
  type: string;
}

// Response
{
  newAchievements: Achievement[];
  updated: Achievement[];
}
```

### 予約 API

#### GET /api/bookings
予約一覧取得
```typescript
// Query Parameters
{
  userId?: string;
  planId?: string;
  type?: string;
  status?: string;
}

// Response
{
  bookings: Booking[];
  total: number;
}
```

#### POST /api/bookings
予約作成
```typescript
// Request
{
  type: string;
  planId?: string;
  details: BookingDetails;
  documents?: File[];
}

// Response
{
  booking: Booking;
}
```

### 検索 API

#### GET /api/search
統合検索
```typescript
// Query Parameters
{
  q: string;
  type?: 'spots' | 'plans' | 'users' | 'all';
  limit?: number;
}

// Response
{
  results: {
    spots?: Spot[];
    plans?: TravelPlan[];
    users?: User[];
  };
  total: number;
}
```

### 推薦 API

#### GET /api/recommendations/spots
おすすめスポット取得
```typescript
// Query Parameters
{
  userId: string;
  location?: {
    lat: number;
    lng: number;
  };
  preferences?: string[];
}

// Response
{
  recommendations: Spot[];
  reason: string[];
}
```

#### GET /api/recommendations/itinerary
おすすめ日程生成
```typescript
// Query Parameters
{
  destination: string;
  days: number;
  interests: string[];
  budget?: string;
}

// Response
{
  itinerary: DayPlan[];
  estimatedCost: number;
}
```

---

## 認証・セキュリティ

### 認証方式
- Firebase Authentication を使用
- JWT トークンベース認証
- ソーシャルログイン対応（Google, Apple, Facebook）

### セキュリティルール

#### Firestore セキュリティルール例
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザーは自分のプロファイルのみ編集可能
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // スポットは認証済みユーザーが作成可能
    match /spots/{spotId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.createdBy || 
         request.auth.token.admin == true);
      allow delete: if request.auth != null && 
        request.auth.token.admin == true;
      
      // レビューは認証済みユーザーが投稿可能
      match /reviews/{reviewId} {
        allow read: if true;
        allow create: if request.auth != null;
        allow update: if request.auth != null && 
          request.auth.uid == resource.data.userId;
        allow delete: if request.auth != null && 
          (request.auth.uid == resource.data.userId || 
           request.auth.token.admin == true);
      }
    }
    
    // 旅行計画はプライバシー設定に基づくアクセス制御
    match /travelPlans/{planId} {
      allow read: if resource.data.visibility == 'public' ||
        (request.auth != null && 
         (resource.data.userId == request.auth.uid ||
          request.auth.uid in resource.data.participants.members));
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### API レート制限
- 認証済みユーザー: 1000 リクエスト/時
- 未認証ユーザー: 100 リクエスト/時
- 特定エンドポイント制限:
  - POST /api/spots: 10 リクエスト/日
  - POST /api/reviews: 20 リクエスト/日

---

## エラーハンドリング

### エラーレスポンス形式
```typescript
interface ErrorResponse {
  error: {
    code: string;
    message: string;
    details?: any;
  };
  timestamp: string;
  path: string;
}
```

### HTTPステータスコード
- 200: 成功
- 201: 作成成功
- 400: 不正なリクエスト
- 401: 認証エラー
- 403: 権限エラー
- 404: リソースが見つからない
- 409: 競合エラー
- 429: レート制限超過
- 500: サーバーエラー

### エラーコード一覧
```typescript
enum ErrorCodes {
  // 認証関連
  AUTH_INVALID_CREDENTIALS = 'AUTH001',
  AUTH_TOKEN_EXPIRED = 'AUTH002',
  AUTH_INSUFFICIENT_PERMISSION = 'AUTH003',
  
  // バリデーション関連
  VALIDATION_INVALID_INPUT = 'VAL001',
  VALIDATION_MISSING_FIELD = 'VAL002',
  VALIDATION_INVALID_FORMAT = 'VAL003',
  
  // リソース関連
  RESOURCE_NOT_FOUND = 'RES001',
  RESOURCE_ALREADY_EXISTS = 'RES002',
  RESOURCE_CONFLICT = 'RES003',
  
  // レート制限
  RATE_LIMIT_EXCEEDED = 'RATE001',
  
  // サーバーエラー
  INTERNAL_SERVER_ERROR = 'SRV001',
  SERVICE_UNAVAILABLE = 'SRV002',
}
```

---

## 実装における考慮事項

### パフォーマンス最適化
1. **インデックス設計**
   - 頻繁にクエリされるフィールドにインデックスを作成
   - 複合インデックスの適切な設計

2. **キャッシング戦略**
   - Firebase Hosting CDN でのキャッシング
   - Firestore のオフラインキャッシュ活用
   - メモリキャッシュの実装

3. **バッチ処理**
   - 大量データ処理時のバッチ化
   - Cloud Functions のタイムアウト考慮

### スケーラビリティ
1. **データ分割**
   - ユーザーデータのシャーディング
   - ホットスポット回避

2. **非同期処理**
   - 重い処理は Cloud Tasks/Pub/Sub で非同期化
   - イベントドリブンアーキテクチャの採用

### データ整合性
1. **トランザクション**
   - 重要な更新操作でのトランザクション使用
   - 楽観的ロックの実装

2. **データ検証**
   - クライアント側とサーバー側の二重検証
   - スキーマバリデーションの実装

### 監視・ログ
1. **モニタリング**
   - Cloud Monitoring での監視
   - カスタムメトリクスの設定

2. **ログ管理**
   - 構造化ログの実装
   - エラートレースの記録

---

## マイグレーション戦略

### 初期セットアップ
1. Firebase プロジェクトの作成
2. Firestore データベースの初期化
3. セキュリティルールのデプロイ
4. Functions のデプロイ

### データマイグレーション
1. **段階的移行**
   - 既存データのエクスポート
   - データ変換スクリプトの作成
   - バッチインポート

2. **バックアップ戦略**
   - 定期的な自動バックアップ
   - ポイントインタイムリカバリ

### バージョン管理
1. **API バージョニング**
   - URL パスでのバージョン管理（/api/v1/, /api/v2/）
   - 後方互換性の維持

2. **スキーマ進化**
   - 新フィールドはオプショナル
   - 廃止予定フィールドの段階的削除

---

## 付録

### 用語集
- **GeoPoint**: Firestore の地理的位置を表すデータ型
- **Timestamp**: Firestore のタイムスタンプ型
- **UID**: ユーザー固有識別子
- **JWT**: JSON Web Token

### 参考リンク
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Cloud Functions Best Practices](https://cloud.google.com/functions/docs/bestpractices)

---

## パフォーマンス・スケーラビリティ

### パフォーマンス指標

```typescript
interface PerformanceTargets {
  api: {
    p95ResponseTime: '< 200ms';    // 95パーセンタイル
    p99ResponseTime: '< 500ms';    // 99パーセンタイル
    availabilityTarget: '99.95%';  // 年間ダウンタイム < 4.38時間
    throughput: '10,000 rps';      // リクエスト/秒
  };
  
  search: {
    algoliaResponseTime: '< 50ms';
    geosearchResponseTime: '< 100ms';
    cacheHitRate: '> 85%';
    indexingLatency: '< 30s';
  };
  
  realtime: {
    websocketLatency: '< 100ms';
    messageDelivery: '99.9%';
    connectionStability: '> 99%';
    maxConcurrentConnections: 100000;
  };
  
  ai: {
    recommendationGeneration: '< 500ms';
    imageProcessing: '< 10s';
    translationLatency: '< 2s';
    batchProcessing: '< 5min';
  };
}
```

### スケーラビリティ戦略

```typescript
interface ScalabilityArchitecture {
  // 水平スケーリング
  horizontalScaling: {
    autoScaling: {
      metrics: ['cpu_utilization', 'memory_usage', 'request_rate'];
      minInstances: 3;
      maxInstances: 100;
      scaleOutThreshold: 70;      // CPU使用率70%
      scaleInThreshold: 30;       // CPU使用率30%
    };
    
    loadBalancing: {
      strategy: 'round_robin';
      healthChecks: true;
      sessionAffinity: false;
      geoRouting: true;
    };
  };
  
  // データ分散
  dataPartitioning: {
    users: {
      strategy: 'hash_based';
      partitionKey: 'user_id';
      replicas: 3;
    };
    
    spots: {
      strategy: 'geohash_based';
      partitionKey: 'geohash_prefix';
      shardCount: 64;
    };
    
    analytics: {
      strategy: 'time_based';
      partitionKey: 'date';
      retentionPolicy: '2_years';
    };
  };
  
  // キャッシュ階層
  cacheHierarchy: {
    level1: {
      type: 'memory';
      size: '2GB';
      ttl: '5min';
      hitRate: '95%';
    };
    
    level2: {
      type: 'redis';
      size: '100GB';
      ttl: '1hour';
      hitRate: '85%';
    };
    
    level3: {
      type: 'cdn';
      size: 'unlimited';
      ttl: '24hours';
      hitRate: '70%';
    };
  };
}
```

### 最適化戦略

```typescript
interface OptimizationStrategies {
  // クエリ最適化
  queryOptimization: {
    indexStrategy: {
      compound: 'multi_field_queries';
      partial: 'prefix_searches';
      sparse: 'optional_fields';
      text: 'full_text_search';
    };
    
    aggregationPipeline: {
      earlyFiltering: boolean;
      indexUsage: boolean;
      memoryLimit: '100MB';
    };
  };
  
  // 画像最適化
  imageOptimization: {
    formats: ['webp', 'avif', 'jpeg'];
    responsiveImages: boolean;
    lazyLoading: boolean;
    compression: {
      quality: 'adaptive';
      algorithm: 'mozjpeg';
    };
  };
  
  // API最適化
  apiOptimization: {
    pagination: {
      defaultSize: 20;
      maxSize: 100;
      cursorBased: boolean;
    };
    
    batching: {
      enabled: boolean;
      maxBatchSize: 50;
      timeWindow: '100ms';
    };
    
    compression: {
      algorithm: 'gzip';
      minSize: '1KB';
      level: 6;
    };
  };
}
```

---

## 認証・セキュリティ v2.0

### 多層セキュリティアーキテクチャ

```typescript
interface SecurityArchitecture {
  // 認証層
  authentication: {
    methods: ['jwt', 'oauth2', 'biometric', 'mfa'];
    tokenSecurity: {
      algorithm: 'RS256';
      expiration: '1h';
      refreshRotation: boolean;
      blacklisting: boolean;
    };
    
    passwordSecurity: {
      minLength: 12;
      complexity: 'high';
      hashAlgorithm: 'argon2id';
      saltRounds: 12;
    };
  };
  
  // 認可層
  authorization: {
    model: 'rbac';            // Role-Based Access Control
    permissions: {
      granular: boolean;
      contextAware: boolean;
      timebound: boolean;
    };
    
    dataAccess: {
      fieldLevel: boolean;
      rowLevel: boolean;
      geofencing: boolean;
    };
  };
  
  // データ保護
  dataProtection: {
    encryption: {
      atRest: 'aes-256-gcm';
      inTransit: 'tls-1.3';
      keyRotation: '90days';
    };
    
    privacy: {
      dataMinimization: boolean;
      purposeLimitation: boolean;
      retentionPolicies: boolean;
      rightToBeForgotten: boolean;
    };
  };
  
  // 脅威対策
  threatMitigation: {
    rateLimiting: {
      global: '1000/hour';
      perUser: '100/minute';
      perEndpoint: 'dynamic';
    };
    
    ddosProtection: {
      cloudflare: boolean;
      geoBlocking: string[];
      botMitigation: boolean;
    };
    
    monitoring: {
      anomalyDetection: boolean;
      realTimeAlerts: boolean;
      incidentResponse: 'automated';
    };
  };
}
```

---

## エラーハンドリング v2.0

### 統一エラーレスポンス

```typescript
interface ErrorResponse {
  error: {
    code: string;              // 機械読み取り用エラーコード
    message: string;           // 人間可読エラーメッセージ
    details?: any;             // 詳細情報
    traceId: string;          // 分散トレーシングID
    timestamp: string;         // ISO 8601形式
    path: string;             // APIパス
    method: string;           // HTTPメソッド
    userId?: string;          // ユーザーID (認証済みの場合)
  };
  
  // 国際化対応
  localizedMessage: {
    [language: string]: string;
  };
  
  // 復旧提案
  suggestions?: {
    action: string;
    description: string;
    automated: boolean;
  }[];
  
  // サポート情報
  support?: {
    contactUrl: string;
    documentationUrl: string;
    statusPageUrl: string;
  };
}
```

### エラーカテゴリと対応

```typescript
enum ErrorCategories {
  // 認証・認可 (1000-1999)
  AUTH_INVALID_CREDENTIALS = 'AUTH_1001',
  AUTH_TOKEN_EXPIRED = 'AUTH_1002',
  AUTH_INSUFFICIENT_PERMISSIONS = 'AUTH_1003',
  AUTH_MFA_REQUIRED = 'AUTH_1004',
  AUTH_ACCOUNT_LOCKED = 'AUTH_1005',
  
  // バリデーション (2000-2999)
  VALIDATION_INVALID_INPUT = 'VAL_2001',
  VALIDATION_MISSING_FIELD = 'VAL_2002',
  VALIDATION_INVALID_FORMAT = 'VAL_2003',
  VALIDATION_FILE_TOO_LARGE = 'VAL_2004',
  VALIDATION_GEOLOCATION_INVALID = 'VAL_2005',
  
  // リソース (3000-3999)
  RESOURCE_NOT_FOUND = 'RES_3001',
  RESOURCE_ALREADY_EXISTS = 'RES_3002',
  RESOURCE_CONFLICT = 'RES_3003',
  RESOURCE_QUOTA_EXCEEDED = 'RES_3004',
  
  // レート制限 (4000-4999)
  RATE_LIMIT_EXCEEDED = 'RATE_4001',
  RATE_LIMIT_QUOTA_EXCEEDED = 'RATE_4002',
  
  // サービス (5000-5999)
  SERVICE_UNAVAILABLE = 'SRV_5001',
  SERVICE_TIMEOUT = 'SRV_5002',
  SERVICE_OVERLOADED = 'SRV_5003',
  
  // 外部API (6000-6999)
  EXTERNAL_API_ERROR = 'EXT_6001',
  EXTERNAL_API_TIMEOUT = 'EXT_6002',
  EXTERNAL_API_QUOTA_EXCEEDED = 'EXT_6003',
  
  // AI/ML (7000-7999)
  AI_MODEL_ERROR = 'AI_7001',
  AI_PROCESSING_TIMEOUT = 'AI_7002',
  AI_QUOTA_EXCEEDED = 'AI_7003',
  
  // リアルタイム (8000-8999)
  REALTIME_CONNECTION_FAILED = 'RT_8001',
  REALTIME_MESSAGE_FAILED = 'RT_8002',
  REALTIME_SESSION_EXPIRED = 'RT_8003',
}
```

### 自動復旧機能

```typescript
interface AutoRecoverySystem {
  retryPolicies: {
    exponentialBackoff: {
      initialDelay: 1000;      // 1秒
      maxDelay: 30000;         // 30秒
      multiplier: 2;
      maxRetries: 3;
    };
    
    circuitBreaker: {
      failureThreshold: 5;
      timeout: 60000;          // 1分
      resetTimeout: 300000;    // 5分
    };
  };
  
  fallbackStrategies: {
    cacheFirst: boolean;       // キャッシュフォールバック
    degradedMode: boolean;     // 機能縮退モード
    offlineMode: boolean;      // オフライン対応
  };
  
  healthChecks: {
    interval: 30000;           // 30秒
    timeout: 5000;             // 5秒
    endpoints: string[];
  };
}
```

---

## 更新履歴

### Version 2.0.0 (2024-12-XX)
- 🚀 **新機能**: エンタープライズレベルアーキテクチャへの全面移行
- 🔍 **検索**: Geohash地理検索システム実装
- 🔍 **検索**: Algolia統合による高度な全文検索
- 🎨 **画像**: AI画像最適化パイプライン追加
- 🌐 **多言語**: 完全多言語対応アーキテクチャ実装
- ⚡ **キャッシュ**: Redis多層キャッシング戦略
- 📡 **リアルタイム**: WebSocket/SSE リアルタイム機能
- 👥 **ソーシャル**: フォロー、フィード、コミュニティ機能
- 🤖 **AI/ML**: レコメンデーション、分析、自動化システム
- 🔐 **セキュリティ**: 多要素認証、RBAC、データ保護強化
- 📊 **分析**: 包括的ユーザー行動・ビジネス分析
- 🏗️ **アーキテクチャ**: マイクロサービス対応スケーラブル設計

### Version 1.0.0 (2024-11-XX)
- 📱 初版リリース: 基本的なFirebase統合
- 👤 ユーザー管理基盤
- 📍 基本的なスポット管理
- ✍️ レビューシステム
- 🗓️ 旅行計画機能
- ✅ チェックリスト機能
- 🏆 実績システム
- 📚 予約管理
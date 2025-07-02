# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Orpheus Clientは、Naxos.jpのクラシック音楽ストリーミングサービス用のFlutterアプリケーションです。日本語UIで構築されており、iOS、Android、Webに対応しています。

## 開発コマンド

### 基本コマンド
```bash
# 依存関係のインストール
flutter pub get

# アプリの実行
flutter run

# 静的解析の実行
flutter analyze

# テストの実行
flutter test

# 特定のテストファイルの実行
flutter test test/widget_test.dart

# ビルド
flutter build ios
flutter build apk
flutter build web
```

### iOS開発時
```bash
cd ios
pod install
cd ..
```

## アーキテクチャ概要

### ディレクトリ構造
- `lib/Screens/` - UI層（フィーチャーベースで整理）
  - `login/` - 認証関連の画面
  - `main/` - メイン機能の画面（home、playback、playlist、account）
  - `common/` - 共通UIコンポーネント
- `lib/api/` - API通信層（Naxos.jp APIとの通信）
- `lib/providers/` - 状態管理層（Providerパターン）
- `lib/storage/` - データ永続化層（SQLite、SharedPreferences、SecureStorage）
- `lib/components/` - 再利用可能なUIコンポーネント

### 主要な状態管理
- **PlayState** (`lib/providers/play_state.dart`) - 音楽再生の中心的な状態管理
  - 再生キュー、シャッフル、リピート機能
  - バックグラウンド再生のサポート
  - just_audioパッケージを使用

### API認証
- Naxos.jp API (http://api2.naxos.jp) を使用
- HMAC-SHA1署名ベースの認証
- 自動トークンリフレッシュ機能
- 認証情報はflutter_secure_storageで安全に保存

### ナビゲーション
- BottomNavigationBarで4つのタブを管理
  - ホーム（検索、新着）
  - プレイリスト
  - 再生中
  - アカウント
- 各タブは独立したNavigatorを持つ（状態の永続化）

### 重要な実装パターン
1. **非同期処理**: Future/async-awaitパターンを使用
2. **エラーハンドリング**: adaptive_dialogで統一的なエラー表示
3. **UIパターン**: 
   - 日本語UI（ボタンテキスト、メッセージ等）
   - MediaQueryでレスポンシブ対応
   - Noto Sans JPフォントを使用

### セキュリティ考慮事項
- ユーザー認証情報はflutter_secure_storageに保存
- API通信時はHMAC-SHA1署名を付与
- APIキーやトークンはコードにハードコードしない

### データベース
- SQLiteを使用（sqfliteパッケージ）
- 検索履歴の保存に使用
- `lib/storage/sqlite.dart`で管理

### テスト環境
- 基本的なウィジェットテストが設定済み
- `test/`ディレクトリにテストファイルを配置

## Memories

- Interact with user in Japanese, but think in English
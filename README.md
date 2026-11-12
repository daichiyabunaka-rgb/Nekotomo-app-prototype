# ニーアキャット（猫とも！）

**猫を飼っている飼い主さん同士が、猫との暮らしでつながる、中身重視の趣味特化型マッチングアプリのプロトタイプです。** 近くの同じ趣味の人（猫とも）を探して交流できます。ともつく！シリーズの猫 Edition で、第1弾: [飯とも！Meshitomo](https://github.com/daichiyabunaka-rgb/Meshitomo-app-prototype)、第2弾: [犬とも！Inutomo](https://github.com/daichiyabunaka-rgb/Inutomo-app-prototype)、第3弾: [釣りとも！Tsuritomo](https://github.com/daichiyabunaka-rgb/Tsuritomo-app-prototype) の設計を踏襲しています。

ビジネスモデルは、**一般ユーザー（無料）とビジネスユーザー（ねこカフェ・ペットサロン・ペットショップ・動物病院などの事業者）** の2層構造です。

## コンセプト・設計原則

| 原則 | 内容 |
|---|---|
| 飼い主の顔画像禁止 | アイコンは**猫に関連する画像のみ**許可（**愛猫の顔はむしろ推奨**）。飼い主本人の顔が写った画像はアップロード不可 |
| 恋愛目的禁止 | 出会い系としての法律が適用されないよう、利用規約で明示的に禁止 |
| 時限性 | 募集は期限付き（1〜3時間）。期限が来たら自動で消える |
| 距離は粗表示 | 位置は「〜1km / 1〜3km」のようなバンド表示のみ。正確な座標は非公開 |
| ペットファースト | 猫ちゃんの安全・体調を最優先する文言・機能設計 |

**注意: モックデータには位置情報が含まれません。** モックの一般ユーザー・店舗は現在地（GPSまたは初期設定の場所）からの相対距離で配置されます。モックユーザーの配置先は端末内データのみに保存され、Supabase には送信されません。Supabase 接続時は Supabase 側のユーザーのデータのみ表示され、モックユーザーは表示されません。

## 実装機能（プロトタイプ）

- メール会員登録 / ログイン / ログアウト（端末内アカウント・セッションの永続化）
- GPS位置情報取得 →（距離バンド付きの）近くの猫とも / 店舗 / コミュニティ・イベントを一覧
- 募集（ねこカフェ / もふもふ会 / お散歩・お出かけ。1〜3時間の期限付きで「今から」感を出す）
- 1:1のDM
- コミュニティ・イベント（誰でも作成・参加でき、参加するとチャットが始まる）
- **近くの猫スポット（特別機能）**: 現在地周辺の OpenStreetMap（Overpass API）から、ねこカフェ・ペットショップ・動物病院を一覧表示。Googleマップで開く・その場で募集（もふもふ会など）がワンタップで可能
- **近くの保護猫・迷い猫（特別機能）**: 近くで見つけた猫ちゃん・いなくなった猫ちゃんの情報を近隣で共有。掲載者へのDM・解決済み機能付き。譲渡・里親探しは行わず、自治体・保護団体の正式な手続きへ誘導
- 興味カテゴリ（ねこカフェ / 愛猫撮影 / TNR活動 など）はDBを通じて全ユーザーに共有される
- アイコン画像の投稿（Supabase Storage の公開バケットに自動リサイズ後アップロード。端末内フォールバック付き）
- **ともつく！シリーズとのアカウント共有**（犬とも！・釣りとも！と同一の Supabase auth を共用。プロフィール・募集・DMは app_id でアプリごとに分離）
- **ともつく！連携**（アプリ横断表示 cross_app_visible・アプリ横断DM）

※ベータ版のため、メール登録確認機能・AI接客機能・ビジネスユーザーのAIチャットはロック中です。

## 構成

```
docs/
  要件定義書_猫とも_v1.md          機能要件・非機能要件・KPI・データモデル
  supabase_multiapp_migration.sql      共有DB化・app_id分離マイグレーション（tomotsuku-memo-share 0002相当）
  supabase_multiapp_v2_cross_app.sql   ともつく！連携（cross_app_visible。0003相当）
  supabase_nekotomo_cats.sql           保護猫テーブル・投稿写真バケットの作成（ニーアキャット用・未適用）
app/                            Flutter アプリ（Android / iOS / Web 対応）
  lib/src/screens/             画面（near_page に 募集/人/店舗/猫スポット の4セクション）
  lib/src/services/            認証・位置情報・Supabase Data Access（app_id フィルタ・RLSを前提）
  lib/src/util/cat_spots.dart   近くの猫スポット取得（Overpass API・ミラーフォールバック・キャッシュ・GoogleマップURL生成）
  lib/src/mock/                 モックユーザー・シード募集（GPS現在地からの相対距離で配置）
tools/make_icon.py              ランチャーアイコン生成スクリプト（Python + Pillow。フラットデザインの猫）
```

## 起動手順

```powershell
cd app
flutter pub get
flutter run -d chrome          # ブラウザ
flutter run -d <デバイスID>     # Android 端末（flutter devices で確認）
flutter build apk --release     # APK ビルド
```

接続DBは「ともつく！」シリーズ共通の Supabase プロジェクトです（接続情報と鍵の扱いは tomotsuku-memo リポジトリ参照）。

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=https://hlcsuogoghrgqabkaqxm.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=<tomotsuku-memo参照>
```

dart-define を付けない場合はローカルモック（端末内データのみ）で起動します。

静的解析: `flutter analyze` / 自動テスト: `flutter test`

## Supabase 接続の前提

1. **共通DB**: 犬とも！・釣りとも！と同じ Supabase プロジェクトを共有します（アカウント〈auth.users〉共通、その他のデータは app_id で分離）。
2. **事前に適用が必要なマイグレーション**: `docs/supabase_multiapp_migration.sql` と `docs/supabase_multiapp_v2_cross_app.sql`（tomotsuku-memo-share の 0002 / 0003 と同一内容）。
3. **ニーアキャット用**: `docs/supabase_nekotomo_cats.sql` を Supabase Dashboard の SQL Editor で適用してください（protected_cats テーブルと protected-cat-photos バケット）。
4. **アイコン投稿バケット**: `icons` バケットは犬とも！と共通です（ユーザーごとの `UUID/nekotomo/` 名前空間に配置されるため使い回せます）。
5. **猫スポット検索**: OpenStreetMap（Overpass API）を利用。APIキー不要・User-Agent必須。ねこカフェは店名とのマッチングで判定するため、OSM でのデータ整備が進むほど精度が上がります。
6. **画像モデレーション**: アイコンの動物検証等は本リリース版で実装予定（犬とも！の Human/Animal 判定相当）。

## 運用

- スキーマ変更は必ず [tomotsuku-memo](https://github.com/daichiyabunaka-rgb/tomotsuku-memo)（Private）の master を先に変更し、そこから SQL Editor へ適用する運用ルールに従う
- クライアントには publishable key のみを埋め込む（`--dart-define` 経由）。secret key は絶対にコミットしない

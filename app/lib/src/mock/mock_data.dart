import 'dart:math' as math;

import '../models.dart';

/// モックユーザーは「anchor（中心点）からの相対距離」で配置する。
/// anchor には実 GPS で取得した現在地が入り、どこにいても近くの猫とも候補が並ぶ。
class _MockSpec {
  final String id;
  final String nickname;
  final String decade;
  final String gender;
  final String iconCategoryId;
  final List<String> interestIds;
  final String bio;
  final double northKm; // anchor からの北方向距離
  final double eastKm; // anchor からの東方向距離

  const _MockSpec(this.id, this.nickname, this.decade, this.gender,
      this.iconCategoryId, this.interestIds, this.bio, this.northKm,
      this.eastKm);
}

const List<_MockSpec> _specs = [
  _MockSpec(
    'u-munchkin-moka',
    'マンチカンのもかママ',
    '30代',
    'female',
    'catcafe',
    ['catcafe', 'photo', 'goods'],
    'マンチカンのもか（女の子・3歳）。おやつの新商品を探すのが趣味。ねこカフェによく通います。',
    0.6,
    0.2,
  ),
  _MockSpec(
    'u-scott-yuki',
    'スコ猫のゆきパパ',
    '20代',
    'male',
    'play',
    ['play', 'training', 'photo'],
    'スコティッシュフォールドのそら（男の子・2歳）。おもちゃで遊ぶのが大好き。',
    -0.3,
    -0.1,
  ),
  _MockSpec(
    'u-noraneko-ken',
    'のら猫ケアのケン',
    '40代',
    'male',
    'tnr',
    ['tnr', 'rescue', 'health'],
    '地域ののら猫のTNRとごはん係をしています。何年も続けています。',
    0.15,
    -0.4,
  ),
  _MockSpec(
    'u-multicat-sara',
    '多頭飼いのさら',
    '30代',
    'undisclosed',
    'multicat',
    ['multicat', 'grooming', 'health'],
    '保護猫から3匹お迎えして多頭飼いに。ブラッシングの時間がいちばん幸せ。',
    -0.7,
    0.5,
  ),
  _MockSpec(
    'u-mix-kuro',
    '雑種猫のくろママ',
    '50代以上',
    'female',
    'health',
    ['health', 'grooming', 'tnr'],
    '雑種のくろ（男の子・10歳）。シニア猫の健康管理について話したい。',
    1.2,
    -0.9,
  ),
  _MockSpec(
    'u-bengal-rika',
    'ベンガルのリカ',
    '20代',
    'female',
    'travel',
    ['travel', 'photo', 'catcafe'],
    'ベンガルのひなた（女の子・1歳）。ハーネスをつけてのお出かけ練習中。',
    -1.1,
    1.0,
  ),
  _MockSpec(
    'u-ragdoll-masa',
    'ラグドール飼いの眞',
    '40代',
    'male',
    'rescue',
    ['rescue', 'catcafe', 'health'],
    '保護猫から迎えたラグドールのしろ（男の子・4歳）。里親活動も応援しています。',
    0.9,
    0.35,
  ),
  _MockSpec(
    'u-kijitora-yui',
    'キジトラのゆい',
    '20代',
    'undisclosed',
    'photo',
    ['photo', 'catcafe', 'goods'],
    'キジトラのちっち（女の子・2歳）。思い出の写真を撮るのが趣味。',
    0.45,
    -1.3,
  ),
];

class _BusinessSpec {
  final String id;
  final String nickname;
  final String iconCategoryId;
  final String storeType;
  final String bio;
  final double northKm;
  final double eastKm;

  const _BusinessSpec(this.id, this.nickname, this.iconCategoryId,
      this.storeType, this.bio, this.northKm, this.eastKm);
}

const List<_BusinessSpec> _businessSpecs = [
  _BusinessSpec(
    'b-catcafe-mofumofu',
    'ねこカフェ もふもふ',
    'catcafe',
    'ねこカフェ',
    '18匹の保護猫が暮らすねこカフェ。猫ちゃんデザートドリンクも人気。飼い主さん同士の交流の場にも。',
    0.8,
    0.9,
  ),
  _BusinessSpec(
    'b-petshop-konekodo',
    'ペットショップ こねこ堂',
    'goods',
    'ペットショップ',
    'フードやおもちゃの相談ができるペットショップ。お迎え前の相談も歓迎です。',
    -0.5,
    1.1,
  ),
  _BusinessSpec(
    'b-salon-pokopoko',
    'ペットサロン ぽこぽこ',
    'grooming',
    'ペットサロン・トリミング',
    '猫ちゃんのペースを最優先にしたシャンプーとブラッシング。爪切りもお任せください。',
    1.5,
    -0.6,
  ),
  _BusinessSpec(
    'b-vet-aibuki',
    'あいぶき動物病院',
    'health',
    '動物病院',
    '予防接種・健康診断のほか、少し気になることも気軽に相談できる病院です。',
    -1.4,
    -0.8,
  ),
];

const double _kmPerDegLat = 111.32;

AppUser _specToUser(_MockSpec s, double anchorLat, double anchorLng) {
  final cos =
      math.cos(anchorLat * math.pi / 180.0).abs().clamp(0.01, 1.0);
  return AppUser(
    id: s.id,
    nickname: s.nickname,
    decade: s.decade,
    gender: s.gender,
    iconCategoryId: s.iconCategoryId,
    interestIds: s.interestIds,
    bio: s.bio,
    lat: anchorLat + s.northKm / _kmPerDegLat,
    lng: anchorLng + s.eastKm / (_kmPerDegLat * cos),
  );
}

BusinessUser _specToBusiness(
    _BusinessSpec s, double anchorLat, double anchorLng) {
  final cos =
      math.cos(anchorLat * math.pi / 180.0).abs().clamp(0.01, 1.0);
  return BusinessUser(
    id: s.id,
    nickname: s.nickname,
    decade: '経営者',
    gender: 'undisclosed',
    iconCategoryId: s.iconCategoryId,
    interestIds: const [],
    bio: s.bio,
    lat: anchorLat + s.northKm / _kmPerDegLat,
    lng: anchorLng + s.eastKm / (_kmPerDegLat * cos),
    storeType: s.storeType,
  );
}

/// 現在地を中心にモックユーザー（一般 + ビジネス）を配置する。
List<AppUser> buildMockUsers(double anchorLat, double anchorLng) {
  return [
    for (final s in _specs) _specToUser(s, anchorLat, anchorLng),
    for (final s in _businessSpecs) _specToBusiness(s, anchorLat, anchorLng),
  ];
}

/// シード募集（起動時刻からの残り時間で作るので、いつ開いても「今から」感が出る）。
/// host は generalUsers（モック一般ユーザー）から id で引く。
List<Recruitment> seedRecruitments(DateTime now, List<AppUser> generalUsers) {
  Recruitment make({
    required String hostId,
    required String genreId,
    required String title,
    required String body,
    required String meetup,
    required int capacity,
    required int minutesLeft,
  }) {
    return Recruitment(
      id: 'r-$hostId',
      hostId: hostId,
      genreId: genreId,
      title: title,
      body: body,
      meetup: meetup,
      capacity: capacity,
      createdAt: now.subtract(const Duration(minutes: 15)),
      expiresAt: now.add(Duration(minutes: minutesLeft)),
      memberIds: [hostId],
    );
  }

  return [
    make(
      hostId: 'u-munchkin-moka',
      genreId: 'catcafe',
      title: '今から昼、駅前のねこカフェで一息どうですか',
      body: 'もかの写真を見せ合いながらお茶しませんか。初めてでも気軽にどうぞ。猫種は問いません。',
      meetup: 'ねこカフェ もふもふ 2階席',
      capacity: 3,
      minutesLeft: 105,
    ),
    make(
      hostId: 'u-scott-yuki',
      genreId: 'mofukai',
      title: 'もふもふ会、あと2名どうですか',
      body: 'うちの猫の写真自慢会をします。おやつの持ち寄りも歓迎。',
      meetup: '公民館の談話室',
      capacity: 3,
      minutesLeft: 70,
    ),
    make(
      hostId: 'u-kijitora-yui',
      genreId: 'catcafe',
      title: '日曜午後、ねこカフェで一息どうですか',
      body: '猫の写真を見せ合いながらまったりできれば。おいしいドリンクもあるお店です。',
      meetup: '駅の東口',
      capacity: 4,
      minutesLeft: 160,
    ),
    make(
      hostId: 'u-bengal-rika',
      genreId: 'sanpo',
      title: 'ベンガルと一緒に、キャリーでお出かけ練習',
      body: 'ハーネスをつけて公園の芝生で初お散歩の練習をします。お出かけ仲間がほしい。',
      meetup: 'リバーサイド公園 駐車場',
      capacity: 2,
      minutesLeft: 95,
    ),
    make(
      hostId: 'u-mix-kuro',
      genreId: 'mofukai',
      title: 'シニア猫の健康の話、ゆる〜くしませんか',
      body: '老猫の食事と通院の話ができれば嬉しい。うちのくろは10歳です。',
      meetup: '公園前のファミレス',
      capacity: 4,
      minutesLeft: 130,
    ),
    make(
      hostId: 'u-ragdoll-masa',
      genreId: 'mofukai',
      title: '保護猫の先輩飼い主さんとお話しませんか',
      body: 'お迎え前後のお悩み相談会。里親活動の情報交換もしたいです。初心者も大歓迎。',
      meetup: 'あいぶき動物病院 前',
      capacity: 3,
      minutesLeft: 45,
    ),
  ];
}

/// 保護猫・迷い猫のシード。anchor（現在地）からの相対距離で配置する。
/// id が 'pd-seed-' 始まりのものは GPS 更新のたびに再配置される
/// （AppState.applyGps を参照）。
class _ProtectedSeedSpec {
  final String id;
  final String reporterId;
  final String kind;
  final String catDescription;
  final String areaName;
  final String detail;
  final double northKm;
  final double eastKm;
  final Duration age;
  const _ProtectedSeedSpec(this.id, this.reporterId, this.kind,
      this.catDescription, this.areaName, this.detail, this.northKm,
      this.eastKm, this.age);
}

const List<_ProtectedSeedSpec> _protectedSeedSpecs = [
  _ProtectedSeedSpec(
    'pd-seed-1',
    'u-noraneko-ken',
    'protected',
    'キジトラの子猫（推定2か月・小柄・白い手足）',
    '河川敷リバーサイド公園 周辺',
    'ダンボールに入って捨てられていました。現在は自宅で保護中。'
        '里親さんを探しています。お心当たりのある方はDMをください。',
    0.3,
    -0.6,
    Duration(hours: 2),
  ),
  _ProtectedSeedSpec(
    'pd-seed-2',
    'u-munchkin-moka',
    'lost',
    '茶白の成猫（女の子・やせ形・青い首輪）',
    '駅東側の商店街',
    '夕方17時頃にベランダから脱走しました。青い首輪をしていました。'
        '少し人見知りです。目撃情報だけでも歓迎します。',
    -0.2,
    0.8,
    Duration(hours: 5),
  ),
  _ProtectedSeedSpec(
    'pd-seed-3',
    'u-multicat-sara',
    'protected',
    '白黒の成猫（シニア・左耳耳カット）',
    '中央公園 周辺',
    '駐車場で震えていたので自宅に保護しました。耳カットがあるので'
        'TNR済みの可能性。ご家族の方はDMください。',
    -0.9,
    -0.3,
    Duration(hours: 26),
  ),
];

List<ProtectedCat> buildSeedProtectedCats(
    DateTime now, double anchorLat, double anchorLng) {
  final cos = (anchorLat * math.pi / 180.0).abs().clamp(0.01, 1.0);
  return [
    for (final s in _protectedSeedSpecs)
      ProtectedCat(
        id: s.id,
        reporterId: s.reporterId,
        kind: s.kind,
        catDescription: s.catDescription,
        areaName: s.areaName,
        detail: s.detail,
        lat: anchorLat + s.northKm / _kmPerDegLat,
        lng: anchorLng + s.eastKm / (_kmPerDegLat * cos),
        createdAt: now.subtract(s.age),
      ),
  ];
}

/// ---------- 近況報告のシード（anchor＝現在地からの相対距離で配置） ----------

class _CatReportSeedSpec {
  final String id;
  final String posterId;
  final String kind;
  final String itemDescription;
  final String areaName;
  final String detail;
  final double northKm;
  final double eastKm;
  final Duration age;
  const _CatReportSeedSpec(this.id, this.posterId, this.kind,
      this.itemDescription, this.areaName, this.detail, this.northKm,
      this.eastKm, this.age);
}

const List<_CatReportSeedSpec> _catReportSeedSpecs = [
  _CatReportSeedSpec(
    'cr-seed-1',
    'u-noraneko-ken',
    'shoot',
    'うちの猫が段ボールで昼寝している姿を撮影しました',
    '自宅の窓辺',
    '日向ぼっこが好きで、いつも段ボールが定位置です。'
        '同じ猫好きさんの写真も見てみたいです。',
    0.3,
    -0.6,
    Duration(hours: 2),
  ),
  _CatReportSeedSpec(
    'cr-seed-2',
    'u-munchkin-moka',
    'post',
    '今週末はねこカフェに行く予定です',
    '駅東側の商店街',
    '新しくできたねこカフェに行ってみます。'
        'おすすめのねこカフェがあったら教えてください。',
    -0.2,
    0.8,
    Duration(hours: 5),
  ),
  _CatReportSeedSpec(
    'cr-seed-3',
    'u-multicat-sara',
    'event',
    '猫好きの集まりに参加してきました',
    '中央公園 周辺',
    '初めての参加でしたが、猫の話で盛り上がって'
        '楽しかったです。次回も参加予定です。',
    -0.9,
    -0.3,
    Duration(hours: 26),
  ),
];

List<CatReport> buildSeedCatReports(
    DateTime now, double anchorLat, double anchorLng) {
  final cos = (anchorLat * math.pi / 180.0).abs().clamp(0.01, 1.0);
  return [
    for (final s in _catReportSeedSpecs)
      CatReport(
        id: s.id,
        posterId: s.posterId,
        kind: s.kind,
        itemDescription: s.itemDescription,
        areaName: s.areaName,
        detail: s.detail,
        lat: anchorLat + s.northKm / _kmPerDegLat,
        lng: anchorLng + s.eastKm / (_kmPerDegLat * cos),
        createdAt: now.subtract(s.age),
      ),
  ];
}

/// モックの返信候補（デモの自動応答に使う。本開発では Supabase Realtime に置換）
const List<String> mockReplies = [
  'よろしくお願いします！',
  '猫ちゃんの様子、楽しみです。',
  '先に着いて席を取っておきますね。',
  'このねこカフェずっと気になっていました。',
];

/// モックの応募メッセージ
const List<String> mockApplyMessages = [
  '参加したいです！うちの子も猫友達を探していました。',
  '猫仲間がいなくて困っていたので嬉しいです。',
  'このお店、近くに住んでいてよく通っています。',
];

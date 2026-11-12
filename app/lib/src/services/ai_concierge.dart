import '../models.dart';

/// AI接客のデモ応答ロジック（プロトタイプ用のモック）。
/// 本開発では LLM API に置き換える。このロジックは店舗業態と
/// ユーザーの興味カテゴリからおすすめを案内する最低限のルールベース。
class AiConcierge {
  /// 最初の挨拶（店舗の口調 + ユーザーの興味を踏まえる）
  String greeting(AppUser me, BusinessUser store) {
    final interest = me.interestIds.isNotEmpty ? me.interestIds.first : null;
    final label = interest == null ? null : _categoryLabel(interest);
    final base = '${_opener(store)}'
        '${me.nickname}さん、${store.nickname}（${store.storeType}）のAI接客です。';
    if (label == null) {
      return '$base 猫ちゃんのことなら何でも聞いてください。';
    }
    return '$base $labelがお好みなんですね。'
        'うちの${_recommend(store)}がおすすめです。';
  }

  /// 店舗タイプごとの口調（本開発では LLM に店舗キャラ設定を渡して生成する）
  String _opener(BusinessUser store) {
    switch (store.storeType) {
      case 'ねこカフェ':
        return 'いらっしゃい！うちの子と一緒にゆっくりしませんか。';
      case 'ペットショップ':
        return 'こんにちは。おもちゃやフードのお試しもできますよ。';
      case 'ペットサロン・トリミング':
        return 'いらっしゃいませ。猫ちゃんのペースに合わせて丁寧にトリミングします。';
      case '動物病院':
        return 'こんにちは。少し気になることも、気軽にご相談ください。';
      default:
        return 'いらっしゃいませ。';
    }
  }

  /// ユーザー発話への応答
  String reply(String input, AppUser me, BusinessUser store) {
    final text = input.replaceAll(RegExp(r'\s'), '');
    if (text.contains('予約') || text.contains('来店')) {
      return 'ありがとうございます。土日は混み合うため、'
          '平日の午前中でしたらゆっくりご案内できます。'
          'ご希望の時間をメモしておきますね。'
          '（デモのため実際の予約機能は本開発で提供します）';
    }
    if (text.contains('おすすめ') || text.contains('オススメ')) {
      return '今回は${_recommend(store)}がおすすめです。'
          '猫ちゃんの苦手なものがあれば教えてください。';
    }
    if (text.contains('猫種') || text.contains('大型') ||
        text.contains('小型')) {
      return '猫ちゃん連れもご自宅の猫ちゃんの写真も歓迎しています。'
          '初めての猫ちゃんには慣れるまで短い時間からのご利用をおすすめしています。';
    }
    if (text.contains('料金') || text.contains('いくら') ||
        text.contains('価格')) {
      return 'ご利用内容によって変わりますが、まずは一度お試しいただけます。'
          '詳しいプランは店舗ページをご確認ください（デモの固定値です）。';
    }
    if (text.contains('何時') || text.contains('営業時間')) {
      return '本日は10:00〜18:00で営業しております。'
          '混雑しやすいのは土曜午前です。（デモの固定値です）';
    }
    if (text.contains('水') || text.contains('トイレ')) {
      return '飲水場と水洗トイレを備えています。'
          '足拭き用のタオルも貸し出していますので、ご利用ください。';
    }
    return '承知しました。「おすすめ」「料金」「営業時間」「予約」「猫ちゃん」など、'
        '気になることを聞いていただければ答えます。';
  }

  String _recommend(BusinessUser store) {
    switch (store.storeType) {
      case 'ねこカフェ':
        return '保護猫と触れ合える開放ルーム';
      case 'ペットショップ':
        return 'おもちゃ・おやつのお試しセット';
      case 'ペットサロン・トリミング':
        return '初回のお試しシャンプーコース';
      case '動物病院':
        return '猫ちゃんの健康診断プラン';
      default:
        return 'おすすめサービス';
    }
  }

  String _categoryLabel(String id) {
    const labels = {
      'catcafe': 'ねこカフェ',
      'photo': '愛猫撮影',
      'goods': 'グッズ・おやつ研究',
      'play': '遊び・おもちゃ研究',
      'grooming': 'お手入れ・ブラッシング',
      'health': '健康・動物病院',
      'training': 'しつけ・トイレトレーニング',
      'travel': 'お出かけ・旅行',
      'rescue': '保護猫・里親活動',
      'tnr': 'のら猫・TNR活動',
      'multicat': '多頭飼い・猫友達',
    };
    return labels[id] ?? '猫のこと';
  }
}

/// グローバルインスタンス（本開発では DI / LLM API クライアントに置き換える）
final AiConcierge aiConcierge = AiConcierge();

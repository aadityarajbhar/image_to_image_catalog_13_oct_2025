import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7679827190624783/6507010708';
    } else if (Platform.isIOS) {
      return 'Ios';
    } else {
      throw UnimplementedError('Unsupported platform');
    }
  }

  static String get getInterstitalAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7679827190624783/2480135782';
    } else if (Platform.isIOS) {
      return 'Ios';
    } else {
      throw UnimplementedError('Unsupported platform');
    }
  }

  static String get getRewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7679827190624783/9353468222';
    } else if (Platform.isIOS) {
      return 'Ios';
    } else {
      throw UnimplementedError('Unsupported platform');
    }
  }
}

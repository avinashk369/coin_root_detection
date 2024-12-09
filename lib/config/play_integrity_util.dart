class PlayIntegrityUtil {
  PlayIntegrityUtil._internal();

  static final PlayIntegrityUtil _instance = PlayIntegrityUtil._internal();

  factory PlayIntegrityUtil() {
    return _instance;
  }

  bool isPlayIntegrityChecked = false;
}
